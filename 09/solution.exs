points =
  File.stream!("input")
  |> Stream.map(fn x ->
    strings = String.split(String.trim(x), ",")
    [x, y] = Enum.map(strings, &String.to_integer/1)
    {x, y}
  end)

point_pairs =
  for x <- points,
      y <- points,
      x != y,
      do: {x, y}

point_pairs
|> MapSet.new()
|> Enum.map(fn x ->
  {a, b} = x
  a_x = elem(a, 0)
  b_x = elem(b, 0)

  a_y = elem(a, 1)
  b_y = elem(b, 1)

  width = abs(a_x - b_x)
  height = abs(a_y - b_y)
  # IO.inspect("#{a_x}, #{a_y} | #{b_x}, #{b_y}")
  # IO.inspect("#{width + 1 * height + 1}")
  (width + 1) * (height + 1)
end)
|> Enum.max()
|> IO.inspect()
