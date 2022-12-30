{ config, pkgs, lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  # prevent some display drivers from crashing
  boot.kernelParams = [ "nomodeset" ];

  # Enable SSH in the boot process.
  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  # Disable automatic login on the local terminal.
  services.getty.autologinUser = lib.mkForce null;

  users.users.nixos = {
    openssh.authorizedKeys.keys = lib.optionals (builtins.pathExists ./authorized-keys.nix)
      import ./authorized-keys.nix;
  };

  networking = {
    wireless = {
      enable = true;
      userControlled.enable = true;
      networks = lib.optionals (builtins.pathExists ./wireless-networks.nix)
        import ./wireless-networks.nix;
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    vim
  ];
}
