# Multi-Platform NixOS Configuration

A modern NixOS configuration using flakes that supports multiple platforms and machines with shared configuration where possible.

Features:

- ✅ Fish shell with comprehensive configuration
- ✅ Neovim with full LSP, completion, and plugin setup
- ✅ Home Manager integration
- ✅ Platform-specific configurations (Darwin/Linux)
- ✅ Shared packages and settings
- ✅ Hostname-based configuration selection
- ✅ Nix flakes support

## Quick Start

### Prerequisites

1. **Install Nix with flakes support:**
   ```bash
   # Install Nix using the Determinate Systems installer (recommended)
   curl -fsSL https://install.determinate.systems/nix | sh -s -- install
   ```

Answer "no" when asked if you want to install determinate nix. We want upstream
nix.

### Installation

1. **Clone this repository:**
```bash
git clone git@github.com:cwill747/nixos-config.git ~/.config/nixos
cd ~/.config/nixos
```

2. Configure Attic (optional)

To pull bits fast, configure attic with:

```shell
nix-shell -p github:zhaofengli/attic#attic-client
attic login central <attic_url> <attic_token>
```

3. **Build initial configuration:**

#### macOS (nix-darwin)

For the first install, `darwin-rebuild` won't be available. Build with:

```shell
nix build .#darwinConfigurations.personal-darwin.system
```

Then run
```shell
sudo ./result/activate
```

#### Ubuntu/Linux with Nix Package Manager (Home Manager only)

For regular Ubuntu/Linux systems where you've installed just the Nix package manager (not full NixOS):

```bash
nix run home-manager/master -- switch --flake .#$(whoami)@$(hostname)
```

If you have issues with building and SSL certs - 

```shell
sudo rm /etc/ssl/certs/ca-certificates.crt
sudo ln -s /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
```

#### Full NixOS System (if running NixOS as your OS)

Only use this if you're running NixOS as your operating system (not Ubuntu with Nix installed):

```bash
sudo nixos-rebuild switch --flake .#$(hostname)
```

## Customization

### Adding New Packages

1. **System-wide packages**: Add to `modules/shared/default.nix`
2. **User packages**: Add to `home/shared.nix`
3. **Platform-specific**: Add to `home/darwin.nix` or `home/linux.nix`
4. **Host-specific**: Add to the respective host configuration

### Adding New Machines

1. Create a new host configuration in `hosts/`
2. Add the configuration to `flake.nix` outputs
3. Set up user configuration with appropriate username

### Modifying Fish Configuration

Fish configuration is managed through Nix in `home/shared.nix`. You can:
- Add aliases to `programs.fish.shellAliases`
- Add functions to `programs.fish.functions`
- Modify shell initialization in `programs.fish.shellInit`
- Add plugins to `programs.fish.plugins`

## Updating

```bash
# Update flake inputs
nix flake update

# Apply updates (choose appropriate command for your system)
darwin-rebuild switch --flake .#$(hostname)          # macOS
sudo nixos-rebuild switch --flake .#$(hostname)      # NixOS
home-manager switch --flake .#$(whoami)@$(hostname)  # Home Manager only
```

## Troubleshooting

### `nixos-rebuild` command not found on Ubuntu
If you get "command not found" for `nixos-rebuild` on Ubuntu, this is expected! You've installed the Nix package manager on Ubuntu, not full NixOS. Use Home Manager instead:

```bash
# This is what you should use on Ubuntu with Nix installed:
nix run home-manager/master -- switch --flake .#$(whoami)@$(hostname)

# NOT this (only works on full NixOS systems):
sudo nixos-rebuild switch --flake .#$(hostname)
```

### Flake Evaluation Errors
```bash
# Check flake syntax
nix flake check

# Build without switching to test
nix build .#darwinConfigurations.$(hostname).system      # macOS
nix build .#nixosConfigurations.$(hostname).config.system.build.toplevel  # NixOS
```

### Fish Shell Issues
```bash
# Test fish configuration
fish --command "echo 'Fish is working'"

# Check which fish is being used
which fish

# Reload fish configuration
fish -c "source ~/.config/fish/config.fish"
```

### Platform Detection
The configuration automatically detects the platform and applies appropriate settings. If you encounter issues:

1. Check hostname matches configuration: `hostname`
2. Verify system architecture: `uname -m`
3. Ensure correct flake target is used

## Development

To test changes without applying:

```bash
# Enter development shell
nix develop

# Build specific configuration
nix build .#darwinConfigurations.$(hostname).system

# Check all configurations
nix flake check
```

## License

This configuration is provided as-is for personal use. Adapt as needed for your setup.
