Rails.application.routes.draw do
  namespace :api do
    post "/users" => "users#create"

  end


end
