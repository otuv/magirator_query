defmodule MagiratorQueryTest do
  use ExUnit.Case

  import MagiratorQuery


  test "Select all deck results" do
    { status, data } = find_deck_results(20)
    assert :ok == status
    assert is_list data
    assert not Enum.empty? data
    first = List.first(data)
    assert is_map first
    assert Map.has_key? first, :id
    assert Map.has_key? first, :games
    assert Map.has_key? first, :wins
    assert Map.has_key? first, :losses
  end
end
