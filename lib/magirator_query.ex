defmodule MagiratorQuery do
  alias MagiratorQuery.Inquisitors.DeckInquiry
  alias MagiratorQuery.Inquisitors.ResultInquiry
  
  defdelegate find_deck_results(deck_id), to: DeckInquiry, as: :select_all_results
  defdelegate extend_results_visual(results), to: ResultInquiry, as: :extend_results_visual
end
