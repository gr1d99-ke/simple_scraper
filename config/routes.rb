require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  mount Sidekiq::Web => '/sidekiq'

  root to: 'welcome#index'
  resources :scrapes, only: %i[new create]
end
