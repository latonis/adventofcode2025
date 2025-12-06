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
lists =
  input
  |> Stream.map(&String.codepoints/1)
  |> Enum.zip()
  |> Enum.map(&Tuple.to_list/1)
  |> Enum.map(fn x -> Enum.filter(x, fn element -> element != " " end) end)

blank_indexes =
  lists
  |> Enum.with_index()
  |> Enum.filter(fn {element, _} -> Enum.all?(element, fn x -> x == " " end) end)
  |> Enum.map_reduce(0, fn index_t, acc ->
    end_index = elem(index_t, 1) - 1
    {{acc, end_index}, end_index + 2}
  end)

number_array = elem(blank_indexes, 0)

end_acc = elem(blank_indexes, 1)

final_arr = number_array ++ [{end_acc, length(lists)}]

numbers =
  final_arr
  |> Enum.map(fn {front, back} ->
    Enum.slice(lists, front..back)
  end)

numbers
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
