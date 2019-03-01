# google-calendar-service

Fetches a Google calendar and posts formatted events to a callback URL.

## Requirements

* AWS CLI already configured with at Administrator permission
* [Ruby 2.5 installed](https://www.ruby-lang.org/en/documentation/installation/)
* [Docker installed](https://www.docker.com/community-edition)

## Setup process

```
gem install bundler
bundle
```

## Packaging and deployment

```script/ship```

## Testing

```bash
ruby tests/unit/test_handler.rb
```
