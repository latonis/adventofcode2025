File.stream!("input")
|> Stream.map(&String.trim/1)
|> Stream.map(fn x ->
  {dir, val} = String.split_at(x, 1)
  val_i = String.to_integer(val)

  if dir == "L" do
    val_i * -1
  else
    val_i
  end
end)
|> Enum.reduce({50, 0}, fn x, acc ->
  {old_lock, count} = acc
  lock = Integer.mod(x + old_lock, 100)

  {lock,
   if lock == 0 do
     count + 1
   else
     count
   end}
end)
|> IO.inspect()

File.stream!("input")
|> Stream.map(&String.trim/1)
|> Stream.map(fn x ->
  {dir, val} = String.split_at(x, 1)
  val_i = String.to_integer(val)

  if dir == "L" do
    val_i * -1
  else
    val_i
  end
end)
|> Enum.reduce({50, 0}, fn x, acc ->
  {old_lock, count} = acc
  times = div(abs(x), 100)

  sign =
    if x < 0 do
      -1
    else
      1
    end

  lock = Integer.mod(x + old_lock, 100)

  times_and_cross =
    if old_lock != 0 && lock != 0 do
      if lock > old_lock && sign == -1 do
        times + 1
      else
        if lock < old_lock && sign == 1 do
          times + 1
        else
          times
        end
      end
    else
      times
    end

  {lock,
   if lock == 0 do
     count + 1 + times_and_cross
   else
     count + times_and_cross
   end}
end)
|> IO.inspect()
