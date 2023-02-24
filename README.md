HomeServer
==========

My home server setup, config files, and utility scripts.

## Install the backup service

First, install `curl`, `git`, and [`restic`](https://restic.net/) if you don't have them yet. Then execute:

```bash
curl https://raw.githubusercontent.com/m4tx/homeserver/master/download.sh | sudo bash
```

## Initializing the backup repository on the server

```
sudo -u restic restic init
```

Remember to edit `/etc/backup.conf` (after installing the backup service) first.
