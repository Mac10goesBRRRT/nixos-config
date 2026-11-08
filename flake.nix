{
  description = "NixOS Configuration";
  
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.ceres = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ./modules/networking.nix
        
        inputs.sops-nix.nixosModules.sops
	      { 
          security.pki.certificateFiles = [ ./certs/HFD-eduroam-CA.pem ]; 
          powerManagement.enable = true; 
          environment.sessionVariables = {
            EDITOR  = "code --wait";
          };
        }

        home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; }; #If you want access to inputs in your home.nix
            users.janos = ./home/ceres/home.nix; # replace <USERNAME> with your actual username
          };
        }
      ];
    };
  };
}
