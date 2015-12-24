defmodule ICalendar do
  @moduledoc """
  Generating ICalendars
  """

  defstruct events: []
  defdelegate to_ics(events), to: ICalendar.Serialize
end

defimpl ICalendar.Serialize, for: ICalendar do
  def to_ics(_calendar) do
  """
  BEGIN:VCALENDAR
  CALSCALE:GREGORIAN
  VERSION:2.0
  END:VCALENDAR
  """
  end
end
