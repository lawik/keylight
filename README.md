# Keylight

- Discovery
- Changing settings
- NOT initial setup

Add to deps, not currently on hex:

```elixir
def deps do
  [
    {:keylight, github: "lawik/keylight"}
  ]
end
```

## Initial configuration

You need to ensure that mdns is properly set up and configured on your system. On mac mdns is setup by default but on Linux you may need to do some configuration (but the details are not covered in this doc).

For nerves you should follow the mdns_lite instructions: https://hexdocs.pm/mdns_lite/readme.html#dns-bridge-configuration

## Usage

```elixir
devices = Keylight.discover()
Keylight.info(devices)

Keylight.on(devices)
Keylight.off(devices)
Keylight.status(devices)
Keylight.set(devices, on: 1, brightness: 20, temperature: 200)
```
