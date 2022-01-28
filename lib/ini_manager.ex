defmodule AmpsLib.IniManager do
  @moduledoc """
  Documentation for `AmpsLib.IniManager`.
  """

  @doc """
  Load contents from INI File

  ## Examples

      iex> AmpsLib.load_ini(filename)
      returns map

  """
  def load_ini(filename) do
    {:ok, data} = File.read filename
    parse_ini(data)
  end

  @doc """
  Decode ini file contents as MAP.

  ## Examples

      iex> AmpsLib.IniManager.decode(data)
      returns map

  """
  def parse_ini(data) do
    # Filter out the garbage rows ; \n ""
    data =
      String.split(data, ~r/[\r\n]+/)
      |> Enum.filter(fn line ->
        !Regex.match?(~r/^\s*[;]/, line) and line != ""
      end)

    # Parse the remaining lines with that sick ini regex
    ini_regex = ~r/^\[([^\]]*)\]$|^([^=]+)(=(.*))?$/i

    data =
      Enum.map(data, fn line ->
        [matches | _rest] = Regex.scan(ini_regex, line)
        matches
      end)
    {output, _level} =
      Enum.reduce(data, {%{}, 0}, fn line, {output, level} ->
        case {line, level} do
          {[_, "", key, _, value], 0} ->
            # If it has [] we need to insert
            output =
              if String.match?(key, ~r/\[\]/) do
                key = key |> String.trim() |> String.replace("[]", "") |> String.to_atom()
                value = value |> String.trim()

                Map.update(output, key, [], fn v ->
                  v ++ [value]
                end)
              else
                # This is a new field that isn't a list
                key = key |> String.trim() |> String.to_atom()
                value = value |> String.trim()

                Map.put(output, key, value)
              end

            {output, level}

          {[_, "", key, _, value], level} ->
            output =
              if String.match?(key, ~r/\[\]/) do
                key = key |> String.trim() |> String.replace("[]", "") |> String.to_atom()
                value = value |> String.trim()

                update_in(output[level], fn map ->
                  Map.update(map, key, [value], fn v ->
                    v ++ [value]
                  end)
                end)
              else
                # This is a new field that isn't a list
                key = key |> String.trim() |> String.to_atom()
                value = value |> String.trim()

                update_in(output[level], &Map.put(&1, key, value))
              end

            {output, level}

          {[_, header], _} ->
            key = String.to_atom(header)
            {Map.put(output, key, %{}), key}

          _ ->
            {output, level}
        end
      end)
    output
  end
end
