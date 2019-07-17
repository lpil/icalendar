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

  test "Handles date strings" do
    event =
      """
      BEGIN:VEVENT
      DTSTART;VALUE=DATE:20190624
      DTEND;VALUE=DATE:20190625
      END:VEVENT
      """
      |> String.trim()
      |> String.split("\n")
      |> Deserialize.build_event()

    assert event == %Event{
             dtend: ~N[2019-06-25 00:00:00],
             dtstart: ~N[2019-06-24 00:00:00]
           }
  end

  test "Handle empty keys" do
    event =
      """
      BEGIN:VEVENT
      DESCRIPTION:
      END:VEVENT
      """
      |> String.trim()
      |> String.split("\n")
      |> Deserialize.build_event()

    assert %Event{} = event
  end
end
