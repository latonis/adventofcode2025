defmodule Grid do
  def print(grid) do
    Enum.each(grid, fn row ->
      row_string = Enum.map_join(row, "", &to_string/1)
      IO.puts(row_string)
    end)

    IO.puts("\n")
  end
end

input = File.stream!("input")

input
|> Stream.map(&String.trim/1)
|> Stream.map(&String.codepoints/1)
|> Enum.reduce({[], nil, 0}, fn current_row, {acc, previous_row, split_count} ->
  current_row_map =
    current_row
    |> Enum.with_index()
    |> Enum.into(%{}, fn {val, i} -> {i, val} end)

  {processed_row, split_count_new} =
    if previous_row do
      previous_row_map =
        previous_row |> Enum.with_index() |> Enum.into(%{}, fn {val, i} -> {i, val} end)

      {new_row_map, split_count} =
        previous_row_map
        |> Enum.reduce({current_row_map, 0}, fn element, {acc, split_count} ->
          {index, previous_char} = element
          current_char = Map.get(acc, index)

          case previous_char do
            "S" ->
              {Map.replace(acc, index, "|"), split_count}

            "|" ->
              case current_char do
                "^" ->
                  # split count  + 1
                  {Map.replace(acc, index - 1, "|") |> Map.replace(index + 1, "|"),
                   split_count + 1}

                "." ->
                  {Map.replace(acc, index, "|"), split_count}

                _ ->
                  {acc, split_count}
              end

            _ ->
              {acc, split_count}
          end
        end)

      {new_row_map
       |> Enum.sort()
       |> Enum.to_list()
       |> Enum.map(fn {_i, val} -> val end), split_count}
    else
      {current_row, split_count}
    end

  {[processed_row | acc], processed_row, split_count + split_count_new}
end)
|> elem(2)
|> IO.inspect()
