{
  description = "NixOS Configuration";
  
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs"; # this line is optional, prevents downloading two versions of nixpkgs but disables cache
    };

    # Flyline Input hinzufügen
    flyline.url = "github:HalFrgrd/flyline";
  };

  outputs = {self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.ceres = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ./modules/networking.nix
        inputs.flyline.nixosModules.default

        inputs.sops-nix.nixosModules.sops
	      { 
          security.pki.certificateFiles = [ ./certs/HFD-eduroam-CA.pem ]; 
          powerManagement.enable = true; 
          environment.sessionVariables = {
            EDITOR  = "code --wait";
          };
          programs.niri.enable = true;
          programs.nh = {
            enable = true;
            clean.enable = true;
            clean.extraArgs = "--keep-since 4d --keep 3";
            flake = "/home/janos/nixos-config"; # sets NH_OS_FLAKE variable for you
          };
        }

        home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = { inherit inputs; }; #If you want access to inputs in your home.nix
            users.janos = ./home/ceres/home.nix; # replace <USERNAME> with your actual username
            sharedModules = [
                inputs.noctalia.homeModules.default
              ];
          };
        }
      ];
    };
  };
}
