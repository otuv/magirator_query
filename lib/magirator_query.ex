defmodule MagiratorQuery do
  alias MagiratorQuery.Inquisitors.DeckInquiry
  
  defdelegate find_deck_results(deck_id), to: DeckInquiry, as: :select_all_results
end
