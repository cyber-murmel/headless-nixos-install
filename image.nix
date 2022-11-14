{ config, pkgs, lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  # Enable SSH in the boot process.
  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  # Disable automatic login on the local terminal.
  services.getty.autologinUser = lib.mkForce null;

  users.users.nixos = {
    openssh.authorizedKeys.keys = import ./authorizedKeys.nix;
  };

  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    vim
  ];
}
