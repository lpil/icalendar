defmodule ICalendar do
  @moduledoc """
  Generating ICalendars
  """

  defstruct events: []
  defdelegate to_ics(events), to: ICalendar.Serialize
end

defimpl ICalendar.Serialize, for: ICalendar do
  def to_ics(calendar) do
  events = Enum.map( calendar.events, &ICalendar.Serialize.to_ics/1 )
  """
  BEGIN:VCALENDAR
  CALSCALE:GREGORIAN
  VERSION:2.0
  #{events}END:VCALENDAR
  """
  end
end
