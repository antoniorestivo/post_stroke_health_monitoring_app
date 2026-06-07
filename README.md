# post_stroke_health_monitoring_app

A Rails 8 JSON API backend for tracking health metrics, conditions, treatments, and journaling for post-stroke recovery. The frontend is a separate client (not in this repo) that consumes the `/api/*` endpoints.

## Stack

- **Ruby** 3.2.4 / **Rails** 8 (API-only)
- **PostgreSQL** 16 (primary store)
- **Redis** 7 + **Sidekiq** 7 (background jobs, Rack::Attack throttle cache)
- **JWT** for auth (Bearer tokens, 24h expiry)
- **RSpec** + FactoryBot for tests
- **MailHog** for catching dev emails

## Architecture at a glance

- All endpoints live under `/api/*` and inherit from `Api::BaseController`, which decodes a `Bearer <JWT>` header and sets `current_user`. Public actions opt out with `skip_before_action :authenticate_user`.
- Non-trivial business logic lives in `app/domain/` as plain Ruby service objects (`.build` / `.call` entry points), not in controllers or models.
- The chart system is the most involved piece: `UserChart` records carry a `chart_mode` (`metric_vs_metric`, `metric_over_time`, `metric_frequency`, `treatment_comparison`) which `UserCharts::Enrich` dispatches to the right mode handler under `app/domain/user_charts/`.
- Health data flow: `User → JournalTemplate → Journals` (with a `jsonb` `metrics` column keyed by `HealthMetric#metric_name`) and `User → Conditions → Treatments → TreatmentRetrospects`.
- `DemoSeedUser.call(user)` builds a full sample dataset (21 days of journals, conditions, treatments, default charts). Hit `POST /api/demo_login` to spin up a throwaway demo user.
- `Rack::Attack` throttles `/api/sessions`, `/api/demo_login`, and applies a global per-IP cap. Redis is the throttle store.

See `CLAUDE.md` for a deeper dive intended for AI assistants and new contributors who want the full map.

## Running locally

Everything runs via Docker Compose — you do **not** need a host-side Ruby, Postgres, or Redis install for normal development.

```bash
# First time, or whenever Gemfile/Dockerfile changes:
docker compose build

# Start the whole stack (web, sidekiq, postgres, redis, mailhog) in the background:
docker compose up -d

# Create / migrate the database:
docker compose exec web bundle exec rails db:setup    # first time
docker compose exec web bundle exec rails db:migrate  # subsequent migrations

# Tail logs:
docker compose logs -f web sidekiq
```

Services and ports:

| Service | Host port | Notes |
|---|---|---|
| Rails (`web`) | `3000` | API root: `http://localhost:3000/api` |
| Postgres (`db`) | `5433` → 5432 | Internal hostname `db` |
| Redis | `6379` | Internal hostname `redis` |
| MailHog SMTP | `1025` | Catches outbound mail |
| MailHog Web UI | `8025` | `http://localhost:8025` |
| Sidekiq Web UI | — | Mounted at `http://localhost:3000/sidekiq` (development only) |

To stop everything: `docker compose down`. Your Postgres data persists in the `postgres_data` named volume.

## Running a Rails console

The gems are baked into the Docker image, and the `web` container is the one with the right bundle *and* network DNS for `db`/`redis`. Run the console **inside** the running container:

```bash
docker compose exec web bundle exec rails console
```

Useful variants:

```bash
# Sandboxed — rolls back all DB changes on exit. Great for poking around safely.
docker compose exec web bundle exec rails console --sandbox

# Test environment (e.g. to reproduce a spec failure).
docker compose exec -e RAILS_ENV=test web bundle exec rails console

# Plain shell inside the container.
docker compose exec web bash

# DB consoles.
docker compose exec web bundle exec rails dbconsole
docker compose exec db psql -U postgres post_stroke_health_monitoring_development
```

If the `web` container isn't running, either start it (`docker compose up -d web`) and use `exec`, or create a one-shot container:

```bash
docker compose run --rm web bundle exec rails console
```

**Don't run `bundle install` on your host.** The Dockerfile pins `bundler 2.6.2` and a specific RubyGems version; host bundlers tend to be newer and will resolve to different gem versions than `Gemfile.lock` expects, producing errors like `Could not find connection_pool-2.5.5, ...`. Treat the container as your real Ruby environment.

## Tests

RSpec with FactoryBot. Sidekiq runs in `fake!` mode and the queue is cleared before every example, so jobs do not execute inline — assert on enqueued jobs or call `.perform_now` explicitly.

```bash
# Full suite
docker compose exec web bundle exec rspec

# A single file
docker compose exec web bundle exec rspec spec/controllers/api/sessions_controller_spec.rb

# A single example by line
docker compose exec web bundle exec rspec spec/path/to_spec.rb:42
```

Controller / request specs authenticate via `auth_headers_for(user)` from `spec/support/auth_helpers.rb`, which mints a JWT signed with `Rails.application.secret_key_base`.

Security tooling:

```bash
docker compose exec web bundle exec brakeman
docker compose exec web bundle exec bundle-audit check --update
```

## Configuration

Environment variables (with sensible defaults baked into `docker-compose.yml`):

| Variable | Default in compose | Purpose |
|---|---|---|
| `DATABASE_URL` | `postgres://postgres:password@db:5432/post_stroke_health_monitoring_development` | Rails / Sidekiq DB connection |
| `REDIS_URL` | `redis://redis:6379/0` | Sidekiq + Rack::Attack store |
| `JWT_SECRET_KEY` | *(falls back to `secret_key_base`)* | Signs and verifies API JWTs |
| `RAILS_ENV` | `development` | — |

For a host-side run (rare — see warning above), `config/database.yml` also honors `DATABASE_HOST`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`, `DATABASE_NAME_DEVELOPMENT`, `DATABASE_NAME_TEST`, and `RAILS_MAX_THREADS`.

## Troubleshooting

**`PG::ConnectionBad: could not translate host name "db"`** — the `web` and `db` containers got separated onto different Docker networks (common after a Docker / WSL restart). Fix by recreating the stack:

```bash
docker compose down
docker compose up -d
# verify:
docker compose exec web getent hosts db
```

**Stale `tmp/pids/server.pid`** — the `web` service command already removes it, but if you started Rails outside of compose at some point and it's stuck, `rm tmp/pids/server.pid` and restart the container.

**Sidekiq jobs not running in dev** — check `docker compose ps`: the `sidekiq` service should be `Up`. If it exited, `docker compose logs sidekiq` will usually show a DB or Redis connection error (often the same network issue as above).
