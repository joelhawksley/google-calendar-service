require 'json'
require 'pry'
require 'test/unit'
require 'mocha/test_unit'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end

require_relative '../../fetch_events/app'

class HelloWorldTest < Test::Unit::TestCase
  def event
    {
      "config" =>
        {
          "calendar_ref" => "hawksley.org@group.calendar.google.com",
          "credential_options" => {
            "client_id" => "scrubbed",
            "scope" => "email https://www.googleapis.com/auth/calendar.readonly",
            "client_secret" => "scrubbed",
            "refresh_token" => "scrubbed",
            "additional_parameters" => { "access_type"=>"offline"}
          },
          "callback_secret"=>"foo",
          "callback_url"=>"http://www.google.com"
        }
    }
  end

  def test_lambda_handler
    VCR.use_cassette("google/fetch_calendar", :match_requests_on => [:host]) do
      HTTParty.expects(:post).with do |url, args|
        url_correct = url == "http://www.google.com"

        body = JSON.parse(args[:body])
        secret_correct = body["callback_secret"] == "foo"

        event_one = {
          "summary"=>"Test hour event",
          "title"=>"Test hour event",
          "location"=>"",
          "start_utc_i"=>"1551319200",
          "end_utc_i"=>"1551319200"
        }

        event_one_correct = body["events"][0] == event_one

        event_two = {
          "summary"=>"Test daily event",
          "title"=>"Test daily event",
          "location"=>"",
          "start_date"=>"2019-02-28",
          "end_date"=>"2019-02-28"
        }

        event_two_correct = body["events"][1] == event_one

        url_correct && secret_correct && event_one_correct
      end

      lambda_handler(event: event)
    end
  end
end
