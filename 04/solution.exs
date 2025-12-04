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
    |> IO.inspect()

  Map.get(frequencies, "@", 0) < 4
end)
|> Enum.count()
|> IO.inspect()
