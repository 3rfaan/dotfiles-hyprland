# Arch Linux Install & Ricing

> [!WARNING]
> This repository is no longer maintained. [I switched to sway and a minimal setup](https://github.com/3rfaan/dotfiles).

This is a full installation and customization guide for Arch Linux.

ℹ️ **If you already have a running Arch system with the necessary packets installed, you can go to the [Quick Ricing](#quick-ricing) section.**

## Preview

![Preview 1](./preview_1.png)
![Preview 2](./preview_2.png)
![Preview 3](./preview_3.png)
![Preview 4](./preview_4.png)

⚠️ _Caution:_ If you are installing Arch on a virtual machine you won't have the blur effect like in the image above because there is no hardware acceleration.

## Arch Installation Guide

### Download ISO image

Go to the download page of the official Arch Linux webpage and download the ISO image from one of the mirrors: https://archlinux.org/download/.

### Prepare an installation medium

Check this Arch Wiki article to prepare an installation medium, e.g. a USB flash drive or an optical disc: https://wiki.archlinux.org/title/installation_guide#Prepare_an_installation_medium

### Console keyboard layout

Find out which keyboard layout you are using and then set it using `loadkeys`:

```
$ ls /usr/share/kbd/keymaps/**/*.map.gz
$ loadkeys de_CH-latin1
```

### Connect to the web

To connect to the web we use _iwctl_:

To start _iwctl_ run the following command:

```
$ iwctl
```

We can then look for the device name:

```
[iwd]# device list
```

Then we can use the device name to scan for networks _(Note: This command won't output anything!)_:

```
[iwd]# station <device-name> scan
```

Now we can list all available networks:

```
[iwd]# station <device-name> get-networks
```

Finally, we connect to a network:

```
[iwd]# station <device-name> connect <SSID>
```

Check if you successfully established a connection by pinging the Google server:

```
$ ping 8.8.8.8
```

### Console font

This step is not really necessary, but the Terminus font may appear cleaner than the default one:

```
$ setfont Lat2-Terminus16
```

### Partitioning

#### UEFI or BIOS?

Run the following command:

```
$ ls /sys/firmware/efi/efivars
```

**If the command shows the directory without error, then the system is booted in [UEFI mode](#uefi-with-gpt). Else you have to use [BIOS mode](#bios-with-mbr).**

Check the name of the hard disk:

```
fdisk -l
```

Use the name (in my case _sda_) to start the `fdisk` partitioning tool:

```
fdisk /dev/sda
```

#### UEFI with GPT

Press <kbd>g</kbd> to create a new GUID Partition Table (GPT).

We will do it according to the example layout of the Arch wiki:

| Mount point | Partition                   | Partition type | Suggested size      |
| ----------- | --------------------------- | -------------- | ------------------- |
| /mnt/boot   | /dev/_efi_system_partition_ | uefi           | At least 300 MiB    |
| [SWAP]      | /dev/_swap_partition_       | swap           | More than 512 MiB   |
| /mnt        | /dev/_root_partition_       | linux          | Remainder of device |

##### Create boot partition

1. Press <kbd>n</kbd>.
1. Press <kbd>Enter</kbd> to select the default partition number.
1. Press <kbd>Enter</kbd> to use the default first sector.
1. Enter _+300M_ for the last sector.
1. Press <kbd>t</kbd> and choose 1 and write _uefi_.

##### Create swap partition

1. Press <kbd>n</kbd>.
1. Press <kbd>Enter</kbd> to select the default partition number.
1. Press <kbd>Enter</kbd> to use the default first sector.
1. Enter _+512M_ for the last sector.
1. Press <kbd>t</kbd> and choose 2 and write _swap_.

##### Create root partition

1. Press <kbd>n</kbd>.
1. Press <kbd>Enter</kbd> to select the default partition number.
1. Press <kbd>Enter</kbd> to use the default first sector.
1. Enter <kbd>Enter</kbd> to use the default last sector.
1. Press <kbd>t</kbd> and choose 3 and write _linux_.

⚠️\ **When you are done partitioning don't forget to press <kbd>w</kbd> to save the changes!**

After partitioning check if the partitions have been created using `fdisk -l`.

##### Partition formatting

```
$ mkfs.ext4 /dev/<root_partition>
$ mkswap /dev/<swap_partition>
$ mkfs.fat -F 32 /dev/<efi_system_partition>
```

##### Mounting the file system

```
$ mount /dev/<root_partition> /mnt
$ mount --mkdir /dev/<efi_system_partition> /mnt/boot
$ swapon /dev/<swap_partition>
```

#### BIOS with MBR

Press <kbd>o</kbd> to create a new MBR partition table.

We will do it according to the example layout of the Arch wiki:

| Mount point | Partition             | Partition type | Suggested size      |
| ----------- | --------------------- | -------------- | ------------------- |
| [SWAP]      | /dev/_swap_partition_ | swap           | More than 512 MiB   |
| /mnt        | /dev/_root_partition_ | linux          | Remainder of device |

##### Create swap partition

1. Press <kbd>n</kbd>.
1. Press <kbd>Enter</kbd> to select the default partition number.
1. Press <kbd>Enter</kbd> to select the default primary partition type.
1. Press <kbd>Enter</kbd> to use the default first sector.
1. Enter _+512M_ for the last sector.
1. Press <kbd>t</kbd> and choose 1 and write _swap_.

##### Create root partition

1. Press <kbd>n</kbd>.
1. Press <kbd>Enter</kbd> to select the default partition number.
1. Press <kbd>Enter</kbd> to select the default primary partition type.
1. Press <kbd>Enter</kbd> to use the default first sector.
1. Enter <kbd>Enter</kbd> to use the default last sector.
1. Press <kbd>t</kbd> and choose 2 and write _linux_.

##### Make partition bootable

Press <kbd>a</kbd> and choose 2 to make the root partition bootable.

⚠️\ **When you are done partitioning don't forget to press <kbd>w</kbd> to save the changes!**

After partitioning check if the partitions have been created using `fdisk -l`.

##### Partition formatting

```
$ mkfs.ext4 /dev/<root_partition>
$ mkswap /dev/<swap_partition>
```

##### Mounting the file system

```
$ mount /dev/<root_partition> /mnt
$ swapon /dev/<swap_partition>
```

### Package install

For a minimal system download and install these packages:

```
$ pacstrap -K /mnt base base-devel linux linux-firmware e2fsprogs networkmanager sof-firmware git neovim man-db man-pages texinfo
```

ℹ️ If you are installing Arch Linux on a computer with **ARM architecture** add the following to the above `pacstrap` command:

```
archlinuxarm-keyring
```

⚠️ If you get errors due to key then do the following:

1. Initialize _pacman_ keys and populate them:

```
pacman-key --init
pacman-key --populate
```

2. Synchronize Arch keyring:

```
archlinux-keyring-wkd-sync
```

### Last steps

#### Generate fstab file

```
$ genfstab -U /mnt >> /mnt/etc/fstab
```

#### Change root into new system

```
$ arch-chroot /mnt
```

#### Set time zone

```
$ ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
$ hwclock --systohc
```

#### Localization

Edit _/etc/locale.gen_ and uncomment _en_US.UTF-8 UTF-8_ and other needed locales. Generate the locales by running:

```
$ locale-gen
```

Create _/etc/locale.conf_ and set the _LANG_ variable according to your preferred language:

```
LANG=de_CH.UTF-8
```

Create _/etc/vconsole.conf_ and set the following variables according to your preferred language:

```
KEYMAP=de_CH-latin1
FONT=Lat2-Terminus16
```

For higher resolution displays like widescreens, `Lat2-Terminus16` might be too small. Set `FONT=ter-132n` from the [terminus-font](https://archlinux.org/packages/?name=terminus-font) package:


#### Network configurations

Create _/etc/hostname_ and type any name you wish as your hostname:

```
arch
```

Edit _/etc/hosts_ like this:

```
127.0.0.1 localhost
::1 localhost
127.0.1.1 arch (your host name here!)
```

#### Initramfs

```
$ mkinitcpio -P
```

#### Root password

Set a new password for root:

```
$ passwd
```

#### Bootloader

##### UEFI

Install `grub` and `efibootmgr`:

```
$ pacman -S grub efibootmgr
```

Run the following command:

```
$ grub-install --efi-directory=/boot --bootloader-id=GRUB
```

Then create a **GRUB** config file:

```
$ grub-mkconfig -o /boot/grub/grub.cfg
```

##### BIOS

Install `grub`:

```
$ pacman -S grub
```

Check using `fdisk -l` to see the name of the disk (**not partition!**) and run the following command:

```
$ grub-install /dev/sdX
```

_/dev/sdX_ could for example stand for _/dev/sda_ (**not _/dev/sda1_!**)

Then create a **GRUB** config file:

```
$ grub-mkconfig -o /boot/grub/grub.cfg
```

#### Final step

Exit out of the chroot environment by typing `exit` or pressing <kbd>Ctrl</kbd>+<kbd>d</kbd>.

Unmount all the partitions:

```
$ umount -R /mnt
```

Then type `poweroff` and remove the installation disk.

## System-related Configurations

### Enable network connection

To use _pacman_ you first have to have a working internet connection by enabling _NetworkManager_:

```
$ systemctl start NetworkManager
$ systemctl enable NetworkManager
```

Now we can connect to the web using _NetworkManager_:

First, we list all nearby Wi-Fi networks:

```
$ nmcli device wifi list
```

We can then connect to a network:

```
$ nmcli device wifi connect <SSID> password <password>
```

Check if you receive data from the Google Server by running this command:

```
$ ping 8.8.8.8
```

### Update the system

First things first: Update the system!

```
$ pacman -Syu
```

### `sudo` Command

Install the `sudo` command:

```
$ pacman -S sudo
```

### Add your personal user account

```
$ useradd -m -g users -G wheel,storage,power,video,audio,input <your username>
$ passwd <your username>
```

#### Grant root access to our user

```
$ EDITOR=nvim visudo
```

Uncomment the following line in order to use the `sudo` command without password prompt:

```
%wheel ALL=(ALL) NOPASSWD: ALL
```

You can then log in as your newly created user:

```
$ su <your username>
```

If you wish to have the default XDG directories (like Downloads, Pictures, Documents etc.) do:

```
$ sudo pacman -S xdg-user-dirs
$ xdg-user-dirs-update
```

### Install AUR package manager

To install [yay](https://github.com/Jguer/yay):

```
$ cd $HOME && mkdir aur
$ cd aur
$ git clone https://aur.archlinux.org/yay.git
$ cd yay
$ makepkg -si
```

### Guest tools

#### SPICE support on guest (for UTM)

This will enhance graphics and improve support for multiple monitors or clipboard sharing.

```
$ sudo pacman -S spice-vdagent xf86-video-qxl
```

#### Guest additions (for VirtualBox)

This will enhance graphics and improve support for multiple monitors or clipboard sharing.

```
$ sudo pacman -S virtualbox-guest-utils
```

### Sound

```
$ sudo pacman -S pavucontrol
$ sudo pacman -S alsa-utils alsa-plugins
$ sudo pacman -S pipewire wireplumber
```

### Network

```
$ sudo pacman -S openssh
$ sudo pacman -S iw wpa_supplicant
$ sudo pacman -S dhcpcd
```

#### Enable SSH, DHCP:

```
$ sudo systemctl enable sshd
$ sudo systemctl enable dhcpcd
```

### Bluetooth

```
$ sudo pacman -S bluez bluez-utils
$ sudo systemctl enable bluetooth
```

### Pacman

To beautify Pacman use:

```
$ sudo nvim /etc/pacman.conf
```

Uncomment `Color` and add below it `ILoveCandy`.

ℹ️ If you have a good internet connection, you can uncomment the option `ParallelDownloads = 5`.

### Enable SSD Trim

```
$ sudo systemctl enable fstrim.timer
```

### Enable Time Synchronization

```
$ sudo pacman -S ntp
```

```
$ sudo systemctl enable ntpd
```

Then enable NTP:

```
$ timedatectl set-ntp true
```

## Graphical User Interface (GUI) Settings

In this repository you will find config files for `Hyprland` and `sway`. If you want fancy effects and animations go with `Hyprland`. For a more minimal setup I'd suggest `sway`.

### Hyprland

```
$ sudo pacman -S hyprland hyprpaper hyprlock hypridle
```

```
$ yay -S wlogout
```

- _hyprland_: A compositor for Wayland
- _hyprpaper_: Set wallpaper in Hyprland
- _hyprlock_: Lockscreen
- _hypridle_: DPMS, turning screen off after timeout period

- _wlogout_: Menu for logging out, rebooting, shutting down, etc

⚠️ _Caution:_ If you don't have an NVIDIA graphics card you have to delete the environment variables concerning NVIDIA in _~/.config/hyprland/hyprland.conf_ later when configuring the system!

#### Hyprcursor

The `hyprcursor` utility should already be installed because of `hyprland`. We just need some cursor themes:

```
$ yay -S bibata-cursor-theme-bin
```

### Sway

```
$ sudo pacman -S sway swaybg swayidle
```

- _sway_: A compositor for Wayland
- _swaybg_: Set wallpaper in sway
- _swayidle_: DPMS, turning screen off after timeout period

Download these programs to work with the default `sway` config or change them in `~/.config/sway/config`:

```
$ sudo pacman -S foot wmenu grim
```

- _foot_: Terminal emulator
- _wmenu_: Program launcher
- _grim_: Screenshot utility

### Drivers

**Intel**:

```
sudo pacman -S mesa intel-media-driver libva-intel-driver vulkan-intel
```

**NVIDIA**:

```
sudo pacman -S nvidia
```

### Fonts

```
$ sudo pacman -S noto-fonts ttf-opensans ttf-jetbrains-mono-nerd
```

Emojis:

```
$ sudo pacman -S noto-fonts-emoji
```

To support Asian letters:

```
$ sudo pacman -S noto-fonts-cjk
```

### Shell

```
$ sudo pacman -S zsh
```

Change default shell to zsh:

```
$ chsh -s $(which zsh)
```

### Terminal

```
$ sudo pacman -S alacritty kitty
```

### Editor

_Neovim_ should already be installed after running the _pacstrap_ command in the installation process.

```
$ sudo pacman -S code nano
```

- _code_: Visual Studio Code OSS
- _gedit_: Gnome Editor
- _nano_: Terminal editor

### Program Launcher

```
$ sudo pacman -S wofi
```

### Status Bar

```
$ sudo pacman -S waybar
```

To set display brightness through `waybar` install `brightnessctl`:

```
$ sudo pacman -S brightnessctl
```

### File Manager

```
$ sudo pacman -S yazi nemo
```

For image previews `alacritty` needs this dependency (kitty is built-in):

```
$ sudo pacman -S ueberzugpp
```

Catppuccin theme:

- [catppuccin-macchiato.yazi](https://github.com/yazi-rs/flavors/tree/main/catppuccin-macchiato.yazi)

Install these plugins for best experience:

- [full-border.yazi](https://github.com/yazi-rs/plugins/tree/main/full-border.yazi)
- [relative-motions.yazi](https://github.com/dedukun/relative-motions.yazi)
- [bookmarks.yazi](https://github.com/dedukun/bookmarks.yazi)

### Image Viewer

```
$ sudo pacman -S imv
```

### Browser

```
$ sudo pacman -S firefox chromium
```

### Screenshot

```
$ yay -S hyprshot
```

### Screen Recorder

```
$ yay -S obs-studio-git
```

Required for screen capture:

```
$ sudo pacman -S xdg-desktop-portal-hyprland
```

You may have to install additional packages. Please follow these instructions: https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580

### Media Player

```
$ sudo pacman -S vlc
```

### PDF Viewer

```
$ sudo pacman -S zathura zathura-pdf-mupdf
```

### Color Temperature Adjustment

```
$ sudo pacman -S gammastep
```

### GTK Dark Theme

Download the Adwaita themes:

```
$ sudo pacman -S gnome-themes-extra
```

To make GTK applications (e.g. _nemo_) use dark theme, execute the following commands:

```
$ gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
$ gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

### Other Tools

#### Programming Languages

These languages are needed for _Mason_, the LSP package manager in _Neovim_:

```
$ sudo pacman -S nodejs npm rust go ruby rubygems php composer lua luarocks python python-pip dotnet-runtime dotnet-sdk julia java-runtime-common java-environment-common jdk-openjdk
```

#### CLI utilities

```
$ sudo pacman -S bottom curl fastfetch fzf gzip htop lazygit starship tar tmux unzip wget
```

```
$ sudo pacman -S tree-sitter tree-sitter-cli
```

```
$ yay -S pfetch-rs
```

- _bottom_: System monitoring
- _curl_: Fetching packages from the web
- _fastfetch_: System information
- _fzf_: Fuzzy finder
- _gzip_: Enzipping/Unzipping
- _htop_: CLI task manager
- _lazygit_: Git CLI tool
- _starship_: Cross-shell prompt
- _tar_: Enzipping/Unzipping
- _tmux_: Terminal mutliplexer
- _unzip_: Enzipping/Unzipping
- _wget_: Fetching packages from the web

- _tree-sitter_ & _tree-sitter-cli_: Real syntax highlighting in Neovim

- _pfetch_: More concise system information

#### Alternatives to traditional commands

```
$ sudo pacman -S bat eza fd ripgrep tldr
```

- _bat_: Alternative to _cat_ command
- _eza_: Alternative to _ls_ command (fork of `exa`)
- _fd_: Alternative to _find_ command
- _ripgrep_: Alternative to _grep_ command
- _tldr_: Commands cheat sheet

### Reboot

When done installing the necessary packages, run the `sudo reboot` command.

### Quick Ricing

You can either clone the repository and move the files manually to your _~/.config_ directory or you could use the [auto-ricer](https://github.com/3rfaan/autoricer):

<p align="center">
    <a href="https://github.com/3rfaan/autoricer"><img src="https://raw.githubusercontent.com/3rfaan/hyprforest-installer/main/hyprforest_logo.png" /></a>
</p>

## Manual Installs

- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

## Troubleshooting

### Missing seatd socket

If you get the following warning:

"[libseat/backend/seatd.c:70] Could not connect to socket /run/seatd.sock: no such file or directory"

Then open `/etc/environment` and add the following line:

```
LIBSEAT_BACKEND=logind
```

### Unable to load such font with such kernel version

If you get the warning "Unable to load such font with such kernel version" when starting up then edit the `/etc/mkinitcpio.conf` file as follows:

1. Check for the line `BINARIES=` and set it to _setfont_:

```
BINARIES=(setfont)
```

2. Check for the line `HOOKS=` and replace `udev` with `systemd` and `keymap` and `consolefont` with `sd-vconsole`:

```
HOOKS=(base systemd autodetect modconf kms keyboard sd-vconsole block filesystems fsck)
```

Then run:

```
mkinitcpio -P
```

### Missing Firmware when (re-)generating presets

When `mkinitcpio -P` outputs warnings about missing firmware you can install this AUR packet:

```
$ yay -S mkinitcpio-firmware
```

Then run:

```
mkinitcpio -P
```

### org.freedesktop.Notifications: No such file or directory

Install the package `notification-daemon`:

```
$ sudo pacman -S notification-daemon
```

Create the file _org.freedesktop.Notifications.service_ in `/usr/share/dbus-1/services` with following content:

```
[D-BUS Service]
Name=org.freedesktop.Notifications
Exec=/usr/lib/notification-daemon-1.0/notification-daemon
```

### No such interface org.freedesktop.portal.settings

Install the following package:

```
$ sudo pacman -S xdg-desktop-portal-gtk
```
