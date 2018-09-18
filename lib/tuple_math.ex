defmodule TupleMath do
  @moduledoc """
  Helper math functions for tuples
  """

  def zero?({}), do: true
  def zero?({0}), do: true
  def zero?({_}), do: false
  def zero?({0, 0}), do: true
  def zero?({_, _}), do: false
  def zero?({0, 0, 0}), do: true
  def zero?({_, _, _}), do: false
  def zero?({0, 0, 0, 0}), do: true
  def zero?({_, _, _, _}), do: false

  def zero?(x) when is_tuple(x) do
    x
    |> Tuple.to_list()
    |> Enum.all?(&(&1 == 0))
  end

  def sub(x, y, g) when tuple_size(x) == tuple_size(y) do
    Enum.zip(Tuple.to_list(x), Tuple.to_list(y))
    |> Enum.reverse()
    |> Enum.map(fn {xd, yd} -> xd - yd end)
    |> normalise(g, [])
    |> List.to_tuple()
  end

  def add(x, nil, _), do: x
  def add(nil, y, _), do: y

  def add(x, y, g) when tuple_size(x) == tuple_size(y) do
    Enum.zip(Tuple.to_list(x), Tuple.to_list(y))
    |> Enum.reverse()
    |> Enum.map(fn {xd, yd} -> xd + yd end)
    |> normalise(g, [])
    |> List.to_tuple()
  end

  def normalise([], _base, acc), do: acc
  def normalise([x], _base, _acc) when x < 0, do: :negative
  def normalise([x], base, acc) when x >= base, do: normalise([x - base, 1], base, acc)
  def normalise([x1 | [x0 | xs]], base, acc) when x1 < 0, do: normalise([x1 + base | [x0 - 1 | xs]], base, acc)
  def normalise([x1 | [x0 | xs]], base, acc) when x1 >= base, do: normalise([x1 - base | [x0 + 1 | xs]], base, acc)
  def normalise([x | xs], base, acc), do: normalise(xs, base, [x | acc])
end
