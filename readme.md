fping server list from mullvad configs.
for top 4 (best rtts), create connect scripts.

Once:
  - write your wg interface name and default gateway ip to `cfg.sh`, see `cfg-example.sh`

Periodically 
  - generate config zips at https://mullvad.net/de/account/#/wireguard-config and download them.
  - unzip config to `cfgs/`

Whenever you wish to fping the servers:

  1. run `find-best.sh`
  1. connect using `sudo ./con-best-0.sh`

RTT results are available in `fping-res.txt`

the script uses a really dumb `grep` to get the ips, adds /32 routes to those ips via the gateway provided in `cfg.sh`, runs fping and writes the scripts.

needs `fping` to be installed (ubuntu/debian: `sudo apt install fping`)
