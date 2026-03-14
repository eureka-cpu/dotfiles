# This file isn't generated like it is on nixos, but rather to distinguish
# hardware features for this machine.
{ config, lib, pkgs, modulesPath, ... }:

{
  # Use the fingerprint scanner instead of password for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # The default Nix build user ID range has been adjusted for
  # compatibility with macOS Sequoia 15. Your _nixbld1 user currently has
  # UID 301 rather than the new default of 351.
  #
  # You can automatically migrate the users with the following command:
  #
  # curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- repair sequoia --move-existing-users
  #
  # If you have no intention of upgrading to macOS Sequoia 15, or already
  # have a custom UID range that you know is compatible with Sequoia, you
  # can disable this check by setting:
  ids.uids.nixbld = 300;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
}
