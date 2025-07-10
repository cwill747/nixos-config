{
  description = "Multi-platform NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:cwill747/nixpkgs/cam/main";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional: for macOS homebrew integration
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    agenix = {
      url = "github:ryantm/agenix";
    };

    secrets = {
      url = "git+ssh://git@github.com/cwill747/nixos-secrets.git";
      flake = false;
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.2-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, agenix, secrets, lix-module }@inputs:
    let
      # System architectures
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
      allSystems = linuxSystems ++ darwinSystems;

      # Helper function to generate configurations for all systems
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems f;

      # Common configuration shared across all systems
      commonModules = [
        ./modules/shared
      ];

      commonDarwinModules = [
        ./modules/darwin
      ];

      commonLinuxModules = [
        ./modules/linux
      ];

      # Centralized git email configurations
      gitEmails = {
        work = "stephen.will@tanium.com";
        personal = "cameron@thewills.net";
      };

      # Shared homebrew configuration for all Darwin systems
      commonHomebrewConfig = {
        nix-homebrew = {
          enable = true;
          user = "cameron";
          taps = {
            "homebrew/homebrew-core" = homebrew-core;
            "homebrew/homebrew-cask" = homebrew-cask;
            "homebrew/homebrew-bundle" = homebrew-bundle;
          };
          mutableTaps = false;
          autoMigrate = true;
        };
      };

      # Shared home-manager base configuration
      baseHomeManagerConfig = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = { inherit inputs; };
      };

      # Function to create Darwin home-manager config with git email override
      mkDarwinHomeManagerConfig = gitEmail: { lib, pkgs, ... }: {
        imports = [
          ./home/shared.nix
          ./home/darwin.nix
          ./modules/shared/utils.nix
          agenix.homeManagerModules.default
        ];
        programs.git = {
          userEmail = lib.mkForce gitEmail;
        };
      };

      # Function to create Linux home-manager config with git email override
      mkLinuxHomeManagerConfig = gitEmail: { lib, pkgs, ... }: {
        imports = [
          ./home/shared.nix
          ./home/linux.nix
          ./modules/shared/utils.nix
          agenix.homeManagerModules.default
        ];
        programs.git = {
          userEmail = lib.mkForce gitEmail;
        };
      };

      # Function to create a base Darwin system configuration
      mkDarwinSystem = { system, hostPath, homeManagerUser }: nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          hostPath
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            inherit (commonHomebrewConfig) nix-homebrew;
            home-manager = baseHomeManagerConfig // {
              users.cameron = homeManagerUser;
            };
          }
        ] ++ commonModules ++ commonDarwinModules;
      };

    in {
      # Development shells
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          nativeBuildInputs = with nixpkgs.legacyPackages.${system}; [
            git
            vim
            nixVersions.stable
          ];
          shellHook = ''
            echo "NixOS Configuration Development Shell"
            echo "Available commands:"
            echo "  nixos-rebuild switch --flake .#cwill-nixos-jump"
            echo "  darwin-rebuild switch --flake .#work-darwin"
            echo "  darwin-rebuild switch --flake .#personal-darwin"
            echo "  home-manager switch --flake .#cameron@work-linux"
          '';
        };
      });

      # NixOS configurations (for Linux systems)
      nixosConfigurations = {
        # Work Linux machine (cwill-nixos-jump)
        "cwill-nixos-jump" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/work-linux
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            lix-module.nixosModules.default
            {
              home-manager = baseHomeManagerConfig // {
                users.cameron = mkLinuxHomeManagerConfig gitEmails.work;
              };
            }
          ] ++ commonModules ++ commonLinuxModules;
        };

        "attic" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/work-linux
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            lix-module.nixosModules.default
            {
              home-manager = baseHomeManagerConfig // {
                users.cameron = mkLinuxHomeManagerConfig gitEmails.personal;
              };
            }
          ] ++ commonModules ++ commonLinuxModules;
        };

        "common-iso" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            agenix.nixosModules.default
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
            "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
            ./modules/shared
            ./modules/linux
          ];
        };
      };

      # Darwin configurations (for macOS systems)
      darwinConfigurations = {
        # Work Darwin
        "work-darwin" = mkDarwinSystem {
          system = "aarch64-darwin";
          hostPath = ./hosts/work-darwin;
          homeManagerUser = mkDarwinHomeManagerConfig gitEmails.work;
        };

        # Personal Darwin
        "personal-darwin" = mkDarwinSystem {
          system = "aarch64-darwin";
          hostPath = ./hosts/personal-darwin;
          homeManagerUser = mkDarwinHomeManagerConfig gitEmails.personal;
        };
      };

      # Standalone home-manager configurations (for non-NixOS systems)
      homeConfigurations = {
        "cameron@work-linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home/shared.nix
            ./home/linux.nix
            agenix.homeManagerModules.default
            ./home/all/fonts.nix
            (mkLinuxHomeManagerConfig gitEmails.work)
          ];
        };
      };
    };
}
