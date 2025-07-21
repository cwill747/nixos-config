{ lib, pkgs, inputs, agenix, ... }:

{
    services.sshd.enable = true;
    users.users.root.password = "nixos";
    services.openssh.settings.PermitRootLogin = lib.mkOverride 999 "yes";
    virtualisation.diskSize = 500 * 1024;
}