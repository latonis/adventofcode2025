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
    Range.new(String.to_integer(start), String.to_integer(stop))
  end)
  |> Enum.sort()

# part one
input_lines
|> Enum.slice((split_pos + 1)..length(Enum.to_list(input_lines)))
|> Enum.map(fn x -> String.to_integer(x) end)
|> Enum.filter(fn x ->
  Enum.any?(fresh_ranges, fn range -> x in range end)
end)
|> Enum.count()
|> IO.inspect()

# part two
fresh_ranges
|> Enum.reduce([], fn current, acc ->
  case acc do
    [] ->
      [current]

    [prev | tail] ->
      if current.first <= prev.last + 1 do
        extended_last = max(prev.last, current.last)
        [prev.first..extended_last | tail]
      else
        [current | acc]
      end
  end
end)
|> Enum.map(fn r -> Range.size(r) end)
|> Enum.sum()
|> IO.inspect()
