{
  description = "Multi-platform NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
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
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask }@inputs:
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

      # Home manager configuration shared across systems
      homeManagerConfig = { lib, pkgs, ... }: {
        imports = [
          ./home/shared.nix
        ];
      };

      # Darwin-specific home manager configuration
      darwinHomeManagerConfig = { lib, pkgs, ... }: {
        imports = [
          ./home/shared.nix
          ./home/darwin.nix
        ];
      };

      linuxHomeManagerConfig = { lib, pkgs, ... }: {
        imports = [
          ./home/shared.nix
          ./home/linux.nix
        ];
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
            echo "  home-manager switch --flake .#cameron@cwill-nixos-jump"
            echo "  home-manager switch --flake .#cameron@work-darwin"
            echo "  home-manager switch --flake .#cameron@personal-darwin"
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
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users.cameron = linuxHomeManagerConfig;
                extraSpecialArgs = { inherit inputs; };
              };
            }
          ] ++ commonModules ++ commonLinuxModules;
        };
      };

      # Darwin configurations (for macOS systems)
      darwinConfigurations = {
        # Work Darwin
        "work-darwin" = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/work-darwin
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
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
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users.cameron = darwinHomeManagerConfig;
                extraSpecialArgs = { inherit inputs; };
              };
            }
          ] ++ commonModules ++ commonDarwinModules;
        };

        # Personal Darwin
        "personal-darwin" = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/personal-darwin
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
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
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users.cameron = { lib, pkgs, ... }: {
                  imports = [
                    ./home/shared.nix
                    ./home/darwin.nix
                  ];
                  # Personal Darwin specific git config
                  programs.git = {
                    userEmail = lib.mkForce "cameron@thewills.net";
                  };
                };
                extraSpecialArgs = { inherit inputs; };
              };
            }
          ] ++ commonModules ++ commonDarwinModules;
        };
      };

      # Standalone home-manager configurations (for non-NixOS systems)
      homeConfigurations = {
        # Work Linux system with standalone home-manager
        "cameron@cwill-nixos-jump" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home/shared.nix
            ./home/linux.nix
            ({ lib, ... }: {
              programs.git = {
                userEmail = lib.mkForce "stephen.will@tanium.com";
              };
            })
          ];
        };

        # Work Darwin with standalone home-manager
        "cameron@work-darwin" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home/shared.nix
            ./home/darwin.nix
          ];
        };

        # Personal Darwin with standalone home-manager
        "cameron@personal-darwin" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home/shared.nix
            ./home/darwin.nix
            # Personal Darwin specific overrides
            ({ lib, ... }: {
              programs.git = {
                userEmail = lib.mkForce "cameron@thewills.net";
              };
            })
          ];
        };
      };
    };
}
