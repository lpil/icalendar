defmodule ICalendarTest do
  use ExUnit.Case

  test "ICalendar.to_ics/1 of empty calendar" do
    ics = %ICalendar{} |> ICalendar.to_ics
    assert ics == """
    BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    VERSION:2.0
    END:VCALENDAR
    """
  end
end
