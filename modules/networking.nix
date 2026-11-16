{ config, pkgs, ... }:

{
  networking.hostName = "ceres"; # Define your hostname.
  networking.firewall.checkReversePath = "loose";

  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-openvpn ];
    ensureProfiles = {
      environmentFiles = [
        config.sops.secrets."wifi-mobile-env".path
        config.sops.secrets."wifi-home-env".path
        config.sops.secrets."wifi-fuas-env".path
        config.sops.secrets."wg-vpn-home".path
      ];

      profiles.mobile = {
        connection = {
          id = "$MOBILE_SSID";
          type = "wifi";
        };
        wifi = {
          ssid = "$MOBILE_SSID";
          mode = "infrastructure";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$MOBILE_PSWD";
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };

      profiles.home = {
        connection = {
          id = "$HOME_SSID";
          type = "wifi";
        };
        wifi = {
          ssid = "$HOME_SSID";
          mode = "infrastructure";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$HOME_PSWD";
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };

      profiles.eduroam = {
        connection = {
          id = "eduroam";
          type = "wifi";
          autoconnect = true;
        };
        wifi = {
          ssid = "eduroam";
          mode = "infrastructure";
        };
        wifi-security = {
          key-mgmt = "wpa-eap";
        };
        "802-1x" = {
          eap = "peap;";
          phase2-auth = "mschapv2";
          domain-suffix-match = "hs-fulda.de";
          system-ca-certs = true;
          anonymous-identity = "anonymous@hs-fulda.de";
          identity = "$FUAS_IDENT";
          password = "$FUAS_PSWD";
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };

      # wg-vpn-home must contain environment variables (not a wg-quick config):
      # WG_HOME_PRIVATE_KEY=...
      # WG_HOME_PUBLIC_KEY=...
      # WG_HOME_ENDPOINT=vpn.example.org:51820
      # WG_HOME_ADDRESS=10.0.0.2/32
      # WG_HOME_ALLOWED_IPS=192.168.178.0/24;
      # Allowed IPs are semicolon-separated; use 0.0.0.0/0 for a full IPv4 tunnel.
      profiles.wg-vpn-home = {
        connection = {
          id = "wg-vpn-home";
          type = "wireguard";
          interface-name = "wg0";
          autoconnect = false;
        };
        wireguard = {
          private-key = "$WGVPN_PRIV";
          private-key-flags = 0;
        };
        "wireguard-peer.XzKFy4hKXPbErZRYYZwcA/BZznEFWOBR5deUB18OrXQ=" = {
          endpoint = "$WGVPN_ENDP";
          allowed-ips = "0.0.0.0/0";
          persistent-keepalive = 25;
          # If required by the server, add WG_HOME_PRESHARED_KEY to the secret:
          # preshared-key = "$WG_HOME_PRESHARED_KEY";
          # preshared-key-flags = 0;
        };
        ipv4 = {
          method = "manual";
          address1 = "192.168.5.4/32";
          # Optional: add WG_HOME_DNS to the secret and enable VPN DNS.
          dns = "192.168.5.1";
        };
        # Add a manual IPv6 address here if the VPN supports IPv6.
        ipv6.method = "disabled";
      };
    };
  };

  sops.secrets = {
    "wifi-mobile-env" = { };
    "wifi-home-env" = { };
    "wifi-fuas-env" = { };
    "wg-vpn-home" = { };
  };
}
