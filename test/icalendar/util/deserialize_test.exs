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

    assert %Event{} = event
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

  test "Include ORGANIZER in event" do
    event =
      """
      BEGIN:VEVENT
      DTSTART:20190711T130000Z
      DTEND:20190711T150000Z
      DTSTAMP:20190719T195201Z
      ORGANIZER;CN=paul@clockk.com:mailto:paul@clockk.com
      UID:7E212264-C604-4071-892B-E0A28048F1BA
      ATTENDEE;CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;CN=eric@clockk.com;X-NUM-GUESTS=0:mailto:eric@clockk.com
      ATTENDEE;CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;CN=paul@clockk.com;X-NUM-GUESTS=0:mailto:paul@clockk.com
      ATTENDEE;CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;CN=James SM;X-NUM-GUESTS=0:mailto:james@clockk.com
      CREATED:20190709T192336Z
      DESCRIPTION:
      LAST-MODIFIED:20190711T130843Z
      LOCATION:In-person at Volta and https://zoom.us/j/12345678
      SEQUENCE:0
      STATUS:CONFIRMED
      SUMMARY:Design session
      END:VEVENT
      """
      |> String.trim()
      |> String.split("\n")
      |> Deserialize.build_event()

      assert %Event{} = event
  end
end
