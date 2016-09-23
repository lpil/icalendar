defmodule ICalendar.DeserializeTest do
  use ExUnit.Case

  alias ICalendar.Event

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
      dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 0}}),
      dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 0}}),
      summary: "Going fishing",
      description: "Escape from the world. Stare at some water."
    }
  end
end
