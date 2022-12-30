{ config, pkgs, lib, ... }:

{
  # prevent some display drivers from crashing
  boot.kernelParams = [ "nomodeset" ];

  # Enable SSH in the boot process.
  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

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
  systemd.services.wpa_supplicant.wantedBy = lib.mkForce [ "multi-user.target" ];

  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    vim
  ];
}
