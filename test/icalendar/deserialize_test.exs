defmodule ICalendar.DeserializeTest do
  use ExUnit.Case

  alias ICalendar.Event

  describe "ICalendar.from_ics/1" do

    test "Single Event" do
      ics = """
      BEGIN:VEVENT
      DESCRIPTION:Escape from the world. Stare at some water.
      SUMMARY:Going fishing
      DTEND:20151224T084500Z
      DTSTART:20151224T083000Z
      LOCATION:123 Fun Street\\, Toronto ON\\, Canada
      END:VEVENT
      """
      event = ICalendar.from_ics(ics)
      assert event == {:ok, %Event{
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 0}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 0}}),
        summary: "Going fishing",
        description: "Escape from the world. Stare at some water.",
        location: "123 Fun Street, Toronto ON, Canada"
      }}
    end

    test "Bad parameter returns {:error, _}" do
      bad_ics = """
      BEGIN:VEVENT
      DTSTART:XXXXXXXXXXXXXXXX
      END:VEVENT
      """
      event = ICalendar.from_ics(bad_ics)
      assert event ==
        {:error, ["DTSTART: Expected `1-4 digit year` at line 1, column 1."]}
    end

    test "with Timezone" do
      ics = """
      BEGIN:VEVENT
      DTEND;TZID=America/Chicago:22221224T084500
      DTSTART;TZID=America/Chicago:22221224T083000
      END:VEVENT
      """

      {:ok, event} = ICalendar.from_ics(ics)
      assert event.dtstart.time_zone == "America/Chicago"
      assert event.dtend.time_zone == "America/Chicago"
    end
    
    test "with RRULE" do
      rrule = [
        "FREQ=DAILY",
        "UNTIL=22221224T084500Z",
        "BYMONTHDAY=1,3,5",
        "BYDAY=TU,FR",
        "BYMONTH=4"
      ] |> Enum.join(";")

      ics = """
      BEGIN:VEVENT
      RRULE:#{rrule}
      END:VEVENT
      """

      {:ok, event} = ICalendar.from_ics(ics)
      assert event.rrule.by_day == [:tuesday, :friday]
      assert event.rrule.by_month == [:april]
      assert event.rrule.by_month_day == [1, 3, 5]
      assert event.rrule.frequency == :daily
      assert event.rrule.until ==
        Timex.to_datetime({{2222, 12, 24}, {8, 45, 0}}, "Etc/UTC")
    end

    test "with CR+LF line endings" do
      ics = """
      DESCRIPTION:CR+LF line endings\r\nSUMMARY:Going fishing\r
      DTEND:20151224T084500Z\r\nDTSTART:20151224T083000Z\r
      END:VEVENT
      """

      event = ICalendar.from_ics(ics)
      assert event.description == "CR+LF line endings"
    end
  end
end
