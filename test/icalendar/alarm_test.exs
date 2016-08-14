defmodule ICalendar.AlarmTest do
  use ExUnit.Case

  alias ICalendar.Alarm

  test "Alarm.to_ics/1 with time trigger in minutes before" do
    ics = %Alarm{minutes_before: 5} |> ICalendar.to_ics
    assert ics == """
    BEGIN:VALARM
    TRIGGER:-PT5M
    ACTION:DISPLAY
    DESCRIPTION:Reminder
    END:VALARM
    """
  end
end
