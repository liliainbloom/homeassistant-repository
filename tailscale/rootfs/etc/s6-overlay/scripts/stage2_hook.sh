#!/command/with-contenv bashio
# shellcheck shell=bash
export LOG_FD
# ==============================================================================
# Home Assistant Community App: Tailscale
# S6 Overlay stage2 hook to customize services
# ==============================================================================

declare options
declare proxy funnel proxy_and_funnel_port
declare share_service_name
declare taildrive_config taildrive_legacy
declare tags

readonly MAGIC_DNS_IPV4="100.100.100.100"
readonly MAGIC_DNS_IPV6="fd7a:115c:a1e0::53"
declare dns
declare invalid_dns_config
declare userspace_networking

# This is to execute potentially failing supervisor api functions within conditions,
# where set -e is not propagated inside the function and bashio relies on set -e for api error handling
function try {
    set +e
    (set -e; "$@")
    declare -gx TRY_ERROR=$?
    set -e
}

# Load app options, even deprecated one to upgrade
options=$(bashio::addon.options)

# Upgrade configuration from 'proxy', 'funnel' and 'proxy_and_funnel_port' to 'share_homeassistant' and 'share_on_port'
# This step can be removed in a later version
proxy=$(bashio::jq "${options}" '.proxy | select(.!=null)')
funnel=$(bashio::jq "${options}" '.funnel | select(.!=null)')
proxy_and_funnel_port=$(bashio::jq "${options}" '.proxy_and_funnel_port | select(.!=null)')
# Upgrade to share_homeassistant
if bashio::var.true "${proxy}"; then
    if bashio::var.true "${funnel}"; then
        bashio::addon.option 'share_homeassistant' 'funnel'
        bashio::log.info "Successfully migrated proxy and funnel options to share_homeassistant: funnel"
    else
        bashio::addon.option 'share_homeassistant' 'serve'
        bashio::log.info "Successfully migrated proxy and funnel options to share_homeassistant: serve"
    fi
fi
# Upgrade to share_on_port
if bashio::var.has_value "${proxy_and_funnel_port}"; then
    try bashio::addon.option 'share_on_port' "^${proxy_and_funnel_port}"
    if ((TRY_ERROR)); then
        bashio::log.warning "The proxy_and_funnel_port option value '${proxy_and_funnel_port}' is invalid, proxy_and_funnel_port option is dropped, using default port."
    else
        bashio::log.info "Successfully migrated proxy_and_funnel_port option to share_on_port: ${proxy_and_funnel_port}"
    fi
fi

# Migrate the former add-on directory names to Home Assistant's app terminology.
# Keep the supported Supervisor mount types; config.yaml maps those mounts to
# the new paths explicitly.
taildrive_legacy=$(bashio::jq "${options}" \
    '(.taildrive // {}) | (has("addons") or has("addon_configs"))')
if bashio::var.true "${taildrive_legacy}"; then
    taildrive_config=$(bashio::jq "${options}" '
        (.taildrive // {})
        | if has("addons") and (has("local_apps") | not) then .local_apps = .addons else . end
        | if has("addon_configs") and (has("app_configs") | not) then .app_configs = .addon_configs else . end
        | del(.addons, .addon_configs)')
    bashio::app.option 'taildrive' "^${taildrive_config}"
    bashio::log.info 'Successfully migrated Taildrive share names to local_apps and app_configs'
fi
# Remove previous options
if bashio::var.has_value "${proxy}"; then
    bashio::log.info 'Removing deprecated proxy option'
    bashio::addon.option 'proxy'
fi
if bashio::var.has_value "${funnel}"; then
    bashio::log.info 'Removing deprecated funnel option'
    bashio::addon.option 'funnel'
fi
if bashio::var.has_value "${proxy_and_funnel_port}"; then
    bashio::log.info 'Removing deprecated proxy_and_funnel_port option'
    bashio::addon.option 'proxy_and_funnel_port'
fi

# Rename changed options
tags=$(bashio::jq "${options}" '.tags | select(.!=null)')
if bashio::var.has_value "${tags}"; then
    try bashio::addon.option 'advertise_tags' "^${tags}"
    if ((TRY_ERROR)); then
        bashio::log.warning "The tags option value is invalid, tags option is dropped, using default no advertise_tags."
        bashio::log.warning "The invalid tags option value is: '${tags}'"
    else
        bashio::log.info "Successfully renamed tags option to advertise_tags"
    fi
    bashio::addon.option 'tags'
fi

# Remove deprecated share_service_name option
share_service_name=$(bashio::jq "${options}" '.share_service_name | select(.!=null)')
if bashio::var.has_value "${share_service_name}"; then
    bashio::log.info 'Removing deprecated share_service_name option'
    bashio::addon.option 'share_service_name'
fi

# Home Assistant's local DNS forwarding must not point back to MagicDNS. Doing
# so creates a DNS loop before the proxy services can start. Fall back to
# userspace networking so the app remains reachable and the configuration can
# be corrected from Home Assistant.
userspace_networking=$(bashio::config "userspace_networking")
invalid_dns_config="false"
for dns in $(bashio::dns.locals); do
    if bashio::var.equals "${dns}" "dns://${MAGIC_DNS_IPV4}" || \
        bashio::var.equals "${dns}" "dns://${MAGIC_DNS_IPV6}"
    then
        bashio::log.warning \
            "Do not configure MagicDNS's IP address (${dns:6}) as DNS server under Settings -> System -> Network"
        invalid_dns_config="true"
    fi
done
if bashio::var.true "${invalid_dns_config}"; then
    bashio::log.warning \
        "Due to the invalid networking DNS configuration, userspace_networking will be enabled to disable MagicDNS"
    bashio::log.warning \
        "Please check the app documentation's DNS section, then disable userspace_networking and restart the app"
    bashio::app.option 'userspace_networking' 'true'
    userspace_networking="true"
fi

# MagicDNS related service dependencies:
#
#   user
#   |  ˅
#   |  magicdns-proxies-reconfigurator
#   ˅  ˅
#   magicdns-ingress-proxy
#   |  ˅
#   |  magicdns-proxies-configurator
#   |  ˅
#   |  post-tailscaled
#   |  ˅
#   |  tailscaled
#   |  ˅
#   |  magicdns-egress-proxy
#   ˅  ˅
#   init-magicdns-proxies
#
if bashio::var.true "${userspace_networking}"; then
    # Disable MagicDNS egress and ingress proxy related services when userspace_networking is enabled
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/magicdns-proxies-reconfigurator
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/magicdns-ingress-proxy
    rm /etc/s6-overlay/s6-rc.d/tailscaled/dependencies.d/magicdns-egress-proxy
elif bashio::config.false "accept_dns"; then
    # Disable MagicDNS egress and ingress proxy reconfigurator when userspace_networking is disabled but accept_dns is also disabled
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/magicdns-proxies-reconfigurator
fi

# Disable protect-subnets service when userspace-networking is enabled or accepting routes is disabled
if bashio::var.true "${userspace_networking}" || \
    bashio::config.false "accept_routes";
then
    rm /etc/s6-overlay/s6-rc.d/post-tailscaled/dependencies.d/protect-subnets
fi

# If local subnets are not configured in advertise_routes, do not wait for the local network to be ready to collect subnet information
if ! bashio::config "advertise_routes" | grep -Fxq "local_subnets"; then
    rm /etc/s6-overlay/s6-rc.d/post-tailscaled/dependencies.d/local-network
fi

# Disable forwarding service when userspace-networking is enabled
if bashio::var.true "${userspace_networking}"; then
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/forwarding
fi

# Disable mss-clamping service when userspace-networking is enabled
if bashio::var.true "${userspace_networking}"; then
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/mss-clamping
fi

# Disable taildrop service when it has been explicitly disabled
if bashio::config.false 'taildrop'; then
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/taildrop
fi

# Disable share-homeassistant service when it has been explicitly disabled
if bashio::config.equals 'share_homeassistant' 'disabled'; then
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/share-homeassistant
fi
