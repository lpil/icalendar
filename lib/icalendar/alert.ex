defmodule ICalendar.Alert do
  @moduledoc """
  Events have alerts.
  """

  defstruct minutes_before: 60
end

defimpl ICalendar.Serialize, for: ICalendar.Alert do
  alias ICalendar.Value

  def to_ics(alert) do
    """
    BEGIN:VALARM
    TRIGGER:-PT#{Value.to_ics( alert.minutes_before )}M
    ACTION:DISPLAY
    DESCRIPTION:Reminder
    END:VALARM
    """
  end
end
