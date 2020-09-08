defmodule ICalendar.RecurrenceTest do
  use ExUnit.Case

  test "daily reccuring event with until" do
    events =
      """
      BEGIN:VCALENDAR
      CALSCALE:GREGORIAN
      VERSION:2.0
      BEGIN:VEVENT
      RRULE:FREQ=DAILY;UNTIL=20151231T083000Z
      DESCRIPTION:Let's go see Star Wars.
      DTEND:20151224T084500Z
      DTSTART:20151224T083000Z
      SUMMARY:Film with Amy and Adam
      END:VEVENT
      END:VCALENDAR
      """
      |> ICalendar.from_ics()
      |> ICalendar.Recurrence.add_recurring_events()

    assert events |> Enum.count() == 8

    [event | events] = events
    assert event.dtstart == ~U[2015-12-24 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2015-12-25 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2015-12-26 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2015-12-27 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2015-12-28 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2015-12-29 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2015-12-30 08:30:00Z]
    [event] = events
    assert event.dtstart == ~U[2015-12-31 08:30:00Z]
  end

  test "monthly reccuring event with until" do
    events =
      """
      BEGIN:VCALENDAR
      CALSCALE:GREGORIAN
      VERSION:2.0
      BEGIN:VEVENT
      RRULE:FREQ=MONTHLY;UNTIL=20160624T083000Z
      DESCRIPTION:Let's go see Star Wars.
      DTEND:20151224T084500Z
      DTSTART:20151224T083000Z
      SUMMARY:Film with Amy and Adam
      END:VEVENT
      END:VCALENDAR
      """
      |> ICalendar.from_ics()
      |> ICalendar.Recurrence.add_recurring_events()

    assert events |> Enum.count() == 7

    [event | events] = events
    assert event.dtstart == ~U[2015-12-24 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2016-01-24 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2016-02-24 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2016-03-24 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2016-04-24 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2016-05-24 08:30:00Z]
    [event] = events
    assert event.dtstart == ~U[2016-06-24 08:30:00Z]
  end

  test "weekly reccuring event with until" do
    events =
      """
      BEGIN:VCALENDAR
      CALSCALE:GREGORIAN
      VERSION:2.0
      BEGIN:VEVENT
      RRULE:FREQ=WEEKLY;UNTIL=20160201T083000Z
      DESCRIPTION:Let's go see Star Wars.
      DTEND:20151224T084500Z
      DTSTART:20151224T083000Z
      SUMMARY:Film with Amy and Adam
      END:VEVENT
      END:VCALENDAR
      """
      |> ICalendar.from_ics()
      |> ICalendar.Recurrence.add_recurring_events()

    assert events |> Enum.count() == 6

    [event | events] = events
    assert event.dtstart == ~U[2015-12-24 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2015-12-31 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2016-01-07 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2016-01-14 08:30:00Z]
    [event | events] = events
    assert event.dtstart == ~U[2016-01-21 08:30:00Z]
    [event] = events
    assert event.dtstart == ~U[2016-01-28 08:30:00Z]
  end
end
