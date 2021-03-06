defmodule MagiratorQuery.Inquisitors.ResultInquiry do

  alias Bolt.Sips, as: Bolt
  alias MagiratorQuery.Helper

  def extend_results_visual( results ) do

    result_ids = 
      results
      |> Enum.map(&(&1.id))
      |> inspect(charlists: false)

    query = """
      MATCH 
        (r:Result)
        -[:In]->(g:Game)<-[:In]-
        (or:Result)-[:With]->(od:Deck)-[:Currently]->(odd:Data),
        (or)<-[:Got]-(op:Player)-[:Currently]->(opd:Data)
      WHERE 
        r.id IN #{ result_ids } 
      OPTIONAL MATCH
        (g)<-[:Contains]-(m:Match)
      RETURN 
        r,or,odd,opd,g,m
    """
    
    Bolt.query!(Bolt.conn, query)
    |> nodes_to_matches
    |> Helper.return_as_tuple
  end


  #Helpers
  defp nodes_to_matches( nodes ) do
    nodes
    |> Enum.map( &node_to_visual_result/1 )
    |> Enum.group_by(
      fn %{match_id: match_id, opponent_name: opn, opponent_deck_name: odn} -> 
        %{match_id: match_id, opponent_name: opn, opponent_deck_name: odn}
      end, 
      fn %{game_id: game_id, time: time, place: place} -> 
        %{game_id: game_id, time: time, place: place}
      end 
    )
    |> Enum.reduce([], fn {key, value}, acc -> 
      acc ++ [%{
        info: key, 
        results: value
      }] 
    end)
  end

  defp node_to_visual_result( node ) do
    result = node["r"].properties
    opponent_deck = node["odd"].properties
    opponent_player = node["opd"].properties
    game = node["g"].properties
    match_id = id_or_zero(node["m"])
    
    %{
      id: result["id"], 
      place: result["place"],
      game_id: game["id"], 
      time: game["created"], 
      opponent_name: opponent_player["name"],
      opponent_deck_name: opponent_deck["name"],
      match_id: match_id,
    }
  end

  defp id_or_zero(node) do
    case node do
      nil ->
        0
      _ -> node.properties["id"]
    end
  end
end