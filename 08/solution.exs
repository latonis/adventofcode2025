defmodule N do
  defstruct x: 0, y: 0, z: 0
end

defmodule Graph do
  def create_node(x, y, z) do
    %N{x: x, y: y, z: z}
  end

  def calculate_distance(a, b) do
    :math.sqrt((b.x - a.x) ** 2 + (b.y - a.y) ** 2 + (b.z - a.z) ** 2)
  end
end

nodes =
  File.stream!("test")
  |> Stream.map(&String.trim/1)
  |> Stream.map(fn x -> String.split(x, ",") end)
  |> Stream.map(fn x -> Enum.map(x, &String.to_integer/1) end)
  |> Stream.map(fn element ->
    [x, y, z] = element
    Graph.create_node(x, y, z)
  end)
  |> Enum.to_list()

distances =
  nodes
  |> Enum.with_index()
  |> Enum.flat_map(fn {p1, i} ->
    Enum.drop(nodes, i + 1)
    |> Enum.map(fn p2 -> {p1, p2, Graph.calculate_distance(p1, p2)} end)
  end)
  |> Enum.sort_by(fn {_p1, _p2, dist} -> dist end)

1..1000
|> Enum.reduce({[], MapSet.new()}, fn _number, {circuits, seen_pairs} ->
  edge =
    Enum.find(distances, fn {a, b, _distance} ->
      not (MapSet.member?(seen_pairs, {a, b}) or MapSet.member?(seen_pairs, {b, a}))
    end)

  case edge do
    nil ->
      {circuits, seen_pairs}

    {p1, p2, _dist} ->
      {sets_with_points, other_sets} =
        Enum.split_with(circuits, fn set ->
          MapSet.member?(set, p1) or MapSet.member?(set, p2)
        end)

      new_set =
        sets_with_points
        |> Enum.reduce(MapSet.new([p1, p2]), fn set, acc -> MapSet.union(set, acc) end)

      new_circuits = [new_set | other_sets]
      {new_circuits, MapSet.put(seen_pairs, {p1, p2})}
  end
end)
|> elem(0)
|> Enum.map(fn x -> Enum.count(x) end)
|> Enum.sort(:desc)
|> Enum.take(3)
|> Enum.product()
|> IO.inspect()
