input_lines =
  File.stream!("input")
  |> Stream.map(&String.trim/1)

split_pos =
  input_lines
  |> Enum.find_index(fn x -> x == "" end)

fresh_ranges =
  input_lines
  |> Enum.slice(0..(split_pos - 1))
  |> Enum.map(fn x ->
    [start, stop] = String.split(x, "-")
    {String.to_integer(start), String.to_integer(stop)}
  end)

input_lines
|> Enum.slice((split_pos + 1)..length(Enum.to_list(input_lines)))
|> Enum.map(fn x -> String.to_integer(x) end)
|> Enum.filter(fn x ->
  Enum.any?(fresh_ranges, fn {start, stop} -> x >= start and x <= stop end)
end)
|> Enum.count()
|> IO.inspect()
