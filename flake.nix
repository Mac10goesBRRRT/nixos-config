{
  description = "NixOS Configuration"
  
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
  };

  outputs = {self, nixpkgs, ...}: {
    nixosConfiguration.nixos = nixpgks.bli.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}
