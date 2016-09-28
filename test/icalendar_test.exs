defmodule ICalendarTest do
  use ExUnit.Case

  test "ICalendar.to_ics/1 of empty calendar" do
    ics = %ICalendar{} |> ICalendar.to_ics
    assert ics == """
    BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    VERSION:2.0
    END:VCALENDAR
    """
  end

  test "ICalendar.to_ics/1 of a calendar with an event, as in README" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtend:   Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "Let's go see Star Wars.",
      },
      %ICalendar.Event{
        summary: "Morning meeting",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {19, 00, 00}}),
        dtend:   Timex.to_datetime({{2015, 12, 24}, {22, 30, 00}}),
        description: "A big long meeting with lots of details.",
      },
    ]
    ics = %ICalendar{ events: events } |> ICalendar.to_ics

    assert ics == """
    BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    VERSION:2.0
    BEGIN:VEVENT
    DESCRIPTION:Let's go see Star Wars.
    DTEND;TZID=Etc/UTC:20151224T084500
    DTSTART;TZID=Etc/UTC:20151224T083000
    SUMMARY:Film with Amy and Adam
    END:VEVENT
    BEGIN:VEVENT
    DESCRIPTION:A big long meeting with lots of details.
    DTEND;TZID=Etc/UTC:20151224T223000
    DTSTART;TZID=Etc/UTC:20151224T190000
    SUMMARY:Morning meeting
    END:VEVENT
    END:VCALENDAR
    """
  end

  test "Icalender.to_ics/1 with location and sanitization" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtend:   Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "Let's go see Star Wars, and have fun.",
        location: "123 Fun Street, Toronto ON, Canada"
      },
    ]
    ics = %ICalendar{ events: events } |> ICalendar.to_ics
    assert ics == """
    BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    VERSION:2.0
    BEGIN:VEVENT
    DESCRIPTION:Let's go see Star Wars\\, and have fun.
    DTEND;TZID=Etc/UTC:20151224T084500
    DTSTART;TZID=Etc/UTC:20151224T083000
    LOCATION:123 Fun Street\\, Toronto ON\\, Canada
    SUMMARY:Film with Amy and Adam
    END:VEVENT
    END:VCALENDAR
    """
  end

  test "ICalendar.to_ics/1 with RRULE" do
    events = [
      %ICalendar.Event{
        rrule: %ICalendar.RRULE{
          frequency: :yearly,
          until: Timex.to_datetime({{2022, 10, 12}, {15, 30, 0}}, "Etc/UTC"),
          by_day: [1, 3, 5],
          week_start: :monday,
          by_month: [:april]
        }
      }
    ]

    ics =
      %ICalendar{ events: events }
      |> ICalendar.to_ics

    assert ics == """
    BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    VERSION:2.0
    BEGIN:VEVENT
    RRULE:BYDAY=1,3,5;BYMONTH=april;FREQ=YEARLY;UNTIL=20221012T153000;WKST=MO
    END:VEVENT
    END:VCALENDAR
    """
  end

  test "ICalender.to_ics/1 -> ICalendar.from_ics/1 and back again" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtend:   Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "Let's go see Star Wars, and have fun.",
        location: "123 Fun Street, Toronto ON, Canada"
      }
    ]
    new_event =
      %ICalendar{ events: events }
      |> ICalendar.to_ics
      |> ICalendar.from_ics

    assert events |> List.first == new_event
  end

end
