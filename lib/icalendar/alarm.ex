defmodule ICalendar.Alarm do
  @moduledoc """
  Events have alarms.
  """

  defstruct minutes_before: 60
end

defimpl ICalendar.Serialize, for: ICalendar.Alarm do
  alias ICalendar.Value

  def to_ics(alarm) do
    """
    BEGIN:VALARM
    TRIGGER:-PT#{Value.to_ics( alarm.minutes_before )}M
    ACTION:DISPLAY
    DESCRIPTION:Reminder
    END:VALARM
    """
  end
end
