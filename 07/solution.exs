defmodule Grid do
  def print(grid) do
    Enum.each(grid, fn row ->
      row_string = Enum.map_join(row, "", &to_string/1)
      IO.puts(row_string)
    end)

    IO.puts("\n")
  end
end

input =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.codepoints/1)

input
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

grid =
  input
  |> Enum.with_index()
  |> Enum.flat_map(fn {row_list, row_index} ->
    row_list
    |> Enum.with_index()
    |> Enum.map(fn {val, col_index} ->
      {{row_index, col_index}, val}
    end)
  end)
  |> Map.new()

grid_n = Enum.count(input)

defmodule Pathing do
  def traverse(starter, grid, n) do
    memo = %{}
    {start_x, start_y} = starter
    walk(start_x, start_y, grid, n, memo) |> IO.inspect()
  end

  defp walk(row, col, grid, n, memo) do
    case Map.fetch(memo, {row, col}) do
      {:ok, result} ->
        {result, memo}

      :error ->
        if row == n - 1 do
          {1, Map.put(memo, {row, col}, 1)}
        else
          case Map.get(grid, {row + 1, col}) do
            # if beneath is ., go down, only option (x, y + 1)
            "." ->
              {res, memo_d} = walk(row + 1, col, grid, n, memo)

              {res, Map.put(memo_d, {row + 1, col}, res)}

            # if ^ beneath, go down and left (x+1, y-1) + go down  and right (x+1, y+1)
            "^" ->
              {left, memo_l} = walk(row + 1, col - 1, grid, n, memo)

              {right, memo_r} =
                walk(row + 1, col + 1, grid, n, memo_l |> Map.put({row + 1, col - 1}, left))

              memo_2 =
                memo_r |> Map.put({row + 1, col + 1}, right) |> Map.put({row, col}, left + right)

              {left + right, memo_2}

            # else no path
            _ ->
              {0, Map.put(memo, {row, col}, 0)}
          end
        end
    end
  end
end

{starting_pos, _} = Enum.find(grid, fn {_key, val} -> val == "S" end)
Pathing.traverse(starting_pos, grid, grid_n)
