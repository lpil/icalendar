defmodule ICalendar.Timezone do
  @moduledoc """
  BEGIN:VTIMEZONE
  TZID:America/New_York
  BEGIN:STANDARD
  DTSTART:19040101T000000
  TZOFFSETFROM:-0500
  TZOFFSETTO:-0400
  TZNAME:EDT
  END:STANDARD
  BEGIN:DAYLIGHT
  DTSTART:19040101T000000
  TZOFFSETFROM:-0400
  TZOFFSETTO:-0500
  TZNAME:EST
  END:DAYLIGHT
  END:VTIMEZONE
  """

  defstruct tzid: nil,
            tzoffsetfrom: nil,
            tzoffsetto: nil,
            tzname: nil,
            standard: nil,
            daylight: nil

  @type t :: %__MODULE__{
          tzid: String.t(),
          tzoffsetfrom: String.t(),
          tzoffsetto: String.t(),
          tzname: String.t(),
          standard: ICalendar.Timezone.Standard.t(),
          daylight: ICalendar.Timezone.Daylight.t()
        }

  defimpl ICalendar.Serialize, for: ICalendar.Timezone do
    alias ICalendar.Util.KV

    def to_ics(%ICalendar.Timezone{} = tz, options \\ []) do
      standard = if tz.standard, do: ICalendar.Serialize.to_ics(tz.standard, options), else: ""
      daylight = if tz.daylight, do: ICalendar.Serialize.to_ics(tz.daylight, options), else: ""

      contents =
        ICalendar.Timezone
        |> struct(tz |> Map.from_struct())
        |> Map.drop([:standard, :daylight])
        |> to_kvs()
        |> Kernel.<>(standard)
        |> Kernel.<>(daylight)

      """
      BEGIN:VTIMEZONE
      #{contents}END:VTIMEZONE
      """
    end

    defp to_kvs(tz) do
      tz
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
end
