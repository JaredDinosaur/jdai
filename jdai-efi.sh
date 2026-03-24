#!/bin/bash
set -euo pipefail
setlocale(){
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
                reg="GB"
                loop=0
                ;;
            2)
                keys="--default"
                reg="US"
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
        read -p "The disk to install to is /dev/" disk
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
                manpart=1
                loop=0
                ;;
            *)
                ;;
        esac
    done
    if [[ "$disk" == *"d"* ]]; then
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
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth dolphin discover plasma sddm vlc iwd git nano konsole dialog limine sudo efibootmgr"
                profile="Desktop (Plasma)"
                loop=0
                ;;
            2)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth dolphin discover vlc iwd hyprland kitty wofi waybar hyprpaper git nano konsole dialog lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings limine sudo efibootmgr"
                profile="Desktop (Hyprland)"
                loop=0
                ;;
            3)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop xfce4 xfce4-goodies plymouth vlc iwd git nano dialog lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings limine sudo efibootmgr"
                profile="Desktop (Xfce)"
                loop=0
                ;;
            4)
                pkglist="base linux linux-firmware screenfetch tree htop plymouth iwd python git nano dialog limine sudo efibootmgr"
                profile="Command line"
                loop=0
                ;;
            5)
                pkglist="base linux linux-firmware iwd python nano limine sudo efibootmgr"
                profile="Minimal"
                loop=0
                ;;
            *)
                ;;
        esac
    done
}

sethostname(){
    clear
    read -p "Name your machine (letters, numbers and dashes): " hname
}

user(){
    read -p "Name your user (single word, lowercase): " uname
}

noint(){
    echo
    echo "No internet connection found. Use iwctl to connect to a wireless network."
    exit 1
}

echo "==================================WARNING=================================="
echo "                This script requires an internet connection!               "
echo "                This script is for 64-bit UEFI systems only!               "
echo " This script is intended to be run within the Arch Linux live environment! "
echo "==========================================================================="
echo "                                [Y] Continue                               "
echo "                                 [N] Cancel                                "
read -n 1 choice
ping -c 1 archlinux.org || noint
case $choice in
    y|Y)
        clear
        ;;
    *)
        exit
        ;;
esac

sed -i "s/#Color/Color/" /etc/pacman.conf
sed -i "s/ParallelDownloads = 5/ParallelDownloads = 1/" /etc/pacman.conf
pacman -Sy --noconfirm hwinfo
setlocale
diskpart
pkgs
sethostname
user

loop=1
while [[ $loop == 1 ]]; do
    clear
    echo "Region: $reg"
    echo "Disk: $disk"
    case $manpart in
        0)
            echo "Partitioning: Automatic"
            ;;
        1)
            echo "Partitioning: Manual"
            ;;
    esac
    echo "Filesystem: $rootfs"
    case $crypt in
        0)
            echo "Encryption: Disabled"
            ;;
        1)
            echo "Encryption: Enabled"
            ;;
    esac
    echo "Profile: $profile"
    echo "Hostname: $hname"
    echo "Username: $uname"
    echo
    echo -e '\e[3m'"Install with these options?"'\e(B\e[m'
    echo
    echo "-------------------------------------"
    echo
    echo -e '\e[36m'"[Y]" '\e(B\e[m'"Begin installation"
    echo -e '\e[36m'"[N]" '\e(B\e[m'"Cancel installation"
    echo
    echo -e '\e[36m'"[1]" '\e(B\e[m'"Change locale"
    echo -e '\e[36m'"[2]" '\e(B\e[m'"Change partitioning"
    echo -e '\e[36m'"[3]" '\e(B\e[m'"Change packages"
    echo -e '\e[36m'"[4]" '\e(B\e[m'"Change hostname"
    echo -e '\e[36m'"[5]" '\e(B\e[m'"Change username"
    read -n 1 choice
    case $choice in
        y|Y)
            clear
            echo "Starting installation in 5 seconds..."
            sleep 1
            clear
            echo "Starting installation in 4 seconds..."
            sleep 1
            clear
            echo "Starting installation in 3 seconds..."
            sleep 1
            clear
            echo "Starting installation in 2 seconds..."
            sleep 1
            clear
            echo "Starting installation in 1 second..."
            sleep 1
            clear
            loop=0
            ;;
        n|N)
            exit
            ;;
        1)
            setlocale
            ;;
        2)
            diskpart
            ;;
        3)
            pkgs
            ;;
        4)
            sethostname
            ;;
        5)
            user
            ;;
        *)
            ;;
    esac
done

chmod +x jdai-efi-2.sh
echo "ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime" >> jdai-efi-2.sh
echo "hwclock --systohc" >> jdai-efi-2.sh
echo "locale-gen" >> jdai-efi-2.sh
echo "systemctl enable sddm accounts-daemon ip6tables iptables iwd NetworkManager-dispatcher NetworkManager systemd-network-generator systemd-networkd udisks2 upower wpa_supplicant lightdm" >> jdai-efi-2.sh
echo "mkinitcpio -P" >> jdai-efi-2.sh
echo "clear" >> jdai-efi-2.sh
echo "echo 'Set the root password: '" >> jdai-efi-2.sh
echo "passwd" >> jdai-efi-2.sh
echo "efibootmgr --create --disk /dev/${disk} --part 1 --label \"Arch Linux\" --loader '\\EFI\\arch-limine\\BOOTX64.EFI' --unicode" >> jdai-efi-2.sh
echo "useradd -m -G wheel $uname" >> jdai-efi-2.sh
echo "echo 'Set your user password: '" >> jdai-efi-2.sh
echo "passwd $uname" >> jdai-efi-2.sh
echo "echo 'Press any key to edit the sudoers config...'" >> jdai-efi-2.sh
echo "read -n 1" >> jdai-efi-2.sh
echo "EDITOR=nano visudo" >> jdai-efi-2.sh

case $manpart in
    0)
        ram=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024)}')
        fdisk /dev/$disk <<EOF
g
n
1

+1G
y
n
2

+${ram}M
y
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
        clear
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
echo "en_${reg}.UTF-8 UTF-8" > /mnt/etc/locale.gen
echo "LANG=en_${reg}.UTF-8" > /mnt/etc/locale.conf
if [[ $reg == "GB" ]]; then
    echo "KEYMAP=uk" > /mnt/etc/vconsole.conf
fi
echo $hname > /mnt/etc/hostname
mkdir -p /mnt/boot/EFI/arch-limine
cp /mnt/usr/share/limine/BOOTX64.EFI /mnt/boot/EFI/arch-limine
uuid=$(blkid -s UUID -o value /dev/$root)
case $crypt in
    0)
        sed -i "s/block filesystems fsck/block keyboard filesystems fsck/" /mnt/etc/mkinitcpio.conf
        ;;
    1)
        sed -i "s/block filesystems fsck/block keyboard plymouth encrypt filesystems fsck/" /mnt/etc/mkinitcpio.conf
        ;;
esac
touch /mnt/boot/EFI/arch-limine/limine.conf
echo "timeout: 0" >> /mnt/boot/EFI/arch-limine/limine.conf
echo "" >> /mnt/boot/EFI/arch-limine/limine.conf
echo "/Arch Linux" >> /mnt/boot/EFI/arch-limine/limine.conf
echo "    protocol: linux" >> /mnt/boot/EFI/arch-limine/limine.conf
echo "    path: boot():/vmlinuz-linux" >> /mnt/boot/EFI/arch-limine/limine.conf
case $crypt in
    0)
        echo "    cmdline: root=UUID=${uuid} zswap.enabled=0 rw rootfstype=${rootfs} quiet splash" >> /mnt/boot/EFI/arch-limine/limine.conf
        ;;
    1)
        echo "    cmdline: cryptdevice=UUID=${uuid}:root root=/dev/mapper/root rw rootfstype=${rootfs} quiet splash" >> /mnt/boot/EFI/arch-limine/limine.conf
esac
echo "    module_path: boot():/initramfs-linux.img" >> /mnt/boot/EFI/arch-limine/limine.conf
sed -i "s/#Color/Color/" /mnt/etc/pacman.conf
sed -i "s/ParallelDownloads = 5/ParallelDownloads = 1/" /mnt/etc/pacman.conf
sed -i "s/#[multilib]/[multilib]/" /mnt/etc/pacman.conf

cp ./* /mnt
arch-chroot /mnt bash "./jdai-efi-2.sh"

echo
echo
echo
echo "Done! You may now reboot."
