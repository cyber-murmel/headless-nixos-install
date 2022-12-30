# Headless NixOS Install

## Building the image
1. Change the public SSH key in [authorizedKeys.nix](authorizedKeys.nix).
2. Change the wireless networks in [wireless-networks.nix](wireless-networks.nix).
3. Build and burn the image.
```shell
nix-build
```

## Installing NixOS
1. Boot the machine from the image and SSH into it.

### Partitioning and formatting
This is based on the [NixOS manual](https://nixos.org/manual/nixos/stable/#sec-installation-partitioning-formatting).

```
┌────────┬───────────────────────┐
│EFI     │Root Partition         │
│System  ├───────────────────────┤
│Partiton│Linux Unified Key Setup│<-(optional)
├────────┴───────────────────────┤
│                DISK            │
└────────────────────────────────┘
```

Determine it device with `lsblk`. In this case it's `/dev/sda`.
```
export DEVICE=/dev/sda
```

#### Partitioning
```shell
# Create a GPT partition table
sudo parted ${DEVICE} -- mklabel gpt
# Add the root partition
sudo parted -a optimal ${DEVICE} -- mkpart primary 512MiB 100%
# Add the boot partition
sudo parted ${DEVICE} -- mkpart ESP fat32 1MiB 512MiB
sudo parted ${DEVICE} -- set 2 esp on
# Update /etc/fstab
sudo partprobe ${DEVICE}
```

#### Formatting

##### Boot partition
```
sudo mkfs.fat -F 32 -n boot /dev/disk/by-partlabel/ESP
```

##### Option A: Encrypted root partition
```shell
# setup disk encryption for root partition
# - choose strong password
# - DON'T write it down
# - also don't forget it
sudo cryptsetup luksFormat --cipher aes-xts-plain64 --key-size 512 /dev/disk/by-partlabel/primary
# open encrypted device
sudo cryptsetup open /dev/disk/by-partlabel/primary crypted
# format partition
sudo mkfs.ext4 -L nixos /dev/mapper/crypted
```

##### Option B: Plain root partition
```shell
sudo mkfs.ext4 -L nixos /dev/disk/by-partlabel/primary
```

#### Mounting
```shell
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-partlabel/ESP /mnt/boot
```

### Installation

#### Generate initial configuration files
```shell
sudo nixos-generate-config --root /mnt
# inspect files
cat /mnt/etc/nixos/hardware-configuration.nix
cat /mnt/etc/nixos/configuration.nix
```

#### Edit configuration
Edit the configuration to your requirements.

If you configuration makes use of [Home Manager](https://github.com/nix-community/home-manager), add the channel.

```shell
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz home-manager
sudo nix-channel --update
```

Optionally you can make use of one of these configs:
- [server-nixos-configuration](https://github.com/cyber-murmel/server-nixos-configuration)
- [workstation-nixos-configuration](https://github.com/cyber-murmel/workstation-nixos-configuration)


#### Run and check installation
```shell
sudo nixos-install --no-root-passwd
# enter to check
# e.g. check that the users are set up correctly
sudo nixos-enter
```

#### Exit and shut down
```shell
exit
sudo poweroff
```
