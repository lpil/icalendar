defmodule ICalendar.Util.DeserializeTest do
  use ExUnit.Case
  alias ICalendar.Util.Deserialize
  alias ICalendar.Event
  doctest ICalendar.Util.Deserialize

  test "Convert iCal String to event Struct" do
    event =
      """
      BEGIN:VEVENT
      DESCRIPTION:Escape from the world. Stare at some water.
      SUMMARY:Going fishing
      DTEND:20151224T084500Z
      DTSTART:20151224T083000Z
      END:VEVENT
      """
      |> String.trim()
      |> String.split("\n")
      |> Deserialize.build_event()

    assert event == %Event{
             description: "Escape from the world. Stare at some water.",
             dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 0}}),
             dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 0}}),
             location: nil,
             summary: "Going fishing"
           }
  end

  test "Handles empty calendars correctly" do
    event =
      """
      BEGIN:VEVENT
      END:VEVENT
      """
      |> String.trim()
      |> String.split("\n")
      |> Deserialize.build_event()

    assert event == %Event{
             dtstart: nil,
             dtend: nil,
             summary: nil,
             description: nil
           }
  end
end
