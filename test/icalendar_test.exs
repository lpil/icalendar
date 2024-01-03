defmodule ICalendarTest do
  use ExUnit.Case

  @vendor "ICalendar Test"

  test "ICalendar.to_ics/1 of empty calendar" do
    ics = %ICalendar{} |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Elixir ICalendar//Elixir ICalendar//EN
           END:VCALENDAR
           """
  end

  test "ICalendar.to_ics/1 of empty calendar with custom vendor" do
    ics = %ICalendar{} |> ICalendar.to_ics(vendor: @vendor)

    assert ics == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Elixir ICalendar//#{@vendor}//EN
           END:VCALENDAR
           """
  end

  test "ICalendar.to_ics/1 of a calendar with an event, as in README" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "Let's go see Star Wars."
      },
      %ICalendar.Event{
        summary: "Morning meeting",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {19, 00, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {22, 30, 00}}),
        description: "A big long meeting with lots of details."
      }
    ]

    ics = %ICalendar{events: events} |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Elixir ICalendar//Elixir ICalendar//EN
           BEGIN:VEVENT
           DESCRIPTION:Let's go see Star Wars.
           DTEND:20151224T084500Z
           DTSTART:20151224T083000Z
           SUMMARY:Film with Amy and Adam
           END:VEVENT
           BEGIN:VEVENT
           DESCRIPTION:A big long meeting with lots of details.
           DTEND:20151224T223000Z
           DTSTART:20151224T190000Z
           SUMMARY:Morning meeting
           END:VEVENT
           END:VCALENDAR
           """
  end

  test "Icalender.to_ics/1 with location and sanitization" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "Let's go see Star Wars, and have fun.",
        location: "123 Fun Street, Toronto ON, Canada"
      }
    ]

    ics = %ICalendar{events: events} |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Elixir ICalendar//Elixir ICalendar//EN
           BEGIN:VEVENT
           DESCRIPTION:Let's go see Star Wars\\, and have fun.
           DTEND:20151224T084500Z
           DTSTART:20151224T083000Z
           LOCATION:123 Fun Street\\, Toronto ON\\, Canada
           SUMMARY:Film with Amy and Adam
           END:VEVENT
           END:VCALENDAR
           """
  end

  test "Icalender.to_ics/1 with url" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "Let's go see Star Wars, and have fun.",
        location: "123 Fun Street, Toronto ON, Canada",
        url: "http://example.com"
      }
    ]

    ics = %ICalendar{events: events} |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Elixir ICalendar//Elixir ICalendar//EN
           BEGIN:VEVENT
           DESCRIPTION:Let's go see Star Wars\\, and have fun.
           DTEND:20151224T084500Z
           DTSTART:20151224T083000Z
           LOCATION:123 Fun Street\\, Toronto ON\\, Canada
           SUMMARY:Film with Amy and Adam
           URL:http://example.com
           END:VEVENT
           END:VCALENDAR
           """
  end

  test "Icalender.to_ics/1 with rrule and exdates" do
    events = [
      %ICalendar.Event{
        rrule: %{
          byday: ["TH", "WE"],
          freq: "WEEKLY",
          bysetpos: [-1],
          interval: -2,
          until: ~U[2020-12-04 04:59:59Z]
        },
        exdates: [
          Timex.Timezone.convert(~U[2020-09-16 18:30:00Z], "America/Toronto"),
          Timex.Timezone.convert(~U[2020-09-17 18:30:00Z], "America/Toronto")
        ]
      }
    ]

    ics =
      %ICalendar{events: events}
      |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Elixir ICalendar//Elixir ICalendar//EN
           BEGIN:VEVENT
           EXDATE;TZID=America/Toronto:20200916T143000
           EXDATE;TZID=America/Toronto:20200917T143000
           RRULE:FREQ=WEEKLY;BYDAY=TH,WE;BYSETPOS=-1;INTERVAL=-2;UNTIL=20201204T045959
           END:VEVENT
           END:VCALENDAR
           """
  end

  test "ICalender.to_ics/1 -> ICalendar.from_ics/1 and back again" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "Let's go see Star Wars, and have fun.",
        location: "123 Fun Street, Toronto ON, Canada",
        url: "http://www.example.com"
      }
    ]

    [new_event] =
      %ICalendar{events: events}
      |> ICalendar.to_ics(vendor: @vendor)
      |> ICalendar.from_ics()

    assert events |> List.first() == new_event
  end

  test "ICalender.to_ics/1 -> ICalendar.from_ics/1 and back again, with newlines" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "First line\nThis is a new line\n\nDouble newline",
        location: "123 Fun Street, Toronto ON, Canada",
        url: "http://www.example.com"
      }
    ]

    [new_event] =
      %ICalendar{events: events}
      |> ICalendar.to_ics(vendor: @vendor)
      |> ICalendar.from_ics()

    assert events |> List.first() == new_event
  end

  test "encode_to_iodata/2" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "Let's go see Star Wars."
      },
      %ICalendar.Event{
        summary: "Morning meeting",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {19, 00, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {22, 30, 00}}),
        description: "A big long meeting with lots of details."
      }
    ]

    cal = %ICalendar{events: events}

    assert {:ok, ical} = ICalendar.encode_to_iodata(cal, [])

    assert ical == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Elixir ICalendar//Elixir ICalendar//EN
           BEGIN:VEVENT
           DESCRIPTION:Let's go see Star Wars.
           DTEND:20151224T084500Z
           DTSTART:20151224T083000Z
           SUMMARY:Film with Amy and Adam
           END:VEVENT
           BEGIN:VEVENT
           DESCRIPTION:A big long meeting with lots of details.
           DTEND:20151224T223000Z
           DTSTART:20151224T190000Z
           SUMMARY:Morning meeting
           END:VEVENT
           END:VCALENDAR
           """
  end

  test "encode_to_iodata/1" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "Let's go see Star Wars."
      },
      %ICalendar.Event{
        summary: "Morning meeting",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {19, 00, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {22, 30, 00}}),
        description: "A big long meeting with lots of details."
      }
    ]

    cal = %ICalendar{events: events}

    assert {:ok, ical} = ICalendar.encode_to_iodata(cal)

    assert ical == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Elixir ICalendar//Elixir ICalendar//EN
           BEGIN:VEVENT
           DESCRIPTION:Let's go see Star Wars.
           DTEND:20151224T084500Z
           DTSTART:20151224T083000Z
           SUMMARY:Film with Amy and Adam
           END:VEVENT
           BEGIN:VEVENT
           DESCRIPTION:A big long meeting with lots of details.
           DTEND:20151224T223000Z
           DTSTART:20151224T190000Z
           SUMMARY:Morning meeting
           END:VEVENT
           END:VCALENDAR
           """
  end

  test "Icalender.from_ics/1 with multiple exdate values" do
    ics = """
    BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    VERSION:2.0
    PRODID:-//Elixir ICalendar//Elixir ICalendar//EN
    BEGIN:VEVENT
    EXDATE;TZID=Eastern Standard Time:20231108T083000,20231220T083000
    EXDATE;TZID=Eastern Standard Time:20231115T083000
    EXDATE:19960402T010000Z,19960403T010000Z,19960404T010000Z
    RRULE:FREQ=WEEKLY;BYDAY=TH,WE;BYSETPOS=-1;INTERVAL=-2;UNTIL=20201204T045959
    END:VEVENT
    END:VCALENDAR
    """

    assert ICalendar.from_ics(ics) == [
             %ICalendar.Event{
               rrule: %{
                 byday: ["TH", "WE"],
                 freq: "WEEKLY",
                 bysetpos: [-1],
                 interval: -2,
                 until: ~U[2020-12-04 04:59:59Z]
               },
               exdates: [
                 ~U[1996-04-04 01:00:00Z],
                 ~U[1996-04-03 01:00:00Z],
                 ~U[1996-04-02 01:00:00Z],
                 Timex.Timezone.convert(~U[2023-11-15 13:30:00Z], "America/New_York"),
                 Timex.Timezone.convert(~U[2023-12-20 13:30:00Z], "America/New_York"),
                 Timex.Timezone.convert(~U[2023-11-08 13:30:00Z], "America/New_York")
               ]
             }
           ]
  end
end
