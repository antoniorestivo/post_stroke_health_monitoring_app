Rails.application.routes.draw do
  namespace :api do
    resources :users, except: %i(index) do
      resources :user_charts
    end

    get 'confirm_email' => "users#confirm_email"

    resources :conditions do
      resources :treatments do
        resources :treatment_retrospects
      end
    end
    delete "/conditions/:id" => "conditions#destroy"

    get "/journals" => "journals#index"
    get "journals/new" => "journals#new"
    get "/journals/:id" => "journals#show"
    post "/journals" => "journals#create"
    patch "/journals/:id" => "journals#update"
    delete "/journals/:id" => "journals#destroy"
    get "treatments/all" => "treatments#all"

    post "/sessions" => "sessions#create"
    resources :journal_templates, only: %i(new create edit update)
  end
end
