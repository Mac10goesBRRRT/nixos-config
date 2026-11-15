{
  services.pipewire.wireplumber.extraConfig."99-no-camera" = {
    "wireplumber.profiles".main."hardware.video-capture" = "disabled";
  };
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
