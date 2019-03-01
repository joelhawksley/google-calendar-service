require "google/apis/calendar_v3"
require "httparty"
require "json"

def lambda_handler(event:, context: "")
  puts "event"
  puts event.inspect

  events = fetch_events(event["config"]["calendar_ref"], event["config"]["credential_options"])

  begin
    response = HTTParty.post(
      event["config"]["callback_url"],
      body: {
        callback_secret: event["config"]["callback_secret"],
        calendar_ref: event["config"]["calendar_ref"],
        events: events
      }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
  rescue HTTParty::Error => error
    puts error.inspect
    raise error
  end
end

def fetch_events(calendar_ref, credential_options)
  credentials = Google::Auth::UserRefreshCredentials.new(credential_options)
  credentials.fetch_access_token!

  service = Google::Apis::CalendarV3::CalendarService.new
  service.authorization = credentials

  events = []

  items =
    service.list_events(
      calendar_ref,
      max_results: 100,
      single_events: true,
      order_by: 'startTime',
      time_min: (Date.today - 14).to_datetime.iso8601
    ).items

  items.each_with_index do |event, index|
    event_json = JSON.parse(event.to_json)

    out = event_json.slice("summary", "location")

    out["title"] = event_json["summary"]
    out["location"] = event_json["location"] || ""

    if event_json["start"].key?("date")
      out["start_date"] = event_json["start"]["date"]

      # Google always puts the end date as the next day. This doesn't make sense.
      # If an event is a single day, it should start *and* and on the same date.
      out["end_date"] = (Date.parse(event_json["end"]["date"]) - 1).to_s
    else
      out["start_utc_i"] = DateTime.parse(event_json["start"]["dateTime"]).strftime("%s")
      out["end_utc_i"] = DateTime.parse(event_json["start"]["dateTime"]).strftime("%s")
    end

    events << out
  end

  events
end
