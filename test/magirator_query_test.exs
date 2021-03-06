defmodule MagiratorQueryTest do
  use ExUnit.Case

  import MagiratorQuery
  
  alias MagiratorQuery.Helper

  test "Select all deck results" do
    { status, data } = find_deck_results(20)
    assert :ok == status
    assert is_list data
    assert not Enum.empty? data
    first = List.first(data)
    assert is_map first
    assert Map.has_key? first, :deck_id
    assert Map.has_key? first, :games
    assert Map.has_key? first, :wins
    assert Map.has_key? first, :losses
  end


  test "extend results" do
    r1 = %{
      id: 32,
      game_id: 41,
      player_id: 10,
      deck_id: 20,
      place: 1,
      comment: "Result 1"
    }
    
    r2 = %{
      id: 30,
      game_id: 40,
      player_id: 10,
      deck_id: 20,
      place: 1,
      comment: "Result 2"
    }
    
    r3 = %{
      id: 36,
      game_id: 44,
      player_id: 10,
      deck_id: 20,
      place: 2,
      comment: "Result 3"
    }

    results = [r1, r2, r3]

    { status, data } = extend_results_visual( results )
    assert :ok == status
    assert is_list data
    assert not Enum.empty? data
    first = List.first(data)
    assert is_map first
    assert Map.has_key? first, :info
    assert Map.has_key? first, :results
  end


  test "list deck results" do
    {status, data_20} = Helper.clock("list deck results", &list_deck_results/1, [20])
    assert :ok == status
    assert is_list data_20
    assert not Enum.empty? data_20
    assert 8 == Enum.count(data_20)
    first = List.first(data_20)
    assert is_map first
    assert Map.has_key? first, :match_id
    assert Map.has_key? first, :game_id
    assert Map.has_key? first, :place
    assert Map.has_key? first, :opponent_deck_id
    assert Map.has_key? first, :opponent_deck_name
    assert Map.has_key? first, :opponent_name
    assert !Enum.find data_20, &(&1.match_id == nil) 
    assert !Enum.find data_20, &(&1.game_id == nil) 
    assert !Enum.find data_20, &(&1.opponent_deck_name == nil) 
    assert !Enum.find data_20, &(&1.opponent_name == nil) 
    
    {status, data_21} = Helper.clock("list deck results", &list_deck_results/1, [21])
    assert :ok == status
    assert is_list data_21
    assert 0 == Enum.count(data_21)
    
    {status, data_22} = Helper.clock("list deck results", &list_deck_results/1, [22])
    assert :ok == status
    assert is_list data_22
    assert 1 == Enum.count(data_22)
  end
end