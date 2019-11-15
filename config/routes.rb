require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  root to: 'welcome#index'
  resources :scrapes, only: %i[new create]
end
