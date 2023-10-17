Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :doctors, only: [:index, :show] do
    resources :working_hours, only: [:index]
    resources :appointments, only: [:index, :create, :update, :destroy]
  end
end
