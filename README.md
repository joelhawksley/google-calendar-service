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

### Usage

```ruby
Aws::Lambda::Client.new.invoke({
  function_name: "lambda:arn",
  invocation_type: "Event",
  log_type: "None",
  payload: {
    config: {
      calendar_ref: "google_calendar@google.com",
      credential_options: {
        client_id: "google_client_id",
        scope: "email #{Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY}",
        client_secret: "google_client_secret",
        refresh_token: "google_refresh_token",
        additional_parameters: {"access_type" => "offline"}
      },
      callback_secret: "my_shared_key",
      callback_url: "my_callback_url"
    },
  }.to_json
})
```
