# config/routes.rb
Rails.application.routes.draw do
  get 'interview/index'
  root 'home#index'
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: redirect('/')
  get '/interview', to: 'interview#index'
  get '/interview/show', to: 'interview#show', as: :show_interview
  get '/interview/answer', to: 'interview#answer', as: :answer_question
  post '/interview/process_answer', to: 'interview#process_answer', as: :process_answer
  get '/logout', to: 'sessions#destroy', as: :logout
  get "up" => "rails/health#show", as: :rails_health_check
end

