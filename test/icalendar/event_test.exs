defmodule ICalendar.EventTest do
  use ExUnit.Case

  alias ICalendar.Event

  test "ICalendar.to_ics/1 of event" do
    ics = %Event{} |> ICalendar.to_ics
    assert ics == """
    BEGIN:VEVENT
    END:VEVENT
    """
  end

  test "ICalendar.to_ics/1 with some attributes" do
    ics = %Event{
      summary:     "Going fishing",
      description: "Escape from the world. Stare at some water.",
    } |> ICalendar.to_ics
    assert ics == """
    BEGIN:VEVENT
    DESCRIPTION:Escape from the world. Stare at some water.
    SUMMARY:Going fishing
    END:VEVENT
    """
  end

  test "ICalendar.to_ics/1 with date start and end" do
    ics = %Event{
      dtstart: Timex.to_date({2015, 12, 24}),
      dtend:   Timex.to_date({2015, 12, 24}),
    } |> ICalendar.to_ics
    assert ics == """
    BEGIN:VEVENT
    DTEND:20151224
    DTSTART:20151224
    END:VEVENT
    """
  end

  test "ICalendar.to_ics/1 with datetime start and end" do
    ics = %Event{
      dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
      dtend:   Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
    } |> ICalendar.to_ics
    assert ics == """
    BEGIN:VEVENT
    DTEND;TZID=Etc/UTC:20151224T084500
    DTSTART;TZID=Etc/UTC:20151224T083000
    END:VEVENT
    """
  end

  test "ICalendar.to_ics/1 with datetime with timezone" do
    dtstart =
      {{2015, 12, 24}, {8, 30, 00}}
      |> Timex.to_datetime("America/Chicago")

    dtend =
      {{2015, 12, 24}, {8, 45, 00}}
      |> Timex.to_datetime("America/Chicago")

    ics =
      %Event{dtstart: dtstart, dtend: dtend}
      |> ICalendar.to_ics

    assert ics == """
    BEGIN:VEVENT
    DTEND;TZID=America/Chicago:20151224T084500
    DTSTART;TZID=America/Chicago:20151224T083000
    END:VEVENT
    """
  end

  test "ICalendar.to_ics/1 does not damage url in description" do
    ics = %Event{
      summary:     "Going fishing",
      description: "See this link http://example.com/pub" <>
                   "/calendars/jsmith/mytime.ics",
    } |> ICalendar.to_ics
    assert ics == """
    BEGIN:VEVENT
    DESCRIPTION:See this link http://example.com/pub/calendars/jsmith/mytime.ics
    SUMMARY:Going fishing
    END:VEVENT
    """
  end

  test "ICalendar.to_ics/1 with url" do
    ics = %Event{
      url: "http://example.com/pub/calendars/jsmith/mytime.ics"
    } |> ICalendar.to_ics
    assert ics == """
    BEGIN:VEVENT
    URL:http://example.com/pub/calendars/jsmith/mytime.ics
    END:VEVENT
    """
  end
end
