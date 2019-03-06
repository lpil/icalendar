defmodule ICalendar.Property do
  @moduledoc """
  Provide structure to define properties of an Event
  """

  defstruct key: nil,
            value: nil,
            params: %{}
end
