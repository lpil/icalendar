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
        dtstart: {{2015, 12, 24}, {8, 30, 00}},
        dtend:   {{2015, 12, 24}, {8, 45, 00}},
        description: "Let's go see Star Wars."
      },
      %ICalendar.Event{
        summary: "Morning meeting",
        dtstart: {{2015, 12, 24}, {19, 00, 00}},
        dtend:   {{2015, 12, 24}, {22, 30, 00}},
        description: "A big long meeting with lots of details."
      }
    ]
    ics = %ICalendar{ events: events } |> ICalendar.to_ics
    assert ics == """
    BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    VERSION:2.0
    BEGIN:VEVENT
    DESCRIPTION:Let's go see Star Wars.
    DTEND:20151224T084500Z
    DTSTART:20151224T083000Z
    SUMMARY:Film with Amy and Adam
    END:VEVENT
    BEGIN:VEVENT
    DESCRIPTION:A big long meeting with lots of details.
    DTEND:20151224T223000Z
    DTSTART:20151224T190000Z
    SUMMARY:Morning meeting
    END:VEVENT
    END:VCALENDAR
    """
  end
end
