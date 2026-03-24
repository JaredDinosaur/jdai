#!/bin/bash
set -e
locale(){
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Select your locale: "'\e(B\e[m'
        echo
        echo -e '\e[36m'"[1]" '\e(B\e[m'"English - United Kingdom" '\e[35m'"(default)"
        echo -e '\e[36m'"[2]" '\e(B\e[m'"English - United States"
        read -n 1 choice
        case $choice in
            1)
                keys="uk"
                loop=0
                ;;
            2)
                keys="--default"
                loop=0
                ;;
            *)
                ;;
        esac
    done
}

diskpart(){
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo "Available disks:"
        echo
        hwinfo --disk --short
        echo
        echo "Recommended minimum disk space: 64GB for VMs, 128GB for real hardware"
        read disk -p "The disk to install to is /dev/"
        echo
        echo -e '\e[3m'"WARNING: The contents of this disk will be erased!"'\e(B\e[m'
        echo -e '\e[3m'"Double check that you have selected the correct disk!"'\e(B\e[m'
        echo -e '\e[3m'"This cannot be undone! Are you sure you want to continue?"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[Y]" '\e(B\e[m'"I understand, continue"
        echo -e '\e[36m'"[N]" '\e(B\e[m'"Choose another disk"
        echo -e '\e[36m'"[Q]" '\e(B\e[m'"Cancel the installation"
        read -n 1 choice
        case $choice in
            y|Y)
                loop=0
                ;;
            q|Q)
                exit
                ;;
            *)
                ;;
        esac
    done
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Choose a partitioning method:"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[1]" '\e(B\e[m'"Automatic partition layout"
        echo -e '\e[36m'"[2]" '\e(B\e[m'"Manual configuration"
        read -n 1 choice
        case $choice in
            1)
                manpart=0
                loop=0
                ;;
            2)
                loop=0
                ;;
            *)
                ;;
        esac
    done
    if [[ "$disk" == "sd"* ]]; then
        root="${disk}3"
        boot="${disk}1"
        swap="${disk}2"
    else
        root="${disk}p3"
        boot="${disk}p1"
        swap="${disk}p2"
    fi
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Choose a root filesystem:"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[1]" '\e(B\e[m'"ext4" '\e[35m'"(default)"
        echo -e '\e[36m'"[2]" '\e(B\e[m'"btrfs"
        echo -e '\e[36m'"[3]" '\e(B\e[m'"xfs"
        read -n 1 choice
        case $choice in
            1)
                rootfs="ext4"
                loop=0
                ;;
            2)
                rootfs="btrfs"
                loop=0
                ;;
            3)
                rootfs="xfs"
                loop=0
                ;;
            *)
                ;;
        esac
    done
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Would you like to encrypt your root partition?"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes"
        echo -e '\e[36m'"[N]" '\e(B\e[m'"No"
        read -n 1 choice
        case $choice in
            y|Y)
                crypt=1
                loop=0
                ;;
            n|N)
                crypt=0
                loop=0
                ;;
            *)
                ;;
        esac
    done
}

pkgs(){
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Choose a set of packages:"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[1]" '\e(B\e[m'"Desktop with Plasma" '\e[35m'"(default)"
        echo -e '\e[36m'"[2]" '\e(B\e[m'"Desktop with Hyprland"
        echo -e '\e[36m'"[3]" '\e(B\e[m'"Desktop with Xfce"
        echo -e '\e[36m'"[4]" '\e(B\e[m'"Command line"
        echo -e '\e[36m'"[5]" '\e(B\e[m'"Minimal"
        read -n 1 choice
        case $choice in
            1)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth dolphin discover plasma sddm vlc iwd git nano konsole dialog limine"
                loop=0
                ;;
            2)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth dolphin discover vlc iwd hyprland kitty wofi waybar hyprpaper git nano konsole dialog lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings limine"
                loop=0
                ;;
            3)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop xfce4 xfce4-goodies plymouth vlc iwd git nano dialog lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings limine"
                loop=0
                ;;
            4)
                pkglist="base linux linux-firmware screenfetch tree htop plymouth iwd python git nano dialog limine"
                loop=0
                ;;
            5)
                pkglist="base linux linux-firmware iwd python nano limine"
                loop=0
                ;;
            *)
                ;;
        esac
    done
}

echo "==================================WARNING=================================="
echo "                This script requires an internet connection!               "
echo "                This script is for 64-bit UEFI systems only!               "
echo " This script is intended to be run within the Arch Linux live environment! "
echo "==========================================================================="
echo "                                [Y] Continue                               "
echo "                                 [N] Cancel                                "
read -n 1 choice
case $choice in
    y|Y)
        clear
        ;;
    *)
        exit
        ;;
esac
locale
pacman -Sy hwinfo
diskpart
pkgs
case $manpart in
    0)
        ram=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024)}')
        swapend=$((1024 + ram))
        fdisk /dev/$disk #<<EOF
        g
        n
        1
        +1G
        n
        2
        +${ram}M
        n
        3
        w
        EOF
        ;;
    1)
        echo
        echo "The following partitions are required:"
        echo
        echo " No. | Type | Size"
        echo "-----|------|----------------------------"
        echo "   1 | Boot | 256MB to 1GB"
        echo "   2 | Swap | Same as RAM"
        echo "   3 | Root | 8GB min, 32GB+ recommended"
        echo 
        echo "Press any key to open cfdisk."
        read -n 1
        cfdisk
        ;;
esac
case $crypt in
    0)
        mkfs.$rootfs /dev/$root
        mount /dev/$root /mnt
        ;;
    1)
        cryptsetup -v luksFormat /dev/$root
        cryptsetup open /dev/$root root
        mkfs.$rootfs /dev/mapper/root
        mount /dev/mapper/root /mnt
        ;;
esac
mkfs.fat -F32 /dev/$boot
mount --mkdir /dev/$boot /mnt/boot
mkswap /dev/$swap
swapon /dev/$swap
pacstrap -K /mnt $pkglist
genfstab -U /mnt >> /mnt/etc/fstab
cp ./* /mnt
arch-chroot /mnt bash "jdai-efi-2.sh"
