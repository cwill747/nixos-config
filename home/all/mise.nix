{ config, pkgs, ... }:

{
    programs.mise = {
        enable = true;
        enableFishIntegration = true;
        globalConfig = {
            tools = {
                nodejs = "latest";
                golang = "latest";
                rust = "latest";
                java = "openjdk-24";
                ruby = "latest";
                yarn = "latest";
                python = "latest";
                bazel = "latest";
                pnpm = "latest";
            };
            settings = {
                idiomatic_version_file_enable_tools = [
                    "node"
                ];
            };
        };
    };
}