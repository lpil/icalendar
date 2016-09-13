defmodule ICalendar.DeserializeTest do
  use ExUnit.Case

  alias ICalendar.Event

  test "ICalendar.from_ics/1 with empty icalendar string" do
    ics = """
    BEGIN:VEVENT
    END:VEVENT
    """
    assert ICalendar.from_ics(ics) == %Event{
      dtstart: nil,
      dtend: nil,
      summary: nil,
      description: nil
    }
  end

  test "ICalendar.from_ics/1" do
    ics = """
    BEGIN:VEVENT
    DESCRIPTION:Escape from the world. Stare at some water.
    SUMMARY:Going fishing
    DTEND:20151224T084500Z
    DTSTART:20151224T083000Z
    END:VEVENT
    """
    event = ICalendar.from_ics(ics)
    assert event == %Event{
      dtstart: {{2015, 12, 24}, {8, 30, 00}},
      dtend: {{2015, 12, 24}, {8, 45, 00}}, 
      summary: "Going fishing",
      description: "Escape from the world. Stare at some water."
    }
  end

end
