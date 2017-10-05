# Raiu/deluge-openvpn

![deluge](https://avatars2.githubusercontent.com/u/6733935?v=3&s=200)

[Deluge](http://deluge-torrent.org/) is a lightweight, Free Software, cross-platform BitTorrent client.

* OpenVPN
* Full Encryption
* WebUI
* Plugin System
* Auto update openvpn and deluge on startup
* Much more...

It bundles certificates and configurations for the following VPN providers:

| Provider Name                | Config Value |
|:-----------------------------|:-------------|
| Anonine | `ANONINE` |
| BTGuard | `BTGUARD` |
| Cryptostorm | `CRYPTOSTORM` |
| FrootVPN | `FROOT` |
| FrostVPN | `FROSTVPN` |
| Giganews | `GIGANEWS` |
| HideMe | `HIDEME` |
| HideMyAss | `HIDEMYASS` |
| IntegrityVPN | `INTEGRITYVPN` |
| IPVanish | `IPVANISH` |
| Ivacy | `IVACY` |
| IVPN | `IVPN` |
| Newshosting | `NEWSHOSTING` |
| NordVPN | `NORDVPN` |
| OVPN | `OVPN` |
| Private Internet Access | `PIA` |
| PrivateVPN | `PRIVATEVPN` |
| PureVPN | `PUREVPN` |
| RA4W VPN | `RA4W` |
| SlickVPN | `SLICKVPN` |
| SmartVPN | `SMARTVPN` |
| TigerVPN | `TIGER` |
| TorGuard | `TORGUARD` |
| UsenetServerVPN | `USENETSERVER` |
| Windscribe | `WINDSCRIBE` |
| VPN.ht | `VPNHT` |
| VPNBook.com | `VPNBOOK` |
| VyprVpn | `VYPRVPN` |
When using PIA as provider it will update Transmission hourly with assigned open port. Please read the instructions below.

## Run container from Docker registry
The container is available from the Docker registry and this is the simplest way to get it.
To run the container use this command:

```
$ docker run -d \
              -v /your/storage/path/:/data \
              -v /your/storage/path/:/config \
              -v /your/storage/path/:/etc/openvpn \
              -v /etc/localtime:/etc/localtime:ro \
              -e "OPENVPN_PROVIDER=PIA" \
              -e "OPENVPN_CONFIG=Netherlands" \
              -e "OPENVPN_USERNAME=user" \
              -e "OPENVPN_PASSWORD=pass" \
              -e "PUID=1001" \
              -e "GUID=2001" \
              -p 9091:9091 \
              raiu/deluge-openvpn
```

You must set the environment variables `OPENVPN_PROVIDER`, `OPENVPN_USERNAME` and `OPENVPN_PASSWORD` to provide basic connection details.

The `OPENVPN_CONFIG` is an optional variable. If no config is given, a default config will be selected for the provider you have chosen.
Find available OpenVPN configurations by looking in the openvpn folder of the GitHub repository. The value that you should use here is the filename of your chosen openvpn configuration *without* the .ovpn file extension. For example:

```
-e "OPENVPN_CONFIG=ipvanish-AT-Vienna-vie-c02"
```

As you can see, the container also expects a data volume to be mounted.
This is where Deluge should store your downloads and incomplete downloads.
By default deluge home will be located at /config, this is where Deluge stores its state.


### Required environment options
| Variable | Function | Example |
|----------|----------|-------|
|`OPENVPN_PROVIDER` | Sets the OpenVPN provider to use. | `OPENVPN_PROVIDER=provider`. Supported providers and their config values are listed in the table above. |
|`OPENVPN_USERNAME`|Your OpenVPN username |`OPENVPN_USERNAME=asdf`|
|`OPENVPN_PASSWORD`|Your OpenVPN password |`OPENVPN_PASSWORD=asdf`|

### Network configuration options
| Variable | Function | Example |
|----------|----------|-------|
|`OPENVPN_CONFIG` | Sets the OpenVPN endpoint to connect to. | `OPENVPN_CONFIG=UK Southampton`|
|`OPENVPN_OPTS` | Will be passed to OpenVPN on startup | See [OpenVPN doc](https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html) |
|`LOCAL_NETWORK` | Sets the local network that should have access. | `LOCAL_NETWORK=192.168.0.0/24`|

## Usage

Deluge is started automaticly when OpenVPN connection has been initiated.

```
docker create \
  --name deluge \
  --net=host \
  -e PUID=<UID> -e PGID=<GID> \
  -e TZ=<timezone> \
  -v </path/to/your/downloads>:/downloads \
  -v </path/to/deluge/config>:/config \
  linuxserver/deluge
```

## Parameters

`The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
http://192.168.x.x:8080 would show you what's running INSIDE the container on port 80.`


* `--net=host` - Shares host networking with container, **required**.
* `-v /config` - deluge configs
* `-v /data` - torrent download directory
* `-e PGID` for for GroupID - see below for explanation
* `-e PUID` for for UserID - see below for explanation
* `-e TZ` for timezone information, eg Europe/London

It is based on alpine linux with s6 overlay, for shell access whilst the container is running do `docker exec -it deluge /bin/bash`.

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Setting up the application 

The admin interface is available at http://<ip>:8112 with a default user/password of admin/deluge.

To change the password (recommended) log in to the web interface and go to Preferences->Interface->Password.

Change the downloads location in the webui in Preferences->Downloads and use /downloads for completed downloads.

## Info

* Monitor the logs of the container in realtime `docker logs -f deluge`.

### Execute script for deluge
    #!/bin/bash
    torrentid=$1
    torrentname=$2
    torrentdir=$3
    torrentpath="$torrentdir/$torrentname"

    filemask=777

    if   [ -d "${torrentpath}" ]
            then
                    chmod ${filemask} -R "${torrentpath}"
    elif [ -f "${torrentpath}" ]
            then
                    chmod ${filemask} "${torrentpath}"
    fi