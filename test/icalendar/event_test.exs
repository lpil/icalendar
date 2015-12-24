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

  test "ICalendar.to_ics/1 of with summary" do
    ics = %Event{ summary: "Going fishing" } |> ICalendar.to_ics
    assert ics == """
    BEGIN:VEVENT
    SUMMARY:Going fishing
    END:VEVENT
    """
  end
end
