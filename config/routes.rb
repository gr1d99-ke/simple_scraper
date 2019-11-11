require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  root to: 'welcome#index'
  post '/scrape-links', to: 'scrape#scrape_links'
end
