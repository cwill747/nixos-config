{ pkgs, ... }:

{
  # Common variables that can be used throughout the configuration
  _module.args = {
    # Standard user name across all systems
    user = "cameron";

    # Platform-aware home directory path
    homeDir = if pkgs.stdenv.isDarwin then "/Users/cameron" else "/home/cameron";

    # Additional utility variables can be added here
    # For example:
    # configDir = "${homeDir}/.config";
    # localBinDir = "${homeDir}/.local/bin";
  };
}
