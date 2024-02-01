Rails.application.routes.draw do
  namespace :api do
    post "/users" => "users#create"
    get "/users/:id" => "users#show"
    patch "/users/:id" => "users#update"
    delete "/users/:id" => "users#destroy"

    get "/conditions" => "conditions#index"
    get "/conditions/:id" => "conditions#show"
    post "/conditions" => "conditions#create"
    patch "/conditions/:id" => "conditions#update"
    delete "/conditions/:id" => "conditions#destroy"

    get "/journals" => "journals#index"
    get "journals/new" => "journals#new"
    get "/journals/:id" => "journals#show"
    post "/journals" => "journals#create"
    patch "/journals/:id" => "journals#update"
    delete "/journals/:id" => "journals#destroy"

    post "/sessions" => "sessions#create"
    resources :journal_templates, only: %i(new create edit update)

  end
  get "/*path" => proc { [200, {}, [ActionView::Base.new.render(file: "public/index.html")]] }

end
