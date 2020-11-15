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

  @tag :skip
  test "Include ORGANIZER and ATTENDEEs in event" do
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
    assert event.organizer == "mailto:paul@clockk.com"
  end

  test "Include ORGANIZER w/ params and ATTENDEEs in event" do
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

    assert %Event{organizer: organizer} = event
    assert %{:original_value => "mailto:paul@clockk.com", "CN" => "paul@clockk.com"} = organizer
  end

  test "Convert other time zone formats to UTC" do
    event =
      """
      BEGIN:VEVENT
      DTSTART;TZID=Greenwich Standard Time:20190726T190000
      DTEND;TZID=Greenwich Standard Time:20190726T213000
      END:VEVENT
      """
      |> String.trim()
      |> String.split("\n")
      |> Deserialize.build_event()

    assert %Event{} = event
  end

  test "ignore empty param values" do
    # the X-ADDRESS param is empty here
    param = "X-APPLE-STRUCTURED-LOCATION;X-ADDRESS=;X-TITLE=Paris:geo:48.856788,2.351077"

    params = Deserialize.retrieve_params(param)

    assert params == [
             "X-APPLE-STRUCTURED-LOCATION",
             %{"X-TITLE" => "Paris:geo:48.856788,2.351077", "X-ADDRESS" => nil}
           ]
  end

  test "ignore empty lines" do
    event =
      """
      BEGIN:VEVENT
      DTSTART:20140522T150000Z
      DTEND:20140522T160000Z
      DESCRIPTION:Going to fly away
      SUMMARY:Initial Review Meeting
      BEGIN:VALARM
      ACTION:NONE

      TRIGGER;VALUE=DATE-TIME:19760401T005545Z

      X-WR-ALARMUID:12D65D6D-D3B2-439D-87F1

      UID:12D65D6D-D3B2-439D-87F1

      ACKNOWLEDGED:20140522T145005Z

      X-APPLE-DEFAULT-ALARM:TRUE

      END:VALARM
      END:VEVENT
      """
      |> String.trim()
      |> String.split("\n")
      |> Deserialize.build_event()

    assert %Event{} = event
  end

  test "include RRULE in event" do
    event =
      """
      BEGIN:VEVENT
      RRULE:FREQ=WEEKLY;BYDAY=TH
      END:VEVENT
      """
      |> String.trim()
      |> String.split("\n")
      |> Deserialize.build_event()

    assert %Event{
             rrule: %{
               byday: ["TH"],
               freq: "WEEKLY"
             }
           } = event
  end

  test "include weekly RRULE in event" do
    event =
      """
      BEGIN:VEVENT
      RRULE:FREQ=WEEKLY;BYDAY=TH
      END:VEVENT
      """
      |> String.trim()
      |> String.split("\n")
      |> Deserialize.build_event()

    assert %Event{
             rrule: %{
               byday: ["TH"],
               freq: "WEEKLY"
             }
           } = event
  end

  test "include interval RRULE in event" do
    event =
      """
      BEGIN:VEVENT
      RRULE:FREQ=WEEKLY;WKST=SU;UNTIL=20201204T045959Z;INTERVAL=2;BYDAY=TH,WE;BYSETPOS=-1
      END:VEVENT
      """
      |> String.trim()
      |> String.split("\n")
      |> Deserialize.build_event()

    assert %Event{
             rrule: %{
               byday: ["TH", "WE"],
               freq: "WEEKLY",
               bysetpos: [-1],
               interval: 2,
               until: ~U[2020-12-04 04:59:59Z]
             }
           } = event
  end

  test "include EXDATE properties as list in event" do
    event =
      """
      BEGIN:VEVENT
      EXDATE;TZID=America/Toronto:20200917T143000
      EXDATE;TZID=America/Toronto:20200916T143000
      END:VEVENT
      """
      |> String.trim()
      |> String.split("\n")
      |> Deserialize.build_event()

    dt1 = Timex.Timezone.convert(~U[2020-09-16 18:30:00Z], "America/Toronto")
    dt2 = Timex.Timezone.convert(~U[2020-09-17 18:30:00Z], "America/Toronto")

    assert %Event{
             exdates: [
               ^dt1,
               ^dt2
             ]
           } = event
  end
end
