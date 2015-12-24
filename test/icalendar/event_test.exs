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

  test "ICalendar.to_ics/1 of with some attributes" do
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
end
