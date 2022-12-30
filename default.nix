{ pkgs_src ?
    (builtins.fetchGit {
      name = "nixos-22.11-2022_12_30";
      url = "https://github.com/nixos/nixpkgs/";
      ref = "refs/heads/nixos-22.11";
      rev = "913a47cd064cc06440ea84e5e0452039a85781f0";
    })
}:

let
  pkgs = ((import pkgs_src) {});
  nixos = import "${pkgs_src}/nixos" {
    configuration = { ... }: {
      imports = [
        ./image.nix
        "${pkgs_src}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        "${pkgs_src}/nixos/modules/installer/cd-dvd/channel.nix"
      ];
    };
  };
in
nixos.config.system.build.isoImage // {
  inherit (nixos) pkgs system config;
}
