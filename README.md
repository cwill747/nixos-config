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
   curl --proto '=https' --tlsv1.2 -sSf https://install.determinate.systems/nix | sh
   ```

2. **For macOS**: Install nix-darwin
   ```bash
   nix run nix-darwin -- switch --flake .#work-darwin
   ```

### Installation

1. **Clone this repository:**
   ```bash
   git clone git@github.com:cwill747/nixos-config.git ~/.config/nixos
   cd ~/.config/nixos
   ```

2. **Choose your installation method based on your system:**

#### macOS (nix-darwin)

```bash
darwin-rebuild switch --flake .#$(hostname)
```

#### Ubuntu/Linux with Nix Package Manager (Home Manager only)

For regular Ubuntu/Linux systems where you've installed just the Nix package manager (not full NixOS):

```bash
nix run home-manager/master -- switch --flake .#$(whoami)@$(hostname)
```

**Note**: `nixos-rebuild` is NOT available when you install Nix on Ubuntu - that command only exists on full NixOS systems. Use Home Manager instead.

#### Full NixOS System (if running NixOS as your OS)

Only use this if you're running NixOS as your operating system (not Ubuntu with Nix installed):

```bash
sudo nixos-rebuild switch --flake .#$(hostname)
```

## Configuration Structure

```
.
├── flake.nix                 # Main flake configuration
├── modules/
│   └── shared/
│       └── default.nix       # Shared system configuration
├── home/
│   ├── shared.nix           # Shared home-manager configuration
│   ├── neovim.nix           # Comprehensive neovim configuration
│   ├── darwin.nix           # macOS-specific home configuration
│   └── linux.nix            # Linux-specific home configuration
└── hosts/
    ├── ubuntu/
    │   ├── default.nix      # Ubuntu system configuration
    │   └── hardware-configuration.nix
    ├── work-mac/
    │   └── default.nix      # Work Mac configuration
    └── personal-mac/
        └── default.nix      # Personal Mac configuration
```

## Fish Shell Configuration

The Fish shell configuration is automatically installed and configured with:

- **Git prompt** with branch status and upstream indicators
- **Aliases** for common commands (`vim` → `nvim`, `asdf` → `mise`, etc.)
- **Functions** from your existing setup:
  - `cleanpycs` - Clean Python cache files
  - `gr` - Go to git repository root
  - `t` - Create and enter temporary directory
  - `varga` - Clean up merged git branches
  - `gf` - Download file to temporary location
- **Plugins**:
  - `z` - Directory jumping
  - `fzf.fish` - Fuzzy finding integration
  - `pure` - Minimal prompt
- **Environment variables** and path configuration
- **Platform-specific paths** (Homebrew on macOS, Linux-specific paths)

Fish is automatically set as the default shell on all systems.

## Neovim Configuration

The Neovim configuration is fully translated from your existing setup and includes:

- **LSP Support**: Language servers for Lua, Python, TypeScript, and Rust
- **Completion**: Full autocomplete with nvim-cmp and language server integration
- **Fuzzy Finding**: Telescope for file/text search (replacing fzf functionality)
- **Git Integration**: Fugitive, GitGutter, and git-related keybindings
- **Syntax Highlighting**: Treesitter with all grammars
- **File Management**: NERDTree for file exploration
- **Text Manipulation**: Surround, multiple cursors, commenting, etc.
- **Movement**: EasyMotion and enhanced search with incsearch
- **Appearance**: Gruvbox theme, Lightline status bar, custom highlights
- **All Key Mappings**: Space as leader, all your custom keybindings preserved

**Key Features Preserved:**
- `<Space>` as leader key
- `jk` to escape insert mode
- `q` disabled (no recording)
- Window/tab management (`<Leader>w*`, `<Leader>t*`)
- Git shortcuts (`<Leader>g*`)
- Telescope shortcuts (`<Leader>f*`)
- All movement and editing customizations

**Language Servers Included:**
- `lua-language-server` (Lua)
- `pyright` (Python)
- `typescript-language-server` (JavaScript/TypeScript)
- `rust-analyzer` (Rust)

**Note**: Some plugins that weren't available in nixpkgs were removed:
- `scratch-vim`, `vim-autoswap`, `TaskList-vim`, `matchit-zip`
- `html5-vim`, `scss-syntax-vim` (may be available, excluded for now)
- `vim-conflicted`, `markdown-preview.nvim` (not in nixpkgs)

The core functionality and all essential plugins are preserved.

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

## Features by Platform

| Feature | macOS | Ubuntu/Linux with Nix | Full NixOS |
|---------|-------|----------------------|------------|
| Fish Shell | ✅ | ✅ | ✅ |
| Home Manager | ✅ | ✅ | ✅ |
| System Management | nix-darwin | ❌ (Home Manager only) | NixOS |
| Homebrew Integration | ✅ | ❌ | ❌ |
| GUI Applications | Homebrew Casks | System package manager | Nixpkgs |
| System Defaults | ✅ | ❌ | ✅ |

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

## Contributing

1. Make changes in appropriate configuration files
2. Test on your target platform
3. Ensure flake check passes: `nix flake check`
4. Update documentation if needed

## Notes

- The Ubuntu hardware configuration is a placeholder - generate the real one with `nixos-generate-config`
- SSH keys need to be added to the respective host configurations
- Git configuration is set up with work email as default, personal email for personal Mac
- Some applications may require additional manual setup after installation

## License

This configuration is provided as-is for personal use. Adapt as needed for your setup.
