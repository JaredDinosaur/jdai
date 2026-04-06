loop=1
while [[ $loop == 1 ]]; do
    clear
    echo -e '\e[3m'"Do you use a wired (Ethernet) or wireless (Wi-Fi) internet connection?"'\e(B\e[m'
    echo
    echo -e '\e[36m'"[1]" '\e(B\e[m'"Wired"
    echo -e '\e[36m'"[2]" '\e(B\e[m'"Wireless"
    read -n 1 choice
    case $choice in
        1)
            loop=0
            ;;
        2)
            nmtui
            loop=0
            ;;
        *)
            ;;
    esac
done

loop=1
while [[ $loop == 1 ]]; do
    clear
    echo -e '\e[3m'"Choose a set of packages:"'\e(B\e[m'
    echo
    echo -e '\e[36m'"[1]" '\e(B\e[m'"Desktop with Plasma" '\e[35m'"(default)"
    echo -e '\e[36m'"[2]" '\e(B\e[m'"Desktop with Hyprland"
    echo -e '\e[36m'"[3]" '\e(B\e[m'"Desktop with Xfce"
    echo -e '\e[36m'"[4]" '\e(B\e[m'"Desktop with LXQt"
    echo -e '\e[36m'"[5]" '\e(B\e[m'"Command line"
    read -n 1 choice
    case $choice in
        1)
            pkglist="firefox flatpak partitionmanager dolphin discover plasma sddm vlc konsole network-manager-applet limine-entry-tool"
            profile="Plasma"
            loop=0
            ;;
        2)
            pkglist="firefox flatpak partitionmanager dolphin discover sddm vlc hyprland kitty wofi waybar hyprpaper konsole network-manager-applet dunst wireplumber noto-fonts pipewire-pulse nerd-fonts sof-firmware sddm-kcm plymouth-kcm systemsettings breeze breeze-cursors breeze-plymouth flatpak-kcm plasma-integration limine-entry-tool"
            profile="Hyprland"
            loop=0
            ;;
        3)
            pkglist="firefox flatpak xfce4 xfce4-goodies discover lightdm-gtk-greeter lightdm-gtk-greeter-settings vlc network-manager-applet limine-entry-tool"
            profile="Xfce"
            loop=0
            ;;
        4)
            pkglist="firefox flatpak partitionmanager discover lightdm-gtk-greeter lightdm-gtk-greeter-settings lxqt vlc network-manager-applet limine-entry-tool"
            profile="LXQt"
            loop=0
            ;;
        5)
            pkglist="limine-entry-tool"
            profile="Command line"
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
loop=1
while [[ $loop == 1 ]]; do
    clear
    echo -e '\e[3m'"Would you like to rename your machine?"'\e(B\e[m'
    echo
    echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes"
    echo -e '\e[36m'"[N]" '\e(B\e[m'"No"
    read -n 1 choice
    case $choice in
        y|Y)
            clear
            read -p "Name your machine (letters, numbers and dashes): " hname
            echo $hname > hostname.tmp
            sudo mv hostname.tmp /etc/hostname
            loop=0
            ;;
        n|N)
            loop=0
            ;;
        *)
            ;;
    esac
done

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

loop=1
while [[ $loop == 1 ]]; do
    clear
    echo -e '\e[3m'"Show boot menu?"'\e(B\e[m'
    echo -e '\e[3m'"You will be asked which boot entries to add later."'\e(B\e[m'
    echo
    echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes"
    echo -e '\e[36m'"[N]" '\e(B\e[m'"No"
    read -n 1 choice
    case $choice in
        y|Y)
            bootmenu=1
            loop=0
            ;;
        n|N)
            bootmenu=0
            loop=0
            ;;
        *)
            ;;
    esac
done

if [[ $rootpass == "" ]]; then
    sudo passwd -l root
else
    sudo chpasswd <<< "root:$rootpass"
fi
sudo useradd -m -G wheel $uname
sudo chpasswd <<< "$uname:$pass"

if [[ -e /dev/mapper/root ]]; then
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Would you like to change your encryption password?"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes"
        echo -e '\e[36m'"[N]" '\e(B\e[m'"No"
        read -n 1 choice
        case $choice in
            y|Y)
                clear
                lsblk -r > lsblk.tmp
                lukspart="$(awk '/root/ { print prev } { prev = $0 }' lsblk.tmp | awk '{print $1}')"
                sudo cryptsetup luksChangeKey /dev/$lukspart
                loop=0
                ;;
            n|N)
                loop=0
                ;;
            *)
                ;;
        esac
    done
fi

clear
yay -S --noconfirm $pkglist
if [[ $extrapkgs == 1 ]]; then
  yay -S --noconfirm firefox firefox-i18n-uk firefox-ublock-origin flatpak neofetch screenfetch fastfetch tree htop btop partitionmanager plymouth vlc packagekit base-devel ark waybar hyprpaper thunar wofi konsole dialog exfatprogs f2fs-tools hfsprogs jfsutils ntfs-3g udftools apfsprogs zfs-utils
fi

git clone https://github.com/JaredDinosaur/hyprconf
sudo mkdir /home/$uname/.config/hypr
sudo mkdir /home/$uname/.config/kitty
sudo cp /home/oem/hyprconf/hyprland.conf /home/$uname/.config/hypr
sudo cp /home/oem/hyprconf/kitty.conf /home/$uname/.config/kitty
sudo cp /home/oem/hyprconf/config.jsonc /etc/xdg/waybar
sudo cp /home/oem/hyprconf/style.css /etc/xdg/waybar

if [[ $bootmenu == 1 ]]; then
    sudo sed -i "s/timeout: 0/timeout: 10" /boot/EFI/arch-limine/limine.conf
    clear
    sudo limine-scan
fi

sudo systemctl enable accounts-daemon
sudo systemctl enable udisks2
sudo systemctl enable upower
sudo systemctl enable sddm
sudo systemctl enable lightdm

sudo rm -rf /etc/systemd/system/getty@tty1.service.d
sudo sed -i "s/^# \(%wheel ALL=(ALL:ALL) ALL\)/\1/" /etc/sudoers
sudo sed -i "s/^\(%wheel ALL=(ALL:ALL) NOPASSWD: ALL\)/# \1/" /etc/sudoers

echo
echo
echo
echo "Done! Rebooting in 5 seconds..."
sleep 1
echo "Done! Rebooting in 4 seconds..."
sleep 1
echo "Done! Rebooting in 3 seconds..."
sleep 1
echo "Done! Rebooting in 2 seconds..."
sleep 1
echo "Done! Rebooting in 1 second..."
sleep 1
clear
echo "Final cleanup, enter 'oem' to continue..."
sudo userdel -rf oem
reboot
