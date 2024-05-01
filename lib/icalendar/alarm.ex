defmodule ICalendar.Alarm do
  @moduledoc """
  Provide structure to define alarms of an Event.
  """
  defstruct trigger: nil,
            repeat: nil,
            duration: nil,
            action: nil,
            description: nil,
            attachments: [],
            attendees: []

  @type t :: %__MODULE__{
          trigger: String.t() | map(),
          repeat: integer(),
          duration: String.t(),
          action: String.t(),
          description: String.t(),
          attachments: list(map),
          attendees: list(map)
        }
end

defimpl ICalendar.Serialize, for: ICalendar.Alarm do
  alias ICalendar.Util.KV

  def to_ics(alarm, _options \\ []) do
    contents = to_kvs(alarm)

    """
    BEGIN:VALARM
    #{contents}END:VALARM
    """
  end

  defp to_kvs(alarm) do
    alarm
    |> Map.from_struct()
    |> Enum.map(&to_kv/1)
    |> List.flatten()
    |> Enum.sort()
    |> Enum.join()
  end

  defp to_kv({key, value}) do
    name = key |> to_string |> String.upcase()
    KV.build(name, value)
  end
end
