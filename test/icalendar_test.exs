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

  test "ICalendar.to_ics/1 of a calendar with an event" do
    event = %ICalendar.Event{
      summary: "Film with Amy and Adam",
      start:  {{2015, 12, 24}, {8, 30, 00}},
      finish: {{2015, 12, 24}, {8, 45, 00}},
      description: "Let's go see Star Wars."
    }
    ics = %ICalendar{ events: [event] } |> ICalendar.to_ics
    assert ics == """
    BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    VERSION:2.0
    BEGIN:VEVENT
    DESCRIPTION:Let's go see Star Wars.
    SUMMARY:Film with Amy and Adam
    END:VEVENT
    END:VCALENDAR
    """
  end
end
