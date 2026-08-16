# Tailscale for Home Assistant — liliainbloom's Fork

> [!IMPORTANT]
> This is liliainbloom's unofficial fork. It is not supported by Tailscale,
> Home Assistant, or the upstream Home Assistant Community Apps maintainers.

Tailscale is a zero config VPN, which installs on any device in minutes,
including your Home Assistant instance.

Create a secure network between your servers, computers, and cloud instances.
Even when separated by firewalls or subnets, Tailscale just works. Tailscale
manages firewall rules for you, and works from anywhere you are.

## Prerequisites

In order to use this app, you'll need a Tailscale account.

It is free to use for personal & hobby projects, up to 100 clients/devices on a
single user account. Sign up using your Google, Microsoft or GitHub account at
the following URL:

https://tailscale.com/start

You can also create an account during the app installation processes,
however, it is nice to know where you need to go later on.

## Installation

Add liliainbloom's app repository—not the source repository—to Home Assistant:

1. In Home Assistant, open **Settings** -> **Apps** -> **App store**.
1. Open the app-store menu, choose **Repositories**, and add
   `https://github.com/liliainbloom/homeassistant-repository`.
1. Install **Tailscale (liliainbloom's Fork)**.
1. Start the app.
1. Check the logs of the "Tailscale" app to see if everything went well.
1. Open the Web UI of the "Tailscale" app to complete authentication and
   couple your Home Assistant instance with your Tailscale account.
   **Note:** Some browsers don't work with this step. It is recommended to
   complete this step on a desktop or laptop computer using the Chrome browser.
1. Check the logs of the "Tailscale" app again, to see if everything went
   well.
1. Check the logs again and confirm that the app reports a running state.

## Configuration

Consider disabling key expiry to avoid losing connection to your Home Assistant
device. See [Key expiry][tailscale_info_key_expiry] for more information.

Logging in to Tailscale, you can configure your Tailscale network right from
their interface.

https://console.tailscale.com/

1. Navigate to the [Machines page][tailscale_machines] of the admin console, and
   find your Home Assistant instance.

1. Click on the **&hellip;** icon at the right side and select the "Edit route
   settings..." option. The "Exit node" and "Subnet routes" functions can be
   enabled here.

1. Click on the **&hellip;** icon at the right side and select the "Disable key
   expiry" option.

**Note:** _Remember to restart the app when the configuration is changed._

**Note:** _This is just an example, not even the default, don't copy and paste
it! Create your own!_

```yaml
accept_dns: true
accept_routes: false
advertise_connector: false
advertise_exit_node: false
advertise_routes:
  - local_subnets
  - 192.168.1.0/24
  - fd12:3456:abcd::/64
advertise_tags:
  - tag:example
  - tag:homeassistant
always_use_derp: false
exit_node: 100.101.102.103
log_level: info
log_upload: false
login_server: "https://controlplane.tailscale.com"
share_homeassistant: disabled
share_on_port: 443
snat_subnet_routes: true
stateful_filtering: false
taildrive:
  local_apps: false
  app_configs: false
  backup: false
  config: false
  media: false
  share: false
  ssl: false
taildrop: false
userspace_networking: false
```

> [!NOTE]
> Some of the configuration options are also available on Tailscale's web
> interface through the Web UI, but they are made read only there. You can't
> change them through the Web UI, because all the changes made there would be
> lost when the app is restarted.

### Option: `accept_dns`

This option allows you to accept the DNS settings of your tailnet that are
configured on the [DNS page][tailscale_dns] of the admin console. When disabled,
Tailscale's DNS resolves only tailnet addresses, no global nameservers from the
admin console are applied.

For more information, see the "DNS" section of this documentation.

This option is enabled by default.

### Option: `accept_routes`

This option allows you to accept subnet routes advertised by other nodes in
your tailnet.

More information: [Subnet routers][tailscale_info_subnets]

This option is disabled by default.

### Option: `advertise_connector`

This option allows you to advertise this Tailscale instance as an app connector.

When you use an app connector, you specify which applications you wish to make
accessible over your tailnet, and the domains for those applications. Any traffic
for that application is then forced over the tailnet to a node running an app
connector before egressing to the target domains. This is useful for cases where
the application has an allowlist of IP addresses which can connect to it: the IP
address of the node running the app connector can be added to the allowlist, and
all nodes on the tailnet will use that IP address for their traffic egress.

More information: [App connectors][tailscale_info_app_connectors]

This option is disabled by default.

### Option: `advertise_exit_node`

This option allows you to advertise this Tailscale instance as an exit node.

By setting a device on your network as an exit node, you can use it to
route all your public internet traffic as needed, like a consumer VPN.

More information: [Exit nodes][tailscale_info_exit_nodes]

This option is disabled by default.

**Note:** You can't advertise this device as an exit node and at the same time
specify an exit node to use. See also the "Option: `exit_node`" section of this
documentation.

**Note:** After you enable this option, you also have to enable it on Tailscale's
admin console.

1. Navigate to the [Machines page][tailscale_machines] of the admin console, and
   find your Home Assistant instance.

1. Click on the **&hellip;** icon at the right side and select the "Edit route
   settings..." option. The "Exit node" and "Subnet routes" functions can be
   enabled here.

### Option: `advertise_routes`

This option allows you to advertise routes to subnets (accessible on the network
your device is connected to) to other clients on your tailnet.

By adding to the list the IP addresses and masks of the subnet routes, you can
use it to make your devices on these subnets accessible within your tailnet.

By adding `local_subnets` to the list, the app will advertise routes to your
subnets on all supported interfaces.

More information: [Subnet routers][tailscale_info_subnets]

**Note:** After you add subnets to this option, you also have to enable them on
Tailscale's admin console.

1. Navigate to the [Machines page][tailscale_machines] of the admin console, and
   find your Home Assistant instance.

1. Click on the **&hellip;** icon at the right side and select the "Edit route
   settings..." option. The "Exit node" and "Subnet routes" functions can be
   enabled here.

### Option: `advertise_tags`

This option allows you to specify specific tags for this Tailscale instance.
They need to start with `tag:`.

More information: [Tags][tailscale_info_tags]

### Option: `always_use_derp`

When enabled forces all peer communication over DERP by disabling the use of
UDP.

This option is disabled by default.

Basically you will never want to enable this option. Try to enable it only, when
you experience that connections to your Home Assistant device regularly freeze
(even when you can ping the device, the web page or the Home Assistant app is
unresponsive), and you have to reload the web page or force stop the Home
Assistant app to make them work again. The root cause can be that your ISP
erroneously drops UDP packets on certain conditions.

### Option: `exit_node`

This option allows you to specify another Tailscale instance as an exit node for
this device.

By setting a device on your network as an exit node, you can use it to
route all your public internet traffic as needed, like a consumer VPN.

More information: [Exit nodes][tailscale_info_exit_nodes]

This option is unused by default. To make it visible on the configuration
editor, click "Show unused optional configuration options" at the bottom of the
page.

**Note:** You can't advertise this device as an exit node and at the same time
specify an exit node to use. See also the "Option: `advertise_exit_node`"
section of this documentation.

**Note:** The `exit-node-allow-lan-access` option is always enabled when an exit
node is specified. This is required by the Home Assistant environment.

### Option: `log_level`

Optionally enable all tailscaled debug messages in the app's log. Turn it on only
in case you are troubleshooting, because Tailscale's daemon is quite chatty. If
`log_level` is set to `info` or less severe level, tailscaled logs will be
suppressed after 200 lines.

The `log_level` option controls the level of log output by the app and can
be changed to be more or less verbose, which might be useful when you are
dealing with an unknown issue. Possible values are:

- `trace`: Show every detail, like all called internal functions.
- `debug`: Shows detailed debug information.
- `info`: Normal (usually) interesting events.
- `notice`: Normal but significant events.
- `warning`: Exceptional occurrences that are not errors.
- `error`: Runtime errors that do not require immediate action.
- `fatal`: Something went terribly wrong. App becomes unusable.

Please note that each level automatically includes log messages from a
more severe level, e.g., `debug` also shows `info` messages. By default,
the `log_level` is set to `info`, which is the recommended setting unless
you are troubleshooting.

### Option: `log_upload`

Controls Tailscale's client log upload to log.tailscale.com. Enable it if your
tailnet policy requires client log upload, otherwise Tailscale and the app can
refuse to start.

**Note:** When disabled, turns on Tailscale's `--no-logs-no-support` flag.

This option is disabled by default.

### Option: `login_server`

This option lets you to specify a custom control server instead of the default
(`https://controlplane.tailscale.com`). This is useful if you are running your
own Tailscale control server, for example, a self-hosted [Headscale] instance.

### Option: `share_homeassistant`

This option allows you to enable Tailscale Serve or Funnel features to present
your Home Assistant instance with a valid certificate on your tailnet or on the
internet.

This option is disabled by default.

Tailscale can provide a TLS certificate for your Home Assistant instance within
your tailnet domain.

This can prevent browsers from warning that HTTP URLs to your Home Assistant
instance look unencrypted (browsers are not aware that the connections between
Tailscale nodes are secured with end-to-end encryption).

**Note:** Tailscale Serve and Funnel will automatically update the certificate
before expiration, unlike the `tailscale cert` command. Follow the steps in this
documentation below to set up Serve or Funnel properly.

With the Tailscale Serve feature, you can access your Home Assistant instance
with the provided certificate within your tailnet from devices already connected
to your tailnet.

With the Tailscale Funnel feature, you can access your Home Assistant instance
with the provided certificate not only within your tailnet but even from the
wider internet using your Tailscale domain (like
`https://homeassistant.tail1234.ts.net`) from devices **without installed
Tailscale VPN client** (for example, on general phones, tablets, and laptops).

**Client** &#8658; _Internet_ &#8658; **Tailscale Funnel** (TCP proxy) &#8658;
_VPN_ &#8658; **Tailscale Serve** (HTTPS proxy) &#8594; **HA** (HTTP web-server)

More information: [Enabling HTTPS][tailscale_info_https],
[Tailscale Serve][tailscale_info_serve], [Tailscale Funnel][tailscale_info_funnel].

1. Disable **SSL/TLS** so Home Assistant is accessible through an HTTP
   connection (this is the default). In Home Assistant 2026.8 and newer, this
   setting is at **Settings** -> **System** -> **Network** -> **HTTP server** ->
   **SSL/TLS**.

   **Note:** If you want to use another HTTPS connection to access Home
   Assistant, use a reverse proxy app for that connection instead of enabling
   SSL directly in Home Assistant. The app remains compatible with existing
   Home Assistant SSL configurations, but the extra local encryption is
   unnecessary and adds overhead.

1. Home Assistant, by default, blocks requests from reverse proxies, like the
   Tailscale Serve. To enable it, go to **Settings** -> **System** ->
   **Network** -> **HTTP server** -> **Reverse proxy** and edit the options
   below:
   - Enable `Trust X-Forwarded-For` option.

   - Add "127.0.0.1" to the `Trusted proxies` option.

   Saving these HTTP server changes restarts Home Assistant. In Home Assistant
   2026.8 and newer, reconnect after the restart and select **Confirm** in the
   pending HTTP configuration dialog within five minutes. If it is not
   confirmed, Home Assistant automatically restores the previous settings and
   Tailscale Serve will continue to be rejected.

1. Navigate to the [DNS page][tailscale_dns] of the admin console:
   - Choose a tailnet name.

   - Enable MagicDNS if not already enabled.

   - Under HTTPS Certificates section, click Enable HTTPS.

1. Optionally, if you want to use Tailscale Funnel, navigate to the [Access
   controls page][tailscale_acls] of the admin console:
   - Add the required `funnel` node attribute to the tailnet policy file. See
     [Funnel node attribute][tailscale_info_funnel_node_attribute]
     for more information.

1. Restart the app.

**Note**: After initial setup, it can take up to 10 minutes for the domain to
be publicly available.

**Note:** You should not use the port number in the URL that you used
previously to access Home Assistant. Tailscale Serve and Funnel works on the
default HTTPS port 443 (or the port configured in option `share_on_port`).

**Note:** If you encounter strange browser behaviour or strange error messages,
try to clear all site-related cookies, clear all browser cache, and restart the
browser.

### Option: `share_on_port`

This option lets you specify which port the Tailscale Serve and Funnel features
will use to present your Home Assistant instance on the tailnet and on the
internet.

Only ports 443, 8443, and 10000 are allowed by Tailscale.

Port 443 is used by default.

### Option: `snat_subnet_routes`

This option allows subnet devices to see the traffic originating from the subnet
router, and this simplifies routing configuration.

This option is enabled by default.

To support advanced [Site-to-site networking][tailscale_info_site_to_site] (e.g.
to traverse multiple networks), you can disable this functionality, and follow
steps in the [Site-to-site networking][tailscale_info_site_to_site] guide (Note:
The app already handles "IP address forwarding" and "Clamp the MSS to the
MTU" for you).

**Note:** Only disable this option if you fully understand the implications.
Keep it enabled if preserving the real source IP address is not critical for
your use case.

### Option: `stateful_filtering`

This option enables stateful packet filtering on packet-forwarding nodes (exit
nodes, subnet routers, and app connectors), to only allow return packets for
existing outbound connections. Inbound packets that don't belong to an existing
connection are dropped.

This option is disabled by default.

### Option: `taildrive`

This option allows you to specify which Home Assistant directories you want to
share with other Tailscale nodes using Taildrive.

Only the listed directories are available.

These options are disabled by default.

More information: [Taildrive][tailscale_info_taildrive]

### Option: `taildrop`

This app supports [Tailscale's Taildrop][tailscale_info_taildrop] feature,
which allows you to send files to your Home Assistant instance from other
Tailscale devices.

This option is disabled by default.

Received files are stored in the `/share/taildrop` directory.

### Option: `userspace_networking`

When enabled, Tailscale will not create a `tailscale0` network interface on your
host, i.e. you get one-way access from tailnet clients to your Home Assistant
instance (and optionally the local subnets).

This option is disabled by default.

To be able to address other clients on your tailnet not only by their tailnet IP
but also by their tailnet name, see the "DNS" section of this documentation.

If you want to access other clients on your tailnet even from your local subnet,
follow steps in the [Site-to-site networking][tailscale_info_site_to_site] guide
(Note: The app already handles "IP address forwarding" and "Clamp the MSS to
the MTU" for you). See also the "Option: `snat_subnet_routes`" section of this
documentation.

More information: [Userspace networking
mode][tailscale_info_userspace_networking]

**Note:** In case your local subnets collide with subnet routes within your
tailnet, your local network access has priority, and these addresses won't be
routed toward your tailnet. This will prevent your Home Assistant instance from
losing network connection. This also means that using the same subnet on
multiple nodes for load balancing and failover is impossible with the current
app behavior.

## Network

### Port: `41641/udp`

UDP port to listen on for WireGuard and peer-to-peer traffic.

Use this option (and router port forwarding) if you experience that Tailscale
can't establish peer-to-peer connections to some of your devices (usually behind
CGNAT networks). You can test connections with `tailscale ping
<hostname-or-ip>`.

When not set, an automatically selected port is used by default.

## DNS

When the `userspace_networking` option is disabled, Tailscale provides a DNS (at
100.100.100.100 and fd7a:115c:a1e0::53) to be able to address other clients on
your tailnet not only by their tailnet IP but also by their tailnet name.

More information: [What is 100.100.100.100][tailscale_info_quad100],
[DNS in Tailscale][tailscale_info_dns], [MagicDNS][tailscale_info_magicdns],
[Access a Pi-hole from anywhere][tailscale_info_pi_hole].

1. Check that the `userspace_networking` option is disabled.

1. Check that under **Settings** -> **System** -> **Network** Tailscale's DNS is
   **_not_** configured as a DNS server.

1. In the command line, execute `ha dns options --servers dns://100.100.100.100`.

   **Note:** _This command replaces the existing DNS server list in Home
   Assistant and restarts the internal DNS server. To specify an empty DNS list
   (i.e. to remove `dns://100.100.100.100` from the list), you must use
   `ha dns reset` and `ha dns restart` commands both. This server list is
   additional and queried before the DNS servers specified in Network settings
   above. This configuration is persistent, you have to execute it only once._

**Note:** The only difference compared to the general Tailscale experience, is
that you always have to use the fully qualified domain name instead of only the
device name, i.e. `ping some-tailnet-device.tail1234.ts.net` works, but `ping
some-tailnet-device` does not work.

## Changelog & Releases

Fork releases and their notes are published on the
[GitHub releases page][releases]. The upstream baseline and pull-request audit
are recorded in [FORK_NOTES.md][fork-notes].

## Support

For fork-specific bugs and feature requests, [open an issue][issue] in this
repository. General Home Assistant questions belong in the
[Home Assistant community forum][forum].

## Authors & contributors

This fork is based on the original project by [Franck Nijhof][frenck] and the
[upstream contributors][contributors]. Original commit authorship is retained.

## License

This fork is distributed under the [MIT License][license] and retains the
original copyright and permission notice.

[contributors]: https://github.com/hassio-addons/app-tailscale/graphs/contributors
[fork-notes]: https://github.com/liliainbloom/homeassistant-app-tailscale/blob/main/FORK_NOTES.md
[forum]: https://community.home-assistant.io/
[frenck]: https://github.com/frenck
[headscale]: https://github.com/juanfont/headscale
[issue]: https://github.com/liliainbloom/homeassistant-app-tailscale/issues
[license]: https://github.com/liliainbloom/homeassistant-app-tailscale/blob/main/LICENSE.md
[releases]: https://github.com/liliainbloom/homeassistant-app-tailscale/releases
[tailscale_acls]: https://console.tailscale.com/admin/acls
[tailscale_dns]: https://console.tailscale.com/admin/dns
[tailscale_info_app_connectors]: https://tailscale.com/docs/features/app-connectors
[tailscale_info_dns]: https://tailscale.com/docs/reference/dns-in-tailscale
[tailscale_info_exit_nodes]: https://tailscale.com/docs/features/exit-nodes
[tailscale_info_funnel]: https://tailscale.com/docs/features/tailscale-funnel
[tailscale_info_funnel_node_attribute]: https://tailscale.com/docs/features/tailscale-funnel#funnel-node-attribute
[tailscale_info_https]: https://tailscale.com/docs/how-to/set-up-https-certificates
[tailscale_info_key_expiry]: https://tailscale.com/docs/features/access-control/key-expiry
[tailscale_info_magicdns]: https://tailscale.com/docs/features/magicdns
[tailscale_info_pi_hole]: https://tailscale.com/docs/solutions/block-ads-all-devices-anywhere-using-raspberry-pi
[tailscale_info_quad100]: https://tailscale.com/docs/reference/quad100
[tailscale_info_serve]: https://tailscale.com/docs/features/tailscale-serve
[tailscale_info_site_to_site]: https://tailscale.com/docs/features/site-to-site
[tailscale_info_subnets]: https://tailscale.com/docs/features/subnet-routers
[tailscale_info_tags]: https://tailscale.com/docs/features/tags
[tailscale_info_taildrive]: https://tailscale.com/docs/features/taildrive
[tailscale_info_taildrop]: https://tailscale.com/docs/features/taildrop
[tailscale_info_userspace_networking]: https://tailscale.com/docs/concepts/userspace-networking
[tailscale_machines]: https://console.tailscale.com/admin/machines
