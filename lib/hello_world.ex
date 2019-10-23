defmodule HelloWorld do
  def handle(event, context) do
    :erllambda.message("event: ~p", [event])
    :erllambda.message("context: ~p", [context])

    {:ok, response(%{ok: "yes"})}
  end

  defp to_json(to_convert) do
    to_convert |> :jiffy.encode
  end

  defp response(response) do
    %{
      statusCode: "200",
      body: to_json(response),
      headers: %{
        "Content-Type": "application/json"
      }
    }
  end
end
