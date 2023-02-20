defmodule Keylight do
  @moduledoc """
  Documentation for `Keylight`.
  """

  require MdnsLite.DNS

  @query_devices MdnsLite.DNS.dns_query(class: :in, type: :ptr, domain: '_elg._tcp.local')
  @default_timeout 2000

  def discover(timeout \\ @default_timeout) do
    query_mdns()
    :timer.sleep(timeout)
    case check_mdns() do
      %{additional: []} -> %{}
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

  def info(%{host: _} = device) do
    get(device, "elgato/accessory-info")
  end

  def info(devices) when is_map(devices) do
    multi(devices, &info/1)
  end

  def status(%{host: _} = device) do
    get(device, "elgato/lights")
  end

  def status(devices) when is_map(devices) do
    multi(devices, &status/1)
  end

  def on(%{host: _} = device) do
    put(device, "elgato/lights", %{"numberOfLights" => 1, "lights" => [%{"on" => 1}]})
  end

  def on(devices) when is_map(devices) do
    multi(devices, &on/1)
  end

  def off(%{host: _} = device) do
    put(device, "elgato/lights", %{"numberOfLights" => 1, "lights" => [%{"on" => 0}]})
  end

  def off(devices) when is_map(devices) do
    multi(devices, &off/1)
  end

  @options [:on, :brightness, :temperature]
  def set(%{host: _} = device, opts) do
    data = opts
          |> Enum.map(fn {key, value} ->
            if key in @options do
              if is_integer(value) do
                {to_string(key), value}
              else
                raise "Bad value #{value} for option '#{key}', should be an integer"
              end
            else
              raise "Bad option '#{key}'"
            end
          end)
          |> Map.new()
    put(device, "elgato/lights", %{"numberOfLights" => 1, "lights" => [data]})
  end

  def set(devices, opts) when is_map(devices) do
    multi(devices, fn device ->
      set(device, opts)
    end)
  end

  defp build_url(device, path) do
    to_charlist("http://#{device.host}:#{device.port}/#{path}")
  end

  defp multi(devices, fun) do
    devices
    |> Enum.sort()
    |> Enum.map(fn {key, value} ->
      {key, fun.(value)}
    end)
    |> Map.new()
  end

  defp get(device, path) do
    :inets.start()
    url = build_url(device, path)
    {:ok, {_, _, body}} = :httpc.request(:get, {url, []}, [], [])
    Jason.decode(to_string(body))
  end

  defp put(device, path, data) do
    :inets.start()
    url = build_url(device, path)
    body = Jason.encode!(data)
    {:ok, {_, _, body}} = :httpc.request(:put, {url, [], 'application/json', body}, [], [])
    Jason.decode(to_string(body))
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
