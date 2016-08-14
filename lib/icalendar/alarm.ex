defmodule ICalendar.Alarm do
  @moduledoc """
  Events have alarms.
  """

  defstruct minutes_before: 60
end

defimpl ICalendar.Serialize, for: ICalendar.Alarm do
  alias ICalendar.Value

  def to_ics(alarm) do
    minutes = alarm.minutes_before |> abs |> Value.to_ics
    """
    BEGIN:VALARM
    TRIGGER:-PT#{minutes}M
    ACTION:DISPLAY
    DESCRIPTION:Reminder
    END:VALARM
    """
  end
end
