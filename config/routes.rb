# config/routes.rb
Rails.application.routes.draw do
  get 'interview/index'
  root 'home#index'
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: redirect('/')
  get '/interview', to: 'interview#index'
  get '/logout', to: 'sessions#destroy', as: :logout
  get "up" => "rails/health#show", as: :rails_health_check
end

