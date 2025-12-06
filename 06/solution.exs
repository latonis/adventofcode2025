File.stream!("input")
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
