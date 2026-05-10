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
        # List available disks
        hwinfo --disk --short
        echo
        echo "Recommended minimum disk space: 64GB for VMs, 128GB for real hardware"
        read -p "The disk to install to is /dev/___: " disk
        echo
        echo -e '\e[3m'"WARNING: The contents of this disk will be changed or erased!"'\e(B\e[m'
        echo -e '\e[3m'"Double check that you have selected the correct disk!"'\e(B\e[m'
        echo -e '\e[3m'"Are you sure you want to continue?"'\e(B\e[m'
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
                exit 1
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
        echo -e '\e[36m'"[1]" '\e(B\e[m'"Automatic partition layout (uses entire disk)"
        echo -e '\e[36m'"[2]" '\e(B\e[m'"Manual configuration"
        read -n 1 choice
        case $choice in
            1)
                rootno=3
                bootno=1
                swapno=2
                formboot=1
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
        echo -e '\e[36m'"[4]" '\e(B\e[m'"Desktop with LXQt"
        echo -e '\e[36m'"[5]" '\e(B\e[m'"Command line"
        echo -e '\e[36m'"[6]" '\e(B\e[m'"Minimal"
        read -n 1 choice
        case $choice in
            1)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth dolphin discover packagekit packagekit-qt6 plasma sddm vlc iwd git nano konsole dialog limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman btrfs-progs dosfstools e2fsprogs xfsprogs"
                profile="Desktop (Plasma)"
                loop=0
                ;;
            2)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth dolphin discover packagekit packagekit-qt6 vlc iwd hyprland kitty wofi waybar hyprpaper git nano konsole dialog sddm limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman dunst wireplumber noto-fonts pipewire-pulse nerd-fonts sof-firmware sddm-kcm plymouth-kcm systemsettings breeze breeze-cursors breeze-plymouth flatpak-kcm plasma-integration btrfs-progs dosfstools e2fsprogs xfsprogs"
                profile="Desktop (Hyprland)"
                loop=0
                ;;
            3)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop xfce4 xfce4-goodies plymouth discover packagekit packagekit-qt6 vlc iwd git nano dialog lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman btrfs-progs dosfstools e2fsprogs xfsprogs"
                profile="Desktop (Xfce)"
                loop=0
                ;;
            4)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth discover packagekit packagekit-qt6 lxqt vlc iwd git nano dialog lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman btrfs-progs dosfstools e2fsprogs xfsprogs"
                profile="Desktop (LXQt)"
                loop=0
                ;;
            5)
                pkglist="base linux linux-firmware screenfetch tree htop plymouth iwd python git nano dialog limine sudo efibootmgr networkmanager base-devel blueman btrfs-progs dosfstools e2fsprogs xfsprogs"
                profile="Command line"
                loop=0
                ;;
            6)
                pkglist="base linux linux-firmware git iwd python nano limine sudo efibootmgr networkmanager base-devel"
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
        echo -e '\e[3m'"This includes an ad blocker, resource monitor, and support for additional file systems."'\e(B\e[m'
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
        echo -e '\e[3m'"Install Steam, GPU drivers, and additional gaming features?"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes"
        echo -e '\e[36m'"[N]" '\e(B\e[m'"No"
        read -n 1 choice
        case $choice in
            y|Y)
                loop=1
                while [[ $loop == 1 ]]; do
                    clear
                    echo -e '\e[3m'"Select your graphics card manufacturer."'\e(B\e[m'
                    echo -e '\e[3m'"For Nvidia, proprietary drivers are better for more recent cards (GTX 1650 or newer)."'\e(B\e[m'
                    echo -e '\e[3m'"If your machine has no graphics card, select your CPU manufacturer."'\e(B\e[m'
                    echo
                    echo -e '\e[36m'"[1]" '\e(B\e[m'"Intel"
                    echo -e '\e[36m'"[2]" '\e(B\e[m'"AMD (Radeon)"
                    echo -e '\e[36m'"[3]" '\e(B\e[m'"Nvidia (Open Source)"
                    echo -e '\e[36m'"[4]" '\e(B\e[m'"Nvidia (Proprietary)"
                    echo -e '\e[36m'"[5]" '\e(B\e[m'"Other"
                    read -n 1 choice
                    case $choice in
                        1)
                            gpupkg=" vulkan-intel xf86-video-intel lib32-vulkan-intel"
                            gpuconf="Intel"
                            loop=0
                            ;;
                        2)
                            gpupkg=" vulkan-radeon xf86-video-amdgpu lib32-vulkan-radeon"
                            gpuconf="AMD (Radeon)"
                            loop=0
                            ;;
                        3)
                            gpupkg=" vulkan-nouveau xf86-video-nouveau lib32-vulkan-nouveau"
                            gpuconf="Nvidia (Open Source)"
                            loop=0
                            ;;
                        4)
                            gpupkg=" nvidia nvidia-utils lib32-nvidia-utils"
                            gpuconf="Nvidia (Proprietary)"
                            loop=0
                            ;;
                        5)
                            gpupkg=""
                            gpuconf="Other"
                            loop=0
                            ;;
                        *)
                            ;;
                    esac
                done
                gamer=1
                loop=0
                ;;
            n|N)
                gamer=0
                loop=0
                ;;
            *)
                ;;
        esac
    done
}

sethostname(){
    clear
    valid=0
    while [[ $valid == 0 ]]; do
        read -p "Name your machine (letters, numbers and dashes): " hname
        if [[ "$hname" =~ ^[a-zA-Z0-9-]+$ ]]; then
            valid=1
        else
            clear
            echo "Invalid hostname!"
        fi
    done
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
    valid=0
    while [[ $valid == 0 ]]; do
        read -p "Name your user (single word, lowercase): " uname
        if [[ "$uname" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            valid=1
        else
            clear
            echo "Invalid username!"
        fi
    done
    clear
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

bootent(){
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Show boot menu?"'\e(B\e[m'
        echo -e '\e[3m'"To detect other boot entries (e.g. Windows), install limine-entry-tool and run limine-scan."'\e(B\e[m'
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
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"This machine is currently booted in $bootmode mode."'\e(B\e[m'
        echo -e '\e[3m'"Would you like to make your system bootable in both BIOS and UEFI mode?"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes"
        echo -e '\e[36m'"[N]" '\e(B\e[m'"No"
        read -n 1 choice
        case $choice in
            y|Y)
                if [[ $bootmode == "BIOS" ]]; then
                    uefiboot=1
                else
                    biosboot=1
                fi
                loop=0
                ;;
            n|N)
                if [[ $bootmode == "BIOS" ]]; then
                    uefiboot=0
                else
                    biosboot=0
                fi
                loop=0
                ;;
            *)
                ;;
        esac
    done
}

intchk(){
    echo "Checking internet connection..."
    # Ping Arch Linux servers
    set +e
    ping -c 1 -W 2 archlinux.org >/dev/null
    connect=$?
    set -e
    if [[ $connect == 0 ]]; then
        echo "Connection test successful."
        quit=0
    else
        loop=1
        while [[ $loop == 1 ]]; do
            clear
            echo -e '\e[3m'"Internet connection not found! Would you like to connect to a wireless network?"'\e(B\e[m'
            echo -e '\e[3m'"If you are definitely connected to the internet, the Arch Linux servers may be down."'\e(B\e[m'
            echo
            echo -e '\e[36m'"[Y]" '\e(B\e[m'"List available wireless networks"
            echo -e '\e[36m'"[N]" '\e(B\e[m'"Cancel installation"
            read -n 1 choice
            case $choice in
                y|Y)
                    clear
                    # List available wireless networks
                    iface=$(iw dev | awk '$1=="Interface"{print $2; exit}')
                    if [[ $iface == "" ]]; then
                        echo "No wireless devices found!"
                        quit=1
                        loop=0
                    else
                        iwctl station "$iface" get-networks
                        read -p "Enter the name of the network you wish to connect to: " ssid
                        # Connect to the selected network
                        iwctl station "$iface" connect "$ssid"
                        quit=2
                        loop=0
                    fi
                    ;;
                n|N)
                    quit=1
                    loop=0
                    ;;
                *)
                    ;;
            esac
        done
    fi
}

quietmode() {
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Enable quiet mode?"'\e(B\e[m'
        echo -e '\e[3m'"This prints less text during the installation, which is easier to read but provides less detail."'\e(B\e[m'
        echo
        echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes"
        echo -e '\e[36m'"[N]" '\e(B\e[m'"No"
        read -n 1 choice
        case $choice in
            y|Y)
                quiet=1
                logfile=" >/dev/null"
                echolog=""
                loop=0
                ;;
            n|N)
                quiet=0
                logfile=""
                echolog=" >/dev/null"
                loop=0
                ;;
            *)
                ;;
        esac
    done
}

quietpkg(){
    local curstage=""
    local prevlen=0
    local stage=""
    local current=""
    local total=""
    local item=""
    local msg=""
    local line=""
    "$@" 2>&1 | while IFS= read -r line; do
        stage=""
        current=""
        total=""
        item=""
        if [[ $line =~ \(([0-9]+)/([0-9]+)\)[[:space:]]+downloading[[:space:]]+(.+)$ ]]; then
            stage="Downloading"
            current="${BASH_REMATCH[1]:-}"
            total="${BASH_REMATCH[2]:-}"
            item="${BASH_REMATCH[3]:-}"
        elif [[ $line =~ ^[[:space:]]*[-\>]+[[:space:]]+Building[[:space:]]+package:[[:space:]]+(.+)$ ]]; then
            stage="Building"
            item="${BASH_REMATCH[1]:-}"
        elif [[ $line =~ ^==\>[[:space:]]+Starting[[:space:]]+package ]]; then
            stage="Packaging"
            item="makepkg"
        elif [[ $line =~ \(([0-9]+)/([0-9]+)\)[[:space:]]+installing[[:space:]]+(.+)$ ]]; then
            stage="Installing"
            current="${BASH_REMATCH[1]:-}"
            total="${BASH_REMATCH[2]:-}"
            item="${BASH_REMATCH[3]:-}"
        elif [[ $line =~ \(([0-9]+)/([0-9]+)\)[[:space:]]+(.+)$ ]]; then
            local m1="${BASH_REMATCH[1]:-}"
            local m2="${BASH_REMATCH[2]:-}"
            local m3="${BASH_REMATCH[3]:-}"
            if [[ $line != *installing* && $line != *downloading* ]]; then
                stage="Post-install hooks"
                current="$m1"
                total="$m2"
                item="$m3"
            else
                continue
            fi
        else
            continue
        fi
        if [[ -n $curstage && $stage != "$curstage" ]]; then
            echo
        fi
        curstage="$stage"
        if [[ -n $current && -n $total ]]; then
            msg="$stage... ($current/$total) $item"
        else
            msg="$stage... $item"
        fi
        printf "\r%-*s" "$prevlen" ""
        printf "\r%s" "$msg"
        prevlen=${#msg}
    done
    echo
}

clear
echo
echo "==================================WARNING=================================="
echo "                This script requires an internet connection!               "
echo "                   This script is for x86-64 systems only!                 "
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
        exit 1
        ;;
esac
# Check boot mode
if [[ -d "/sys/firmware/efi" ]]; then
    echo "The system is booted in UEFI mode."
    bootmode="UEFI"
    uefiboot=1
    biosboot=0
else
    echo "The system is booted in BIOS mode."
    bootmode="BIOS"
    uefiboot=0
    biosboot=1
fi
# Check internet connection
quit=0
intchk
if [[ $quit == 1 ]]; then
    exit 2
fi
while [[ $quit == 2 ]]; do
    intchk
    if [[ $quit == 1 ]]; then
        exit 2
    fi
done
# Edit pacman config and install hwinfo
sed -i "s/#Color/Color/" /etc/pacman.conf
sed -i "s/ParallelDownloads = 5/ParallelDownloads = 1/" /etc/pacman.conf
sed -i "s/#NoProgressBar/ILoveCandy/" /etc/pacman.conf
pacman -Sy --noconfirm --needed hwinfo

# Get options
setlocale
diskpart
pkgs
sethostname
user
bootent
quietmode

# Show options and ask for confirmation
menu=1
while [[ $menu == 1 ]]; do
    clear
    echo "Region:                 $reg"
    echo "Disk:                   $disk"
    case $manpart in
        0)
            echo "Partitioning:           Automatic (using entire disk)"
            ;;
        1)
            echo "Partitioning:           Manual"
            ;;
    esac
    echo "Filesystem:             $rootfs"
    case $crypt in
        0)
            echo "Disk encryption:        Disabled"
            ;;
        1)
            echo "Disk encryption:        Enabled"
            echo "Encryption password:    $cryptstar"
            ;;
    esac
    echo "Profile:                $profile"
    case $extrapkgs in
        0)
            echo "Additional packages:    Disabled"
            ;;
        1)
            echo "Additional packages:    Enabled"
            ;;
    esac
    case $gamer in
        0)
            echo "Gaming features:        Disabled"
            echo "GPU Driver:             None"
            ;;
        1)
            echo "Gaming features:        Enabled"
            echo "GPU Driver:             $gpuconf"
            ;;
    esac
    echo "Hostname:               $hname"
    if [[ $rootpass == "" ]]; then
        echo "Root account:               Disabled"
    else
        echo "Root password:          $rootstar"
    fi
    echo "Username:               $uname"
    echo "Password:               $star"
    case $bootmenu in
        0)
            echo "Boot menu:              Hidden"
            ;;
        1)
            echo "Boot menu:              Shown"
            ;;
    esac
    case $uefiboot in
        0)
            echo "Boot mode:              BIOS only"
            ;;
        1)
            case $biosboot in
                0)
                    echo "Boot mode:              UEFI only"
                    ;;
                1)
                    echo "Boot mode:              BIOS and UEFI"
                    ;;
            esac
            ;;
    esac
    case $quiet in
        0)
            echo "Quiet mode:             Disabled"
            ;;
        1)
            echo "Quiet mode:             Enabled"
            ;;
    esac
    echo
    echo -e '\e[3m'"Install with these options?"'\e(B\e[m'
    echo
    echo "-------------------------------------"
    echo
    echo -e '\e[36m'"[Y]" '\e(B\e[m'"Begin installation"
    echo -e '\e[36m'"[N]" '\e(B\e[m'"Cancel installation"
    echo
    echo -e '\e[36m'"[1]" '\e(B\e[m'"Change locale"
    echo -e '\e[36m'"[2]" '\e(B\e[m'"Change partitioning and encryption"
    echo -e '\e[36m'"[3]" '\e(B\e[m'"Change packages and drivers"
    echo -e '\e[36m'"[4]" '\e(B\e[m'"Change hostname"
    echo -e '\e[36m'"[5]" '\e(B\e[m'"Change username and authentication"
    echo -e '\e[36m'"[6]" '\e(B\e[m'"Change boot options"
    echo -e '\e[36m'"[7]" '\e(B\e[m'"Change quiet mode"
    read -n 1 choice
    case $choice in
        y|Y)
            menu=0
            ;;
        n|N)
            exit 1
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
        6)
            bootent
            ;;
        7)
            quietmode
            ;;
        *)
            ;;
    esac
done

# Make child scripts executable
echo "#!/bin/bash" > jdai-efi-2.sh
echo "#!/bin/bash" > jdai-usr.sh
chmod +x jdai-efi-2.sh
chmod +x jdai-usr.sh
chmod +x cleanup.sh
declare -f quietpkg >> jdai-efi-2.sh
declare -f quietpkg >> jdai-usr.sh

# Set timezone (GB only)
if [[ $reg == "GB" ]]; then
    echo "echo \"Generating locale...\"$echolog" >> jdai-efi-2.sh
    echo "ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime" >> jdai-efi-2.sh
    echo "hwclock --systohc" >> jdai-efi-2.sh
fi
# Generate locale
echo "locale-gen$logfile" >> jdai-efi-2.sh
# Generate initramfs
echo "echo \"Generating initramfs...\"$echolog" >> jdai-efi-2.sh
echo "mkinitcpio -P$logfile" >> jdai-efi-2.sh
# Enable system services
echo "echo \"Enabling system services...\"$echolog" >> jdai-efi-2.sh
echo "systemctl enable ip6tables iptables iwd NetworkManager-dispatcher NetworkManager systemd-network-generator systemd-networkd wpa_supplicant$logfile" >> jdai-efi-2.sh
echo "systemctl enable accounts-daemon$logfile" >> jdai-efi-2.sh
echo "systemctl enable udisks2$logfile" >> jdai-efi-2.sh
echo "systemctl enable upower$logfile" >> jdai-efi-2.sh
echo "systemctl enable sddm$logfile" >> jdai-efi-2.sh
echo "systemctl enable lightdm$logfile" >> jdai-efi-2.sh
echo "systemctl enable wireplumber$logfile" >> jdai-efi-2.sh
# Create boot entry
echo "echo \"Creating boot entry...\"$echolog" >> jdai-efi-2.sh
if [[ $uefiboot == 1 ]]; then
    echo "efibootmgr --create --disk /dev/${disk} --part 1 --label \"Arch Linux\" --loader '\\BOOTX64.EFI' --unicode$logfile" >> jdai-efi-2.sh
fi
if [[ $biosboot == 1 ]]; then
    echo "limine bios-install /dev/$disk$logfile" >> jdai-efi-2.sh
fi
# Copy child scripts
echo "cp jdai-usr.sh /home/$uname" >> jdai-efi-2.sh
# Switch to newly created user
echo "cd /home/$uname" >> jdai-efi-2.sh
# Run child script as new user
echo "su $uname -c ./jdai-usr.sh" >> jdai-efi-2.sh

# Clone and build yay
echo "echo \"Installing yay...\"$echolog" >> jdai-usr.sh
echo "quietpkg sudo pacman -Syy$logfile" >> jdai-usr.sh
echo "git clone https://aur.archlinux.org/yay.git$logfile" >> jdai-usr.sh
echo "cd yay" >> jdai-usr.sh
if [[ $quiet == 0 ]]; then
    echo "makepkg -si --noconfirm" >> jdai-usr.sh
else
    echo "quietpkg makepkg -si --noconfirm" >> jdai-usr.sh
fi
#echo "yay -S --noconfirm limine-entry-tool" >> jdai-usr.sh

# Install extra packages if selected
if [[ $extrapkgs == 1 ]]; then
    echo "echo \"Installing extra packages...\"$echolog" >> jdai-usr.sh
    if [[ $quiet == 0 ]]; then
        echo "yay -S --noconfirm --needed firefox firefox-i18n-uk firefox-ublock-origin flatpak neofetch screenfetch fastfetch tree htop btop partitionmanager ark thunar konsole dialog exfatprogs f2fs-tools hfsprogs jfsutils ntfs-3g udftools apfsprogs zfs-utils" >> jdai-usr.sh
    else
        echo "quietpkg yay -S --noconfirm --needed firefox firefox-i18n-uk firefox-ublock-origin flatpak neofetch screenfetch fastfetch tree htop btop partitionmanager ark thunar konsole dialog exfatprogs f2fs-tools hfsprogs jfsutils ntfs-3g udftools apfsprogs zfs-utils" >> jdai-usr.sh
    fi
fi
if [[ $gamer == 1 ]]; then
    echo "echo \"Installing gaming packages and GPU drivers...\"$echolog" >> jdai-usr.sh
    if [[ $quiet == 0 ]]; then
        echo "yay -S --noconfirm --needed steam gamescope lutris winboat mesa$gpupkg" >> jdai-usr.sh
    else
        echo "quietpkg yay -S --noconfirm --needed steam gamescope lutris winboat mesa$gpupkg" >> jdai-usr.sh
    fi
fi
# Install hyprland configuration files
if [[ $profile == "Desktop (Hyprland)" ]]; then
    echo "echo \"Configuring Hyprland...\"$echolog" >> jdai-usr.sh
    echo "cd .." >> jdai-usr.sh
    echo "git clone https://github.com/JaredDinosaur/hyprconf$logfile" >> jdai-usr.sh
    echo "cd hyprconf" >> jdai-usr.sh
    echo "mkdir ~/.config/hypr" >> jdai-usr.sh
    echo "mkdir ~/.config/kitty" >> jdai-usr.sh
    echo "cp hyprland.conf ~/.config/hypr" >> jdai-usr.sh
    echo "cp kitty.conf ~/.config/kitty" >> jdai-usr.sh
    echo "sudo cp config.jsonc /etc/xdg/waybar" >> jdai-usr.sh
    echo "sudo cp style.css /etc/xdg/waybar" >> jdai-usr.sh
fi

## Scan for other boot entries
#if [[ $bootmenu == 1 ]]; then
#    echo "echo" >> jdai-usr.sh
#    echo "echo" >> jdai-usr.sh
#    echo "echo" >> jdai-usr.sh
#    echo "sudo limine-scan" >> jdai-usr.sh
#fi

case $manpart in
    0)
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
        # Handles different partition names (sda/vda vs nvme/mmcblk)
        if [[ "$disk" == *"d"* ]]; then
            root="${disk}${rootno}"
            boot="${disk}${bootno}"
            swap="${disk}${swapno}"
        else
            root="${disk}p${rootno}"
            boot="${disk}p${bootno}"
            swap="${disk}p${swapno}"
        fi
        # Get system RAM amount
        ram=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024)}')
        # Partition disk:
        # /boot  | 1GB
        # [SWAP] | Same as RAM
        # /      | rest of disk
        fdisk /dev/$disk <<EOF
o
n
p
1

+1G
y
n
p
2

+${ram}M
y
n
p
3


w
EOF
        ;;
    1)
        menu=1
        while [[ $menu == 1 ]]; do
            echo
            echo "If your boot mode is not UEFI only, your disk must have an MBR partition table."
            echo "The following partitions are required:"
            echo
            echo " Type | Size"
            echo "------|----------------------------"
            echo " Boot | 256MB to 1GB"
            echo " Swap | Same as RAM"
            echo " Root | 8GB min, 32GB+ recommended"
            echo 
            echo "Press any key to open cfdisk."
            read -n 1
            # Open TUI partition manager
            cfdisk /dev/$disk
            clear
            read -p "Which partition number should be used for root? " rootno
            clear
            read -p "Which partition number should be used for boot? (usually 1) " bootno
            clear
            read -p "Which partition number should be used for swap? " swapno
            clear
            loop=1
            while [[ $loop == 1 ]]; do
                clear
                echo -e '\e[3m'"Format the boot partition? This will remove all data on the partition!"'\e(B\e[m'
                echo
                echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes, format it"
                echo -e '\e[36m'"[N]" '\e(B\e[m'"No, keep existing data (may cause issues)"
                read -n 1 choice
                case $choice in
                    y|Y)
                        formboot=1
                        loop=0
                        ;;
                    n|N)
                        formboot=0
                        loop=0
                        ;;
                    *)
                        ;;
                esac
            done
            # Handles different partition names (sda/vda vs nvme/mmcblk)
            if [[ "$disk" == *"d"* ]]; then
                root="${disk}${rootno}"
                boot="${disk}${bootno}"
                swap="${disk}${swapno}"
            else
                root="${disk}p${rootno}"
                boot="${disk}p${bootno}"
                swap="${disk}p${swapno}"
            fi
            loop=1
            while [[ $loop == 1 ]]; do
                clear
                echo "Root partition: /dev/$root"
                echo "Boot partition: /dev/$boot"
                echo "Swap partition: /dev/$swap"
                case $formboot in
                    0)
                        echo "Format boot partition: No"
                        ;;
                    1)
                        echo "Format boot partition: Yes"
                        ;;
                esac
                echo
                echo -e '\e[3m'"Are you sure these options are correct?"'\e(B\e[m'
                echo
                echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes, continue"
                echo -e '\e[36m'"[N]" '\e(B\e[m'"No, change my options"
                echo -e '\e[36m'"[Q]" '\e(B\e[m'"Cancel installation"
                read -n 1 choice
                case $choice in
                    y|Y)
                        menu=0
                        loop=0
                        ;;
                    n|N)
                        loop=0
                        ;;
                    q|Q)
                        exit 1
                        ;;
                    *)
                        ;;
                esac
            done
        done
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
        ;;
esac
clear
echo "Formatting disk..."$echolog
case $crypt in
    0)
        # Format root partition (no encryption)
        if [[ $rootfs == "ext4" ]]; then
            mkfs.$rootfs /dev/$root
        else
            mkfs.$rootfs -f /dev/$root
        fi
        # Mount root partition to /mnt
        mount /dev/$root /mnt
        ;;
    1)
        # Format and encrypt root partition
        printf "%s" "$cryptpass" | cryptsetup -v --batch-mode luksFormat /dev/$root -
        printf "%s" "$cryptpass" | cryptsetup open /dev/$root root -
        mkfs.$rootfs /dev/mapper/root
        # Mount root partition to /mnt
        mount /dev/mapper/root /mnt
        ;;
esac
if [[ $formboot == 1 ]]; then
    # Format ESP
    mkfs.fat -F32 /dev/$boot
fi
# Mount ESP to /mnt/boot
mount --mkdir /dev/$boot /mnt/boot
# Format and activate swap partition
mkswap /dev/$swap
swapon /dev/$swap
# Install packages
echo "Installing base system..."$echolog
if [[ $quiet == 0 ]]; then
    pacstrap -K /mnt $pkglist
else
    quietpkg pacstrap -K /mnt $pkglist
fi
# Configure filesystem mount points
genfstab -U /mnt >> /mnt/etc/fstab
# Set language and keyboard layout
echo "Setting locale..."$echolog
echo "en_${reg}.UTF-8 UTF-8" > /mnt/etc/locale.gen
echo "LANG=en_${reg}.UTF-8" > /mnt/etc/locale.conf
if [[ $reg == "GB" ]]; then
    echo "KEYMAP=uk" > /mnt/etc/vconsole.conf
fi
# Set hostname
echo "Setting hostname..."$echolog
echo $hname > /mnt/etc/hostname
echo "Creating boot files..."$echolog
if [[ $uefiboot == 1 ]]; then
    # Create EFI boot point
    cp /mnt/usr/share/limine/BOOTX64.EFI /mnt/boot/
fi
if [[ $biosboot == 1 ]]; then
    # Create BIOS boot point
    cp /mnt/usr/share/limine/limine-bios.sys /mnt/boot/
fi
# Get root partition UUID
uuid=$(blkid -s UUID -o value /dev/$root)
# Enable initramfs hooks
case $crypt in
    0)
        sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap consolefont modconf block filesystems fsck)/' /mnt/etc/mkinitcpio.conf
        ;;
    1)
        sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt sd-encrypt filesystems fsck)/' /mnt/etc/mkinitcpio.conf
        ;;
esac
# Configure bootloader
echo "Configuring system files..."$echolog
touch /mnt/boot/limine.conf
case $bootmenu in
    0)
        echo "timeout: 0" >> /mnt/boot/limine.conf
        ;;
    1)
        echo "timeout: 10" >> /mnt/boot/limine.conf
        ;;
esac
echo "" >> /mnt/boot/limine.conf
echo "/Arch Linux" >> /mnt/boot/limine.conf
echo "    protocol: linux" >> /mnt/boot/limine.conf
echo "    path: boot():/vmlinuz-linux" >> /mnt/boot/limine.conf
case $crypt in
    0)
        echo "    cmdline: root=UUID=${uuid} zswap.enabled=0 rw rootfstype=${rootfs} quiet splash" >> /mnt/boot/limine.conf
        ;;
    1)
        echo "    cmdline: cryptdevice=UUID=${uuid}:root root=/dev/mapper/root rw rootfstype=${rootfs} quiet splash" >> /mnt/boot/limine.conf
        ;;
esac
echo "    module_path: boot():/initramfs-linux.img" >> /mnt/boot/limine.conf
touch /mnt/etc/default/limine
echo "ESP_PATH=/boot" >> /mnt/etc/default/limine
# Edit pacman configuration
sed -i "s/#Color/Color/" /mnt/etc/pacman.conf
sed -i "s/ParallelDownloads = 5/ParallelDownloads = 1/" /mnt/etc/pacman.conf
sed -i "s/#NoProgressBar/ILoveCandy/" /mnt/etc/pacman.conf
sed -i '/\[multilib\]/,/Include/ s/^#//' /mnt/etc/pacman.conf
# Edit sudo configuration
sed -i 's/^# \(%wheel ALL=(ALL:ALL) NOPASSWD: ALL\)/\1/' /mnt/etc/sudoers

cp ./* /mnt
echo "Setting up users..."$echolog
if [[ $rootpass == "" ]]; then
    # Disable root account
    arch-chroot /mnt passwd -l root
else
    # Set root password
    arch-chroot /mnt chpasswd <<< "root:$rootpass"
fi
# Add user
arch-chroot /mnt useradd -m -G wheel $uname
# Set password
arch-chroot /mnt chpasswd <<< "$uname:$pass"
# Run child script within chroot
arch-chroot /mnt bash ./jdai-efi-2.sh
# Edit sudo configuration
sed -i 's/^\(%wheel ALL=(ALL:ALL) NOPASSWD: ALL\)/# \1/' /mnt/etc/sudoers
sed -i 's/^# \(%wheel ALL=(ALL:ALL) ALL\)/\1/' /mnt/etc/sudoers
echo
echo
echo
echo "Done! You may now reboot."
