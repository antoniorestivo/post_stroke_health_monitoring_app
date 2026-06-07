# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

Rails 8 API-only app (Ruby 3.2.4), PostgreSQL, Redis, Sidekiq, JWT auth. Frontend is a separate consumer of this JSON API. View templates are `.jb` files (the `jb` gem), not `.jbuilder`.

## Running the app

The intended dev environment is Docker Compose:

```bash
docker compose up           # web on :3000, postgres on :5433, redis on :6379, mailhog UI on :8025
docker compose run web bundle exec rails db:setup
docker compose run web bundle exec rails db:migrate
```

A `sidekiq` service runs jobs; Sidekiq Web UI is mounted at `/sidekiq` in development only.

## Tests

RSpec with FactoryBot. `Sidekiq::Testing.fake!` is enabled globally and `Sidekiq::Worker.clear_all` runs before every example, so jobs do not execute inline — assert on enqueued jobs or call `.perform_now` explicitly.

```bash
bundle exec rspec                              # full suite
bundle exec rspec spec/controllers/api/...     # one file
bundle exec rspec spec/path/to_spec.rb:42      # one example by line
```

Controller/request specs authenticate via `auth_headers_for(user)` from `spec/support/auth_helpers.rb` — it builds a JWT signed with `Rails.application.secret_key_base`.

Security tooling:
```bash
bundle exec brakeman
bundle exec bundle-audit check --update
```

## Architecture

### Authentication
All API endpoints inherit from `Api::BaseController`, which requires a `Bearer <JWT>` header and decodes it with `ENV["JWT_SECRET_KEY"]` (falling back to `Rails.application.secret_key_base`). Controllers that need to be public must `skip_before_action :authenticate_user` (e.g. `UsersController#create`, `UsersController#confirm_email`, `SessionsController`). `current_user` is the only thing controllers should use to scope queries — there is no Pundit/CanCan layer.

### Routing
Every route lives under the `:api` namespace (see `config/routes.rb`). Resource nesting reflects the domain: `users → user_charts`, `conditions → treatments → treatment_retrospects`. Journals are mounted as flat routes rather than nested under `journal_templates`.

### Domain layer (`app/domain/`)
Non-trivial business logic lives here as plain Ruby service objects with a `.build` or `.call` entry point, **not** in models or controllers. The key shape to preserve:

- `UserCharts::Enrich` is the dispatcher that turns a `UserChart` + a journals collection into rendered chart data. It branches on `chart_mode` to one of four handlers:
  - `treatment_comparison` → `UserCharts::TreatmentComparisons::Construct` (boxplot of `TreatmentRetrospect` ratings)
  - `metric_over_time` → `UserCharts::Modes::HandleMetricOverTime` (line)
  - `metric_frequency` → `UserCharts::Modes::HandleMetricFrequency` (bar)
  - `metric_vs_metric` → `UserCharts::Modes::HandleMetricVsMetric` (scatter)
- `chart_mode` and `chart_type` are coupled. `UserChart.create_with_mode!` is the canonical writer and enforces the mapping; do not let callers pick `chart_type` independently of `chart_mode`.
- `DemoSeedUser.call(user)` builds the complete demo dataset (journal template, health metrics with warning thresholds, conditions, treatments, retrospects, 21 days of journal entries, and the default `UserChart`s). `SessionsController#demo` invokes this inside a transaction when `POST /api/demo_login` is hit. Changes to the demo experience belong here, not in seeds.

### Data model essentials
- `User has_one :journal_template` and `has_many :journals, through: :journal_template`. A user's metrics live on `JournalTemplate`, not directly on the user — `User#journal_template!` raises `ActiveRecord::RecordNotFound` if missing.
- `Journal#metrics` is a `jsonb` column keyed by `HealthMetric#metric_name` (e.g. `{ "Sleep Time" => 7.2, "Mood" => "energetic" }`). The chart layer reads metrics by string key, so renaming a `HealthMetric#metric_name` will silently break historical journal lookups — there is no migration path for that today.
- `HealthMetric#warning_threshold` + `warning_modifier` (`"lteq"`/`"gteq"`) drive threshold lines drawn on charts via `UserCharts::Enrich#find_warning_thresholds`.
- `UserLogin` rows are written synchronously by `SessionsController#create`; `User#usage_statistics` (jsonb) holds aggregated monthly counts read by `UsersController#show` for the dashboard.

### Background jobs
`config.active_job.queue_adapter = :sidekiq`. Jobs are in `app/jobs/`. `Sidekiq::Web` is only mounted in development.

### Rate limiting
`Rack::Attack` is in the middleware stack (`config/initializers/rack_attack.rb`) with throttles on `/api/sessions` (per-IP and per-email), `/api/demo_login` (5/hour/IP), and a global 300/5min/IP cap. The cache store is Redis. Localhost is safelisted. When adding a sensitive endpoint, add a matching throttle here.

### Email confirmation
New users get a `confirmation_token` on create and an email via `UserMailer#confirmation_email` (deliver_later). Demo users skip this (`demo: true` sets `email_confirmed: true`). `SessionsController#create` refuses login for unconfirmed users and re-issues a confirmation email. MailHog (`:8025`) catches outbound mail in development.
