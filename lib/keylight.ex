defmodule Keylight do
  @moduledoc """
  Documentation for `Keylight`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Keylight.hello()
      :world

  """



  @query_all {:dns_query, '_services._dns-sd._udp.local', :ptr, :in}
  @query_devices {:dns_query, '_elg._tcp.local', :ptr, :in}
  @default_timeout 2000
  def discover(timeout \\ @default_timeout) do
    query_mdns()
    :timer.sleep(@default_timeout)
    case check_mdns() do
      %{additional: []} -> []
      %{additional: records} -> records_to_devices(records)
    end
  end

  defp records_to_devices(records) do
    records
    |> Enum.map(fn record ->
      {:dns_rr, identifier, record_type, _, _, _, contents, _, _, _} = record
      case record_type do
        :srv -> {to_string(identifier), %{host: srv_to_host(contents), port: srv_to_port(contents)}}
        :txt -> {to_string(identifier), %{name: txt_to_name(contents)}}
      end
    end)
    |> Enum.reduce(%{}, fn {key, data}, acc ->
      d = acc
          |> Map.get(key, %{})
          |> Map.merge(data)
      Map.put(acc, key, d)
    end)
  end

  def info(%{host: host, port: port}) do
    :inets.start()
    url = to_charlist("http://#{host}:#{port}/elgato/accessory-info")
    {:ok, {_, _, body}} = :httpc.request(:get, {url, []}, [], [])
    body
  end

  def info(devices) when is_map(devices) do
    devices
    |> Enum.map(fn {key, value} ->
      {key, info(value)}
    end)
    |> Map.new()
  end


  defp srv_to_host({_, _, _, host}), do: to_string(host)
  defp srv_to_port({_, _, port, _}), do: port

  defp txt_to_name(parts) do
    parts
    |> Enum.find(fn p ->
      String.starts_with?(to_string(p), "md=")
    end)
    |> case do
      nil -> "Unnamed"
      name ->
        "md=" <> name = to_string(name)
        name
    end
  end

  defp query_mdns do
    MdnsLite.Responder.multicast_all(@query_devices)
  end

  defp check_mdns do
    MdnsLite.Responder.query_all_caches(@query_devices)
  end
end
