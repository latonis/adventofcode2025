File.stream!("input")
|> Stream.map(&String.trim/1)
|> Stream.map(&String.codepoints/1)
|> Stream.map(fn x -> Enum.map(x, fn y -> String.to_integer(y) end) end)
|> Enum.map(fn arr ->
  # n = 2
  n = 12

  {_, highs} =
    Enum.reduce_while(0..(n - 1), {0, []}, fn i, acc ->
      {cur_max_index, cur_maxes} = acc
      list_after_cur_max = Enum.slice(arr, cur_max_index..length(arr))
      list_end_removed = Enum.take(list_after_cur_max, length(list_after_cur_max) - (n - 1 - i))

      cur_max =
        Enum.reduce(
          Enum.with_index(list_end_removed),
          {hd(list_end_removed), cur_max_index},
          fn {value, index}, {max_value, max_index} ->
            if value > max_value do
              {value, index + cur_max_index}
            else
              {max_value, max_index}
            end
          end
        )

      if i < n do
        {:cont, {elem(cur_max, 1) + 1, cur_maxes ++ [cur_max]}}
      else
        {:halt, {i, cur_maxes}}
      end
    end)

  highs
  |> Enum.map(fn x ->
    {val, _} = x
    val
  end)
  |> Integer.undigits()
end)
|> Enum.sum()
|> IO.inspect()
