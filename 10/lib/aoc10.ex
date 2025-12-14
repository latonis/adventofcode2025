defmodule Aoc10p1 do
  alias ExSMT.{BitVector, Expression, Solver, Variable, Serializable}

  defp list_to_int(bits) do
    Enum.reduce(bits, 0, fn bit, acc ->
      acc * 2 + bit
    end)
  end

  defp build_smt_script(constraint, vars, objective) do
    logic = "(set-logic QF_BV)\n"

    declare_vars =
      Enum.flat_map(vars, fn var ->
        var_name = Serializable.serialize_int(var)
        ~c"(declare-const #{var_name} Bool)\n"
      end)

    constraint_smt = Serializable.serialize_bool(constraint)
    assert_constraint = ["(assert ", constraint_smt, ")\n"]

    objective_smt = Serializable.serialize_int(objective)
    minimize_command = ["(minimize ", objective_smt, ")\n"]

    commands = [
      "(check-sat)\n",
      "(get-model)\n"
    ]

    [logic, declare_vars, assert_constraint, minimize_command, commands]
  end

  def main() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn x ->
      [end_state | tail] = String.split(x, " ")
      [joltage | equation_entries] = Enum.reverse(tail)

      end_state =
        Enum.map(String.codepoints(end_state), fn x ->
          case x do
            "." -> 0
            "#" -> 1
            _ -> nil
          end
        end)
        |> Enum.reject(fn x -> x == nil end)

      n = Enum.count(end_state)

      equation_entries =
        Enum.map(equation_entries, fn x ->
          String.split(String.replace(x, "(", "") |> String.replace(")", ""), ",")
          |> Enum.map(&String.to_integer/1)
        end)
        |> Enum.map(fn x ->
          keys_to_flip = x |> MapSet.new()

          for i <- 0..(n - 1) do
            if MapSet.member?(keys_to_flip, i) do
              1
            else
              0
            end
          end
        end)

      joltage =
        String.split(String.replace(joltage, "{", "") |> String.replace("}", ""), ",")
        |> Enum.map(&String.to_integer/1)

      {end_state, equation_entries, joltage}
    end)
    |> Enum.map(fn {target_mask, variable_masks, _joltage} ->
      target_value = list_to_int(target_mask)
      variable_values = Enum.map(variable_masks, &list_to_int/1)

      bit_size = Enum.count(target_mask)

      target_bv = BitVector.new(target_value, bit_size)
      zero_bv = BitVector.new(0, bit_size)
      one_bv = BitVector.new(1, bit_size)

      var_bvs =
        Enum.map(variable_values, fn value ->
          BitVector.new(value, bit_size)
        end)

      bool_vars =
        for i <- 1..length(var_bvs) do
          Variable.new(:bool, "x#{i}")
        end

      terms =
        Enum.zip(bool_vars, var_bvs)
        |> Enum.map(fn {x_i, v_i} ->
          Expression.new(:ite, [x_i, v_i, zero_bv])
        end)

      final_state =
        Enum.reduce(terms, zero_bv, fn term, acc ->
          Expression.new(:bvxor, [term, acc])
        end)

      primary_constraint = Expression.new(:=, [final_state, target_bv])

      min_terms =
        Enum.map(bool_vars, fn x_i ->
          Expression.new(:ite, [x_i, one_bv, zero_bv])
        end)

      min_objective =
        Enum.reduce(min_terms, zero_bv, fn term, acc ->
          Expression.new(:bvadd, [term, acc])
        end)

      smt_script =
        build_smt_script(primary_constraint, bool_vars, min_objective)

      [_solution, terms] = Solver.query(smt_script)

      terms |> Enum.filter(fn [_, _, _, _, b] -> b end) |> Enum.count()
    end)
    |> Enum.sum()
    |> IO.inspect()
  end
end

defmodule Aoc10p2 do
  alias ExSMT
  alias ExSMT.Expression
  alias ExSMT.Variable

  def min_button_presses(equations, joltage) do
    %{
      constraints: base_constraints,
      total_var: total_var,
      press_vars: press_vars
    } = build_constraints(equations, joltage)

    max_target = Enum.sum(joltage)
    min_search_bound = if max_target > 0, do: 1, else: 0

    min_solution =
      min_search_bound..max_target
      |> Enum.find_value(fn n ->
        total_constraint = ExSMT.expr(:=, total_var, n)
        full_expr = ExSMT.Expression.new(:and, [base_constraints, total_constraint])

        case ExSMT.solve(full_expr) do
          {:sat, model} ->
            presses = get_presses(model, press_vars)
            {:ok, n, presses}

          _ ->
            nil
        end
      end)

    case min_solution do
      {:ok, total, presses} -> {:ok, total, presses}
      nil -> {:error, :unsolvable}
    end
  end

  defp build_constraints(equations, joltage) do
    num_buttons = length(equations)
    num_counters = length(joltage)

    press_vars = 0..(num_buttons - 1) |> Enum.map(&ExSMT.ssa_var(:p, &1))

    non_neg_constraints =
      Enum.map(press_vars, fn p_var -> ExSMT.expr(:>=, p_var, 0) end)

    joltage_constraints =
      0..(num_counters - 1)
      |> Enum.map(fn i ->
        contributing_presses =
          Enum.zip(press_vars, equations)
          |> Enum.filter(fn {_, affected_counters} -> i in affected_counters end)
          |> Enum.map(fn {p_var, _} -> p_var end)

        sum_expr =
          case contributing_presses do
            [] -> 0
            [p_var] -> p_var
            args -> ExSMT.Expression.new(:+, args)
          end

        target_joltage = Enum.at(joltage, i)
        ExSMT.expr(:=, sum_expr, target_joltage)
      end)

    total_presses_sum = ExSMT.Expression.new(:+, press_vars)

    total_var = ExSMT.env_var(:total)
    total_constraint = ExSMT.expr(:=, total_var, total_presses_sum)

    all_constraints_list =
      non_neg_constraints ++ joltage_constraints ++ [total_constraint]

    all_constraints = ExSMT.Expression.new(:and, all_constraints_list)

    %{
      constraints: all_constraints,
      total_var: total_var,
      press_vars: press_vars
    }
  end

  defp get_presses(model, press_vars) do
    assignments =
      Enum.flat_map(model, fn
        [:"define-fun", key_atom, [], :Int, value] when is_atom(key_atom) and is_integer(value) ->
          [{key_atom, value}]

        _ ->
          []
      end)
      |> Enum.into(%{})

    press_vars
    |> Enum.map(fn %Variable{name: name, i: i} ->
      atom_key = String.to_atom("#{Atom.to_string(name)}:#{i}")

      Map.get(assignments, atom_key, 0)
    end)
  end

  def main() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn x ->
      [end_state | tail] = String.split(x, " ")
      [joltage | equation_entries] = Enum.reverse(tail)

      end_state =
        Enum.map(String.codepoints(end_state), fn x ->
          case x do
            "." -> 0
            "#" -> 1
            _ -> nil
          end
        end)
        |> Enum.reject(fn x -> x == nil end)

      equation_entries =
        Enum.map(equation_entries, fn x ->
          String.split(String.replace(x, "(", "") |> String.replace(")", ""), ",")
          |> Enum.map(&String.to_integer/1)
        end)

      joltage =
        String.split(String.replace(joltage, "{", "") |> String.replace("}", ""), ",")
        |> Enum.map(&String.to_integer/1)

      {end_state, equation_entries, joltage}
    end)
    |> Enum.to_list()
    |> Enum.map(fn {_, equations, joltage} ->
      min_button_presses(equations, joltage)
    end)
    |> Enum.map(fn {_, count, _} -> count end)
    |> Enum.sum()
    |> IO.inspect()
  end
end
