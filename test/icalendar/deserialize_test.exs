defmodule ICalendar.DeserializeTest do
  use ExUnit.Case

  alias ICalendar.Event

  describe "ICalendar.from_ics/1" do

    test "Single Event" do
      ics = """
      BEGIN:VEVENT
      DESCRIPTION:Escape from the world. Stare at some water.
      COMMENT:Don't forget to take something to eat !
      SUMMARY:Going fishing
      DTEND:20151224T084500Z
      DTSTART:20151224T083000Z
      LOCATION:123 Fun Street\\, Toronto ON\\, Canada
      STATUS:TENTATIVE
      CATEGORIES:Fishing,Nature
      CLASS:PRIVATE
      GEO:43.6978819;-79.3810277
      END:VEVENT
      """
      event = ICalendar.from_ics(ics)
      assert event == %Event{
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 0}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 0}}),
        summary: "Going fishing",
        description: "Escape from the world. Stare at some water.",
        location: "123 Fun Street, Toronto ON, Canada",
        status: "tentative",
        categories: ["Fishing", "Nature"],
        comment: "Don't forget to take something to eat !",
        class: "private",
        geo: {43.6978819, -79.3810277}
      }
    end

    test "with Timezone" do
      ics = """
      BEGIN:VEVENT
      DTEND;TZID=America/Chicago:22221224T084500
      DTSTART;TZID=America/Chicago:22221224T083000
      END:VEVENT
      """

      event = ICalendar.from_ics(ics)
      assert event.dtstart.time_zone == "America/Chicago"
      assert event.dtend.time_zone == "America/Chicago"
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
