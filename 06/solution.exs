input = File.stream!("input")

# part 1
input
|> Stream.map(&String.split/1)
|> Enum.zip()
|> Enum.map(&Tuple.to_list/1)
|> Enum.map(fn x ->
  [sign | rest] = Enum.reverse(x)

  elements = rest |> Enum.map(&String.to_integer/1)

  case sign do
    "*" -> elements |> Enum.product()
    "+" -> elements |> Enum.sum()
  end
end)
|> Enum.sum()
|> IO.inspect()

# part 2
input
|> Stream.map(&String.codepoints/1)
|> Enum.zip()
|> Enum.map(&Tuple.to_list/1)
|> Enum.map(fn x -> Enum.filter(x, fn element -> element != " " end) end)
|> Enum.chunk_by(fn x -> x == [] end)
|> Enum.reject(fn x -> x == [[]] end)
|> Enum.map(fn [first | rest] ->
  {operator, new_int} = List.pop_at(first, -1)
  {operator, rest ++ [new_int]}
end)
|> Enum.map(fn {operator, integers} ->
  {operator, Enum.map(integers, fn x -> Integer.undigits(Enum.map(x, &String.to_integer/1)) end)}
end)
|> Enum.map(fn {operator, elements} ->
  case operator do
    "*" -> elements |> Enum.product()
    "+" -> elements |> Enum.sum()
  end
end)
|> Enum.sum()
|> IO.inspect()
