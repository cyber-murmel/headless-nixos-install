{ pkgs_src ?
    (builtins.fetchGit {
      name = "nixos-22.05-2022_08_27";
      url = "https://github.com/nixos/nixpkgs/";
      ref = "refs/heads/nixos-22.05";
      rev = "f11e12ac6af528c1ba12426ce83cee26f21ceafd";
    })
}:

let
  pkgs = ((import pkgs_src) {});
  nixos = import "${pkgs_src}/nixos" {
    configuration = { ... }: {
      imports = [
        ./image.nix
      ];
    };
  };
in
nixos.config.system.build.isoImage // {
  inherit (nixos) pkgs system config;
}
