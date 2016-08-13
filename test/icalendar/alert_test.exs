defmodule ICalendar.AlertTest do
  use ExUnit.Case

  alias ICalendar.Alert

  test "Alert.to_ics/1 with time trigger in minutes before" do
    ics = %Alert{minutes_before: 5} |> ICalendar.to_ics
    assert ics == """
    BEGIN:VALARM
    TRIGGER:-PT5M
    ACTION:DISPLAY
    DESCRIPTION:Reminder
    END:VALARM
    """
  end
end
