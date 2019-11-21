defmodule MagiratorQuery.Inquisitors.DeckInquiry do

  alias Bolt.Sips, as: Bolt
  alias MagiratorQuery.Helpers

  def select_all_results( deck_id ) do

    query = """
      MATCH 
        (qd:Deck)<-[:With]-(r:Result)
        -[:In]->(g:Game)<-[:In]-
        (:Result)-[:With]->(d:Deck),
        (r)-[:Got]-(p:Player)
      WHERE 
        qd.id = #{ deck_id } 
      RETURN 
        d.id As bundle_id, r
    """
    
    Bolt.query!(Bolt.conn, query)
    |> nodes_to_results
    |> Helpers.return_as_tuple
  end


  #Helpers
  defp nodes_to_results( nodes ) do
    nodes
    |> Enum.map( &node_to_result/1 )
    |> Enum.group_by(fn %{id: id} -> id end, fn %{place: place} -> place end)
    |> Enum.reduce([], fn {key, values}, acc ->
      acc ++ [%{
        deck_id: key, 
        games: Enum.count(values),
        wins: Enum.count(values, fn x -> x == 1 end),
        losses: Enum.count(values, fn x -> x > 1 end)
        }]
    end)
  end

  defp node_to_result( node ) do
    id = node["bundle_id"]
    result = node["r"].properties
    %{id: id, place: result["place"]}
  end


  def list_all_results(deck_id) do

    query = """
      MATCH 
        (q_deck:Deck)<-[:With]-(q_result:Result)
        -[:In]->(game:Game)<-[:In]-
        (opponent_result:Result)-[:With]->(opponent_deck:Deck)
        -[:Currently]->(opponent_deck_data:Data), 
        (opponent_result)<-[:Got]-(opponent_player:Player)
        -[:Currently]->(opponent_data:Data) 
      OPTIONAL MATCH 
        (match:Match)-[:Contains]->(game) 
      WHERE q_deck.id = #{deck_id} 
      RETURN match, game, q_result, opponent_deck, opponent_data, opponent_deck_data
    """

    Bolt.query!(Bolt.conn, query)
    |> result_set_to_result_list
    |> Helpers.return_as_tuple
  end

  defp result_set_to_result_list(result_set) do
    result_set
    |> Enum.map(&to_list_result/1)
  end

  defp to_list_result(node_set) do
    prop_map = map_prop(%{}, node_set, "match")
    |> map_prop(node_set, "game")
    |> map_prop(node_set, "q_result", "result")
    |> map_prop(node_set, "opponent_deck")
    |> map_prop(node_set, "opponent_deck_data")
    |> map_prop(node_set, "opponent_data")

    %{
      match_id: zero_nil(prop_map["match"]["id"]), 
      game_id: prop_map["game"]["id"], 
      place: prop_map["result"]["place"], 
      opponent_deck_id: prop_map["opponent_deck"]["id"], 
      opponent_deck_name: prop_map["opponent_deck_data"]["name"], 
      opponent_name: prop_map["opponent_data"]["name"], 
    }
  end


  defp map_prop(map, node_set, name, alias) do
    case node_set[name] do
      nil ->
        Map.put(map, name, 
          Map.put(map, alias <> "_id", 0)
        )
      _ -> 
        Map.put(map, alias, node_set[name].properties)
    end
  end

  defp map_prop(map, node_set, name) do
    map_prop(map, node_set, name, name)
  end


  defp zero_nil(nil) do
    0
  end

  defp zero_nil(x) do
    x
  end
end