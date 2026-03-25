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
                clear
                valid=0
                while [[ $valid == 0 ]]; do
                    read -s -p "Enter the encryption password (will not show): " cryptpass
                    if [[ $cryptpass == "" ]]; then
                        clear
                        echo "Password cannot be blank!"
                        echo
                    else
                        echo
                        read -s -p "Confirm password: " cryptconf
                        if [[ $cryptconf == $cryptpass ]]; then
                            clear
                            printf -v cryptstar '%*s' "${#cryptpass}" ''
                            cryptstar=${cryptstar// /*}
                            valid=1
                        else
                            clear
                            echo "Passwords do not match!"
                            echo
                        fi
                    fi
                done
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
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth dolphin discover plasma sddm vlc iwd git nano konsole dialog limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman"
                profile="Desktop (Plasma)"
                loop=0
                ;;
            2)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth dolphin discover vlc iwd hyprland kitty wofi waybar hyprpaper git nano konsole dialog lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman"
                profile="Desktop (Hyprland)"
                loop=0
                ;;
            3)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop xfce4 xfce4-goodies plymouth vlc iwd git nano dialog lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman"
                profile="Desktop (Xfce)"
                loop=0
                ;;
            4)
                pkglist="base linux linux-firmware screenfetch tree htop plymouth iwd python git nano dialog limine sudo efibootmgr networkmanager base-devel blueman"
                profile="Command line"
                loop=0
                ;;
            5)
                pkglist="base linux linux-firmware iwd python nano limine sudo efibootmgr networkmanager base-devel"
                profile="Minimal"
                loop=0
                ;;
            *)
                ;;
        esac
    done
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Install additional packages?"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes"
        echo -e '\e[36m'"[N]" '\e(B\e[m'"No"
        read -n 1 choice
        case $choice in
            y|Y)
                extrapkgs=1
                loop=0
                ;;
            n|N)
                extrapkgs=0
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
    clear
    valid=0
    while [[ $valid == 0 ]]; do
        read -s -p "Enter the root password (will not show): " rootpass
        if [[ $rootpass == "" ]]; then
            clear
            echo
            echo "This will disable the root account! Are you sure?"
            read -p "Enter \"Yes, I understand\" to continue: " rootconf
            if [[ $rootconf == "Yes, I understand" ]]; then
                clear
                valid=1
            else
                clear
            fi
        else
            echo
            read -s -p "Confirm password: " rootconf
            if [[ $rootconf == $rootpass ]]; then
                clear
                printf -v rootstar '%*s' "${#rootpass}" ''
                rootstar=${rootstar// /*}
                valid=1
            else
                clear
                echo "Passwords do not match!"
                echo
            fi
        fi
    done
    clear
    read -p "Name your user (single word, lowercase): " uname
    valid=0
    while [[ $valid == 0 ]]; do
        read -s -p "Enter your user's password (will not show): " pass
        if [[ $pass == "" ]]; then
            clear
            echo "Password cannot be blank!"
            echo
        else
            echo
            read -s -p "Confirm password: " passconf
            if [[ $passconf == $pass ]]; then
                clear
                printf -v star '%*s' "${#pass}" ''
                star=${star// /*}
                valid=1
            else
                clear
                echo "Passwords do not match!"
                echo
            fi
        fi
    done
}

noint(){
    echo
    echo "No internet connection found. Use iwctl to connect to a wireless network."
    exit 1
}

clear
echo
echo "==================================WARNING=================================="
echo "                This script requires an internet connection!               "
echo "                This script is for 64-bit UEFI systems only!               "
echo " This script is intended to be run within the Arch Linux live environment! "
echo "==========================================================================="
echo "                                [Y] Continue                               "
echo "                                 [N] Cancel                                "
read -n 1 choice
#ping -c 1 archlinux.org || noint
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

menu=1
while [[ $menu == 1 ]]; do
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
            echo "Encryption password: $cryptstar"
            ;;
    esac
    echo "Profile: $profile"
    echo "Hostname: $hname"
    if [[ $rootpass == "" ]]; then
        echo "Root account: Disabled"
    else
        echo "Root password: $rootstar"
    fi
    echo "Username: $uname"
    echo "Password: $star"
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
    echo -e '\e[36m'"[5]" '\e(B\e[m'"Change username and authentication"
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
            menu=0
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
chmod +x jdai-usr.sh
echo "ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime" >> jdai-efi-2.sh
echo "hwclock --systohc" >> jdai-efi-2.sh
echo "locale-gen" >> jdai-efi-2.sh
echo "mkinitcpio -P" >> jdai-efi-2.sh
echo "systemctl enable ip6tables iptables iwd NetworkManager-dispatcher NetworkManager systemd-network-generator systemd-networkd wpa_supplicant" >> jdai-efi-2.sh
echo "systemctl enable accounts-daemon" >> jdai-efi-2.sh
echo "systemctl enable udisks2" >> jdai-efi-2.sh
echo "systemctl enable upower" >> jdai-efi-2.sh
echo "systemctl enable sddm" >> jdai-efi-2.sh
echo "systemctl enable lightdm" >> jdai-efi-2.sh
echo "efibootmgr --create --disk /dev/${disk} --part 1 --label \"Arch Linux\" --loader '\\EFI\\arch-limine\\BOOTX64.EFI' --unicode" >> jdai-efi-2.sh
echo "cp jdai-usr.sh /home/$uname" >> jdai-efi-2.sh
echo "cd /home/$uname" >> jdai-efi-2.sh
echo "su $uname -c ./jdai-usr.sh" >> jdai-efi-2.sh

echo "git clone https://aur.archlinux.org/yay.git" >> jdai-usr.sh
echo "cd yay" >> jdai-usr.sh
echo "makepkg -si --noconfirm" >> jdai-usr.sh
if [[ $extrapkgs == 1 ]]; then
    echo "yay -S --noconfirm firefox firefox-i18n-uk firefox-ublock-origin flatpak neofetch screenfetch fastfetch tree htop btop partitionmanager plymouth vlc packagekit base-devel ark waybar hyprpaper thunar wofi konsole dialog" >> jdai-usr.sh
fi
if [[ $profile == "Desktop (Hyprland)" ]]; then
    echo "sudo pacman -Sy --noconfirm nerd-fonts" >> jdai-usr.sh
    echo "cd .." >> jdai-usr.sh
    echo "git clone https://github.com/JaredDinosaur/hyprconf" >> jdai-usr.sh
    echo "cd hyprconf" >> jdai-usr.sh
    echo "mkdir ~/.config/hypr" >> jdai-usr.sh
    echo "mkdir ~/.config/kitty" >> jdai-usr.sh
    echo "cp hyprland.conf ~/.config/hypr" >> jdai-usr.sh
    echo "cp kitty.conf ~/.config/kitty" >> jdai-usr.sh
    echo "sudo cp config.jsonc /etc/xdg/waybar" >> jdai-usr.sh
    echo "sudo cp style.css /etc/xdg/waybar" >> jdai-usr.sh
fi

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
        printf "%s" "$cryptpass" | cryptsetup -v --batch-mode luksFormat /dev/$root -
        printf "%s" "$cryptpass" | cryptsetup open /dev/$root root -
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
        sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap consolefont modconf block filesystems fsck)/' /mnt/etc/mkinitcpio.conf
        ;;
    1)
        sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt sd-encrypt filesystems fsck)/' /mnt/etc/mkinitcpio.conf
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
sed -i 's/^# \(%wheel ALL=(ALL:ALL) NOPASSWD: ALL\)/\1/' /mnt/etc/sudoers

cp ./* /mnt
if [[ $rootpass == "" ]]; then
    arch-chroot /mnt passwd -l root
else
    arch-chroot /mnt chpasswd <<< "root:$rootpass"
fi
arch-chroot /mnt useradd -m -G wheel $uname
arch-chroot /mnt chpasswd <<< "$uname:$pass"
arch-chroot /mnt bash ./jdai-efi-2.sh

echo
echo
echo
echo "Done! You may now reboot."
