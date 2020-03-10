[![HitCount](http://hits.dwyl.io/gr1d99/my-scraper.svg)](http://hits.dwyl.io/gr1d99/my-scraper)

# simple_links_scraper

Is a simple Ruby on Rail web application that attempts to extract all links in any given web application __(except facebook and youtube)__.
The application only extracts links of the given url, this means it will not follow identified links that it finds.

## Next steps
- [ ] Implement following of links to a depth of __1__ as long as it is within the scope of the url domain.
## Getting Started

These instructions will get you a copy of the project up and running on your local machine
### Prerequisites

What things you need to install the software and how to install them

- Ruby-v2.5.1p57
- Rails-v5.2.1
- Postgresql

### Installing

A step by step series of examples that tell you how to get a development env running

1. Clone this repo
2. `cd` to `my-scraper` directory
3. Install dependencies `bundle install`
4. Setup figaro `figaro install`
5. Setup some environment variables in _config/application.yml_ file
   ```bash
   DOMAIN: [your-domain]
   SMTP_USER_NAME: [your gmail address]
   SMTP_PASSWORD: [your gmail password]
   ```
   __NB: replace everything that is inside []__
6. Prepare database `rake db:setup`
7. Migrate database `rake db:migrate`
8. Start sidekiq `bundle exec sidekiq -q default -q mailers`
9. Start development server `rails s` :sunglasses:

## Running the tests

`bundle exec rspec`

## Built With

* [Ruby](https://www.ruby-lang.org/en/) - The programming language
* [Rails](https://rubyonrails.org/) - Web framework
* [Postgres](https://www.postgresql.org/) - Database
* [Sidekiq](https://sidekiq.org/) - For background jobs
* [Faraday](https://github.com/lostisland/faraday) - For external HTTP requests

## Authors

* **Gideon Kimutai**

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
