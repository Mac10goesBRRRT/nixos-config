{
  description = "NixOS Configuration";
  
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
  };

  outputs = {self, nixpkgs, ...}: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
	{ security.pki.certificateFiles = [ ./certs/HFD-eduroam-CA.pem ]; }
        { powerManagement.enable = true; }	
      ];
    };
  };
}
