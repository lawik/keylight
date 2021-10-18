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

Usage:

```elixir
devices = Keylight.discover()
Keylight.info(devices)

Keylight.on(devices)
Keylight.off(devices)
Keylight.status(devices)
Keylight.set(devices, on: 1, brightness: 20, temperature: 200)
```
