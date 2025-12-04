defmodule Grid do
  def get_accessible_bales(grid) do
    Map.keys(grid)
    |> Enum.filter(fn {row, col} -> Map.get(grid, {row, col}) == "@" end)
    |> Enum.filter(fn {row, col} ->
      frequencies =
        [
          {-1, -1},
          {0, -1},
          {1, -1},
          {-1, 0},
          {1, 0},
          {-1, 1},
          {0, 1},
          {1, 1}
        ]
        |> Enum.map(fn {dx, dy} -> {row + dx, col + dy} end)
        |> Enum.map(fn coord -> Map.get(grid, coord) end)
        |> Enum.frequencies()

      Map.get(frequencies, "@", 0) < 4
    end)
  end
end

grid =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.codepoints/1)
  |> Enum.with_index()
  |> Enum.flat_map(fn {row, row_index} ->
    Enum.with_index(row)
    |> Enum.map(fn {element, col_index} ->
      {{row_index, col_index}, element}
    end)
  end)
  |> Map.new()

# part 1
Grid.get_accessible_bales(grid)
|> Enum.count()
|> IO.inspect()

# part 2
Enum.reduce_while(0..length(Map.keys(grid)), {0, grid}, fn _, {count, new_map} ->
  to_filter = Grid.get_accessible_bales(new_map)
  to_filter_count = to_filter |> Enum.count()

  if to_filter_count == 0 do
    {:halt, {count, new_map}}
  else
    {:cont, {count + to_filter_count, Map.drop(new_map, to_filter)}}
  end
end)
|> elem(0)
|> IO.inspect()
