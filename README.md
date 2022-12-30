# Keylight

Keylight is an elixir api to control the [Elgato Key Light](https://www.elgato.com/en/key-light) and [Key Light Mini](https://www.elgato.com/en/key-light-mini).

Features:
- Discovery
- Changing settings

Note: Does NOT support initial setup

Add keylight to your deps (it is not currently on hex):

```elixir
def deps do
  [
    {:keylight, github: "lawik/keylight"},
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
