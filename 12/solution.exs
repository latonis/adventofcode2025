[presents, regions] =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Stream.chunk_by(fn x -> x == "" end)
  |> Stream.reject(fn x -> x == [""] end)
  |> Stream.chunk_by(fn x -> Enum.count(x) == 4 end)
  |> Enum.to_list()

present_areas =
  presents
  |> Enum.map(fn x ->
    Enum.reduce(x, 0, fn e, acc ->
      acc + (String.graphemes(e) |> Enum.count(fn c -> c == "#" end))
    end)
  end)

regions
|> List.flatten()
|> Enum.reject(fn x ->
  [area_unparsed, needed_presents] = String.split(x, ": ")

  area_given =
    area_unparsed
    |> String.split("x")
    |> Enum.map(&String.to_integer/1)
    |> Enum.product()

  area_needed =
    String.split(needed_presents)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.map(fn {i, index} ->
      case i do
        0 ->
          1

        _ ->
          Enum.at(present_areas, index) * i
      end
    end)
    |> Enum.sum()

  area_given < area_needed
end)
|> Enum.count()
|> IO.inspect()
