#!/bin/bash
setfont ter-132b
clear
echo "Before Phase 1 is run, a root partition must exist and the system must be connected to the internet."
echo "You can use cfdisk to create a root partition and iwctl to connect to Wi-Fi."
echo "This script is for BIOS systems or UEFI systems which support Legacy Boot."
echo "Enter which phase to run: "
read phase
case $phase in
    1)
        echo "WARNING: All data on this partition will be erased!"
        echo "The root partition is located at /dev/___: "
        read part
        mkfs.ext4 /dev/$part
        mount /dev/$part /mnt
        loadkeys uk
        clear

        echo "1) Minimal"
        echo "2) Basic"
        echo "3) Desktop (Plasma)"
        echo "4) Desktop (Hyprland)"
        echo "Select your edition: "
        read pkgsel

        case $pkgsel in
            1)
                pkglist="base linux linux-firmware grub iwd python nano"
                ;;
            2)
                pkglist="base linux linux-firmware screenfetch tree htop plymouth grub iwd python git nano"
                ;;
            3)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth grub dolphin discover plasma-desktop plasma-workspace plasma-meta sddm vlc iwd git nano"
                ;;
            *)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth grub dolphin discover sddm vlc iwd hyprland kitty wofi waybar hyprpaper git nano"
                ;;
        esac

        pacstrap -K /mnt $pkglist
        genfstab -U /mnt >> /mnt/etc/fstab
        cp jdai.sh /mnt
        clear

        echo
        echo "Phase 1 complete!"
        echo "Please run the following commands to continue:"
        echo "arch-chroot /mnt"
        echo "./jdai.sh"
        echo
        ;;
    2)
        echo
        echo "GRUB will be installed to /dev/___: "
        read grubpart
        echo "Name your device: "
        read hname
        echo "Name your user: "
        read name

        ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
        hwclock --systohc
        echo 'en_GB.UTF-8 UTF-8' > /etc/locale.gen
        locale-gen
        echo "LANG=en_GB.UTF-8" > /etc/locale.conf
        echo KEYMAP=uk > /etc/vconsole.conf
        echo $hname > /etc/hostname
        systemctl enable sddm accounts-daemon ip6tables iptables iwd NetworkManager-dispatcher NetworkManager systemd-network-generator systemd-networkd udisks2 upower wpa_supplicant
        clear

        echo "Enter the root password: "
        passwd

        grub-install /dev/$grubpart
        clear

        echo "Edit the GRUB configuration now? (y/n) "
        read egrub
        if [ "$egrub" == "y" ]; then
            nano /etc/default/grub
        fi
        grub-mkconfig -o /boot/grub/grub.cfg
        clear

        useradd -m -G wheel $name
        echo "Enter the password for your user: "
        passwd $name
        clear
        
        echo
        echo "Phase 2 complete!"
        echo "Press Ctrl+Alt+Del to reboot."
        echo
        ;;
    *)
        echo "Exiting..."
        ;;
esac