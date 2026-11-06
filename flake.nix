{
  description = "NixOS Configuration";
  
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, nixpkgs, ...}@inputs: {
    nixosConfigurations.ceres = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        inputs.sops-nix.nixosModules.sops
	      { 
          security.pki.certificateFiles = [ ./certs/HFD-eduroam-CA.pem ]; 
          powerManagement.enable = true; 
          environment.sessionVariables = {
            EDITOR  = "code --wait";
          };
        }
      ];
    };
  };
}
