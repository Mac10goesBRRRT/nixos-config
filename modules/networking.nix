{ config, ... }:

{
  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      environmentFiles = [
        config.sops.secrets."wifi-mobile-env".path
        config.sops.secrets."wifi-home-env".path
        config.sops.secrets."wifi-fuas-env".path
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
    };
  };

  sops.secrets = {
    "wifi-mobile-env" = { };
    "wifi-home-env" = { };
    "wifi-fuas-env" = { };
  };
}