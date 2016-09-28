defprotocol ICalendar.Value do
  @fallback_to_any true
  def to_ics(data)
end

alias ICalendar.Value

defimpl Value, for: ICalendar.RRULE do
  @doc """
  This function converts RRULE structs into an RRULE string
  """
  def to_ics(rrule = %ICalendar.RRULE{}) do
    keys = ICalendar.RRULE.string_to_atom_keys(:inverted)

    rrule
    |> Map.from_struct
    |> Map.keys
    |> Enum.map(fn (key) ->
      case Map.fetch(rrule, key) do
        {:ok, value} ->
          serialized_key = new_key(key, keys)
          serialized_value = serialize(key, value)
          cond do
            is_bitstring(serialized_key) && is_bitstring(serialized_value) ->
              "#{serialized_key}=#{serialized_value}"
            true -> nil
          end
        :error -> nil
      end
    end)
    |> Enum.reject(&(&1 == nil))
    |> Enum.join(";")
  end

  defp new_key(key, keys) do
    case Map.fetch(keys, key) do
      {:ok, new_key} -> new_key
      :error -> nil
    end
  end

  defp serialize(:frequency, value) when is_atom(value) do
    frequencies = ICalendar.RRULE.frequencies(:inverted)
    case Map.fetch(frequencies, value) do
      {:ok, freq} -> freq
      :error      -> nil
    end
  end
  defp serialize(:count, value), do: value
  defp serialize(:until, value), do: ICalendar.Value.to_ics(value)
  defp serialize(:interval, value), do: value
  defp serialize(:by_second, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> Enum.join(value, ",")
    end
  end
  defp serialize(:by_minute, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> Enum.join(value, ",")
    end
  end
  defp serialize(:by_hour, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> Enum.join(value, ",")
    end
  end
  defp serialize(:by_day, value) when is_list(value) do
    days = ICalendar.RRULE.days(:inverted)
    case Enum.count(value) do
      0 -> nil
      _ ->
        value
        |> Enum.map(fn(val) ->
          case Map.fetch(days, val) do
            {:ok, day} -> day
            :error     -> nil
          end
        end)
        |> Enum.join(",")
    end
  end
  defp serialize(:by_month, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ ->
        value
        |> Enum.map(fn(val) ->
          # Retrieve the index of the months array then add one
          Enum.find_index(ICalendar.RRULE.months, &(&1 == val)) + 1
        end)
        |> Enum.join(",")
    end
  end
  defp serialize(:by_month_day, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> Enum.join(value, ",")
    end
  end
  defp serialize(:by_year_day, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> Enum.join(value, ",")
    end
  end
  defp serialize(:by_week_number, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> Enum.join(value, ",")
    end
  end
  defp serialize(:by_set_pos, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> Enum.join(value, ",")
    end
  end
  defp serialize(:week_start, value) when is_atom(value) do
    days = ICalendar.RRULE.days(:inverted)
    case Map.fetch(days, value) do
      {:ok, day} -> day
      :error     -> nil
    end
  end
  defp serialize(_, val), do: val
end

defimpl Value, for: BitString do
  def to_ics(x) do
    x
    |> String.replace(~S"\n", ~S"\\n")
    |> String.replace("\n", ~S"\n")
  end
end

defimpl Value, for: Tuple do
  defmacro elem2(x, i1, i2) do
    quote do
      unquote(x) |> elem(unquote(i1)) |> elem(unquote(i2))
    end
  end

  @doc """
  This macro is used to establish whether a tuple is in the Erlang Timestamp
  format (`{{year, month, day}, {hour, minute, second}}`).
  """
  defmacro is_datetime_tuple(x) do
    quote do
      # Year
      ( unquote(x) |> elem2(0, 0)  |> is_integer) and
      # Month
      ( unquote(x) |> elem2(0, 1)  |> is_integer) and
      ((unquote(x) |> elem2(0, 1)) <= 12) and
      ((unquote(x) |> elem2(0, 1)) >= 1) and
      # Day
      ( unquote(x) |> elem2(0, 2)  |> is_integer) and
      ((unquote(x) |> elem2(0, 2)) <= 31) and
      ((unquote(x) |> elem2(0, 2)) >= 1) and
      # Hour
      ( unquote(x) |> elem2(1, 0)  |> is_integer) and
      ((unquote(x) |> elem2(1, 0)) <= 23) and
      ((unquote(x) |> elem2(1, 0)) >= 0) and
      # Minute
      ( unquote(x) |> elem2(1, 1)  |> is_integer) and
      ((unquote(x) |> elem2(1, 1)) <= 59) and
      ((unquote(x) |> elem2(1, 1)) >= 0) and
      # Second
      ( unquote(x) |> elem2(1, 2)  |> is_integer) and
      ((unquote(x) |> elem2(1, 2)) <= 60) and
      ((unquote(x) |> elem2(1, 2)) >= 0)
    end
  end

  @doc """
  This function converts Erlang timestamp tuples into DateTimes.
  """
  def to_ics(timestamp) when is_datetime_tuple(timestamp) do
    timestamp
    |> Timex.to_datetime
    |> Value.to_ics
  end

  def to_ics(x), do: x

end

defimpl Value, for: DateTime do
  use Timex

  @doc """
  This function converts DateTimes to UTC timezone and then into Strings in the
  iCal format
  """
  def to_ics(%DateTime{} = timestamp) do
    format_string = "{YYYY}{0M}{0D}T{h24}{m}{s}"

    {:ok, result} =
      timestamp
      |> Timex.format(format_string)
    result
  end
end

defimpl Value, for: Any do
  def to_ics(x), do: x
end
