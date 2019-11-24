defmodule MagiratorQuery.Helper do
  @doc """
  Convert map string keys to :atom keys
  """
  def atomize_keys(nil), do: nil

  # Structs don't do enumerable and anyway the keys are already
  # atoms
  def atomize_keys(struct = %{__struct__: _}) do
    struct
  end

  def atomize_keys(map = %{}) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
  end


  def return_expected_single( list ) do
    case Enum.count list do
      1 ->
        Enum.fetch(list, 0)
      0 ->
        { :error, :not_found}
      _ ->
        { :error, :invalid_request}
    end
  end


  def return_expected_matching_id(created_id, generated_id) do
      case created_id == generated_id do
      :true ->
          { :ok, created_id }
      :false ->
          { :error, :insert_failure }
    end
  end


  def return_as_tuple({:error, msg}) do
    {:error, msg}
  end

  def return_as_tuple(item) do
    {:ok, item}
  end


  def return_result_id(result) do
    [ row ] = result
    { created_id } = { row["id"] }
    created_id
  end
  

  def mics_to_ms(microseconds) do
    microseconds/1000
  end


  def clock(mark, fun, args) do
    {time, result} = :timer.tc(fun, args)
    ms_time = mics_to_ms(time)
    IO.puts(mark <> ": #{ms_time} ms")
    result
  end


  def ts(mark, previous) do
    current = ts(mark)
    diff = 
      :timer.now_diff(current, previous)
      |> mics_to_ms()
    IO.puts(mark <> " after #{diff} ms")
    current
  end

  def ts(mark) do
    current = :os.timestamp()
    IO.puts(mark <> " at #{:os.system_time(1000)} ms")
    current
  end
end