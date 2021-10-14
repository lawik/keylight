use Mix.Config

config :mdns_lite,
  if_monitor: MdnsLite.InetMonitor

# Overrides for debugging and testing
#
# * udhcpc_handler: capture whatever happens with udhcpc
# * resolvconf: don't update the real resolv.conf
# * persistence_dir: use the current directory
# * bin_ip: just fail if anything calls ip rather that run it
config :vintage_net,
  udhcpc_handler: VintageNetTest.CapturingUdhcpcHandler,
  resolvconf: "/dev/null",
  persistence_dir: "./test_tmp/persistence",
  bin_ip: "false"

