File.stream!("test")
|> Enum.to_list()
|> List.first()
|> String.split(",")
|> Stream.map(fn x ->
  [a, b] = String.split(x, "-")
  start = String.to_integer(a)
  stop = String.to_integer(b)
  Enum.to_list(start..stop)
end)
|> Enum.to_list()
|> List.flatten()
|> Enum.map(fn x -> Integer.digits(x) end)
|> Enum.filter(fn x -> Integer.mod(length(x), 2) == 0 end)
|> Enum.filter(fn x ->
  n_len = length(x)
  {first_half, second_half} = Enum.split(x, trunc(n_len / 2))
  first_half == second_half
end)
|> Enum.map(fn digits -> Enum.reduce(digits, fn digit, acc -> acc * 10 + digit end) end)
|> Enum.sum()
|> IO.inspect(charlists: :as_lists)

File.stream!("input")
|> Enum.to_list()
|> List.first()
|> String.split(",")
|> Stream.map(fn x ->
  [a, b] = String.split(x, "-")
  start = String.to_integer(a)
  stop = String.to_integer(b)
  Enum.to_list(start..stop)
end)
|> Enum.to_list()
|> List.flatten()
|> Enum.map(fn x -> Integer.digits(x) end)
|> Enum.filter(fn x -> length(x) > 1 end)
|> Enum.flat_map(fn x ->
  vals =
    for idx <- 1..max(length(x) - 1, 1) do
      {pattern, rest} = Enum.split(x, idx)
      to_check = Enum.chunk_every(rest, idx)
      {Enum.all?(to_check, fn x -> pattern == x end), x}
    end

  filtered =
    Enum.filter(vals, fn x ->
      {keep, _} = x
      keep
    end)
    |> Enum.map(fn x ->
      {_, val} = x
      val
    end)
    |> Enum.uniq()

  filtered
end)
|> Enum.map(fn digits -> Enum.reduce(digits, fn digit, acc -> acc * 10 + digit end) end)
|> Enum.sum()
|> IO.inspect(charlists: :as_lists)
