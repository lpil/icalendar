defmodule ICalendar.Util.RRULE do

  def serialize(rrule, keys, key) do
    case Map.fetch(rrule, key) do
      {:ok, value} ->
        serialized_key   = serialize_key(key, keys)
        serialized_value = serialize_value(key, value)
        cond do
          is_bitstring(serialized_key) && is_bitstring(serialized_value) ->
            "#{serialized_key}=#{serialized_value}"
          true -> nil
        end
      :error -> nil
    end
  end

  def serialize_value(:frequency, value) when is_atom(value) do
    frequencies = ICalendar.RRULE.frequencies(:inverted)
    case Map.fetch(frequencies, value) do
      {:ok, freq} -> freq
      :error      -> nil
    end
  end
  def serialize_value(:count, value), do: value
  def serialize_value(:until, value), do: ICalendar.Value.to_ics(value)
  def serialize_value(:interval, value), do: value
  def serialize_value(:by_second, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> Enum.join(value, ",")
    end
  end
  def serialize_value(:by_minute, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> Enum.join(value, ",")
    end
  end
  def serialize_value(:by_hour, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> Enum.join(value, ",")
    end
  end
  def serialize_value(:by_day, value) when is_list(value) do
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
  def serialize_value(:by_month, value) when is_list(value) do
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
  def serialize_value(:by_month_day, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> Enum.join(value, ",")
    end
  end
  def serialize_value(:by_year_day, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> Enum.join(value, ",")
    end
  end
  def serialize_value(:by_week_number, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> Enum.join(value, ",")
    end
  end
  def serialize_value(:by_set_pos, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> Enum.join(value, ",")
    end
  end
  def serialize_value(:week_start, value) when is_atom(value) do
    days = ICalendar.RRULE.days(:inverted)
    case Map.fetch(days, value) do
      {:ok, day} -> day
      :error     -> nil
    end
  end
  def serialize_value(_, val), do: val

  def serialize_key(key, keys) do
    case Map.fetch(keys, key) do
      {:ok, new_key} -> new_key
      :error -> nil
    end
  end
end
