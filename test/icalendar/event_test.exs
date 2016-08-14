defmodule ICalendar.EventTest do
  use ExUnit.Case

  alias ICalendar.Event
  alias ICalendar.Alarm

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

  test "ICalendar.to_ics/1 with start and end" do
    ics = %Event{
      dtstart: {{2015, 12, 24}, {8, 30, 00}},
      dtend:   {{2015, 12, 24}, {8, 45, 00}},
    } |> ICalendar.to_ics
    assert ics == """
    BEGIN:VEVENT
    DTEND:20151224T084500Z
    DTSTART:20151224T083000Z
    END:VEVENT
    """
  end

  test "ICalendar.to_ics/1 with alarms" do
    alarm = %Alarm{minutes_before: 23}
    ics = %Event{
      dtstart: {{2015, 12, 24}, {8, 30, 00}},
      dtend:   {{2015, 12, 24}, {8, 45, 00}},
      alarms:  [alarm]
    } |> ICalendar.to_ics
    assert ics == """
    BEGIN:VEVENT
    BEGIN:VALARM
    TRIGGER:-PT23M
    ACTION:DISPLAY
    DESCRIPTION:Reminder
    END:VALARM
    DTEND:20151224T084500Z
    DTSTART:20151224T083000Z
    END:VEVENT
    """
  end
end
