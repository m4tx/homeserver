HomeServer
==========

My home server setup, config files, and utility scripts.

## Install the backup service

First, install `curl`, `git`, and [`rustic`](https://rustic.cli.rs/) if you don't have them yet. Then execute:

```bash
curl https://raw.githubusercontent.com/m4tx/homeserver/master/download.sh | sudo bash
```

## Initializing the backup repository on the server

```
sudo -u rustic rustic init
```

Remember to edit `/etc/rustic/rustic.toml` (after installing the backup service) first.
