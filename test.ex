event = %ICalendar.Event{
  uid: Base.encode16(:crypto.strong_rand_bytes(16), case: :upper),
  dtstart: Timex.Timezone.convert(~U[2020-01-01 18:30:00Z], "America/New_York"),
  dtend: Timex.Timezone.convert(~U[2020-01-01 18:45:00Z], "America/New_York"),
  dtstamp: Timex.Timezone.convert(~U[2020-01-01 18:30:00Z], "America/New_York"),
  last_modified: Timex.now(),
  tzid: "America/New_York",
  summary: "Going fishing at the lake that happens to be in the middle of fun street.",
  description: "Escape from the world. Stare at some water. Maybe you'll even catch some fish!",
  location: "123 Fun Street, Toronto ON, Canada",
  status: "tentative",
  categories: ["Fishing", "Nature"],
  comment: "Don't forget to take something to eat !",
  class: "private",
  geo: {43.6978819, -79.3810277},
  organizer: %{"CN" => "eric@clockk.com", "EMAIL" => "eric@clockk.com", :original_value => "mailto:eric@clockk.com"},
  rrule: %{
    byday: ["TH", "WE"],
    freq: "WEEKLY",
    bysetpos: [-1],
    interval: 1,
    until: ~U[2020-12-04 04:59:59Z]
  },
  exdates: [
    Timex.Timezone.convert(~U[2020-09-16 18:30:00Z], "America/New_York"),
    Timex.Timezone.convert(~U[2020-09-17 18:30:00Z], "America/New_York")
  ],
  attendees: [
    %{"CN" => "eric@clockk.com", "EMAIL" => "eric@clockk.com", :original_value => "mailto:eric@clockk.com"},
    %{"CN" => "paul@clockk.com", "EMAIL" => "paul@clockk.com", :original_value => "mailto:paul@clockk.com"}
  ],
  attachments: [
    %{"ENCODING" => "BASE64", "VALUE" => "BINARY", :original_value => Base.encode64(File.read!("./test.ex"))}
  ]
}

tz = %ICalendar.Timezone{
  tzid: "America/New_York",
  standard: %ICalendar.Timezone.Standard{
    tzoffsetfrom: -500,
    tzoffsetto: 100,
    tzname: "EDT"
  },
  daylight: %ICalendar.Timezone.Daylight{
    tzoffsetfrom: -1500,
    tzoffsetto: 100,
    tzname: "EST"
  },
  tzoffsetfrom: -500,
  tzoffsetto: 100,
  tzname: "EDT"
}

alarm = %ICalendar.Alarm{
  trigger: "PT5M",
  duration: "PT5M",
  action: "EMAIL",
  description: "Don't forget to take something to eat !",
  attendees: [
    %{"CN" => "eric@clockk.com", "EMAIL" => "eric@clockk.com", :original_value => "mailto:eric@clockk.com"}
  ],
  repeat: 1
}

calendar = %ICalendar{events: [event], timezones: [tz], alarms: [alarm]}

ICalendar.to_ics(calendar)
