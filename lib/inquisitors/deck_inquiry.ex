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
        id: key, 
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
end