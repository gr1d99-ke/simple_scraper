release: ./bin/heroku_release
worker: bundle exec sidekiq
web: bundle exec passenger start -p $PORT --max-pool-size 3
