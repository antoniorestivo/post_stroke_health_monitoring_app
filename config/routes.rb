Rails.application.routes.draw do
  namespace :api do
    post "/users" => "users#create"
    get "/users/:id" => "users#show"
    patch "/users/:id" => "users#update"
    delete "/users/:id" => "users#destroy"

    resources :conditions do
      resources :treatments
    end
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
end
