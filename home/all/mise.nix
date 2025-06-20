{ config, pkgs, ... }:

{
    programs.mise = {
        enable = true;
        enableFishIntegration = true;
        globalConfig = {
            tools = {
                nodejs = "latest";
                golang = "1.20.5";
                rust = "1.87.0";
                java = "openjdk-24";
                ruby = "3.4.4";
                yarn = "1.22.22";
                python = "3.13.3";
                bazel = "8.2.1";
                pnpm = "latest";
            };
        };
    };
}