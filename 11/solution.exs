defmodule Search do
  def find_paths(graph, start_node, end_node) do
    {count, _cache} = recurse(graph, start_node, end_node, 1, %{})
    count
  end

  defp recurse(graph, current_node, end_node, current_len, cache) do
    if current_node == end_node do
      {1, cache}
    else
      if count = Map.get(cache, current_node) do
        {count, cache}
      else
        neighbors = Map.get(graph, current_node, [])

        {total_count, final_cache} =
          Enum.reduce(neighbors, {0, cache}, fn neighbor, {acc_count, acc_cache} ->
            {neighbor_count, new_cache} =
              recurse(graph, neighbor, end_node, current_len + 1, acc_cache)

            {acc_count + neighbor_count, new_cache}
          end)

        new_cache_with_result = Map.put(final_cache, current_node, total_count)
        {total_count, new_cache_with_result}
      end
    end
  end
end

graph =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Stream.map(fn x ->
    [key, parts] = String.split(x, ": ")
    {key, String.split(parts)}
  end)
  |> Map.new()

# part 1
start_key = "you"
end_key = "out"
Search.find_paths(graph, start_key, end_key) |> IO.inspect()

# part 2
start_key = "svr"
required_a = "dac"
required_b = "fft"

(Search.find_paths(graph, start_key, required_b) *
   Search.find_paths(graph, required_b, required_a) *
   Search.find_paths(graph, required_a, end_key))
|> IO.inspect()
