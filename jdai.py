import os
print("Before Phase 1 is started, the installation's root partition must be created and an internet connection must be present.")
print("You can modify partitions with cfdisk.")
print("This script is for BIOS (non-UEFI or UEFI-CSM) x86_64 systems ONLY!")
phase=int(input("Enter the phase to run: "))

def phase1():
    # Set large font to aid readability
    os.system("setfont ter-132b")
    part=input("The partition to format and mount as the root of the installation is /dev/")
    # Format selected partition as ext4
    os.system("mkfs.ext4 /dev/"+part)
    # Mount newly formatted partition to /mnt
    os.system("mount /dev/"+part+" /mnt")
    # Set keyboard layout
    os.system("loadkeys uk")
    os.system("clear")
    print("1) Minimal")
    print("2) Console")
    print("3) Desktop with KDE Plasma")
    print("4) Desktop with Hyprland")
    pkgsel=int(input("Select an installation type: "))
    # Select and install packages
    if pkgsel==1:
        pkglist="base linux linux-firmware grub iwd python nano"
    elif pkgsel==2:
        pkglist="base linux linux-firmware screenfetch tree htop plymouth grub iwd python git nano"
    elif pkgsel==3:
        pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth grub dolphin discover plasma-desktop plasma-workspace plasma-meta sddm vlc iwd grub-customizer git nano"
    else:
        pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth grub dolphin discover sddm vlc iwd grub-customizer hyprland kitty wofi waybar hyprpaper git nano"
    os.system("pacstrap -K /mnt "+pkglist)
    # Generate filesystem table
    os.system("genfstab -U /mnt >> /mnt/etc/fstab")
    os.system("clear")
    print("Phase 1 complete!")
    print("Please run the following commands before running Phase 2:")
    print("")
    print("If running from a seperate partition:")
    print("umount (partition containing this script)")
    print("mkdir /mnt/jdai")
    print("mount (partition containing this script) /mnt/jdai")
    print("arch-chroot /mnt")
    print("")
    print("Or, if cloned from GitHub:")
    print("mv jdai/jdai.py /mnt")
    print("arch-chroot /mnt")

def phase2():
    grubpart=input("GRUB will be installed to /dev/")
    hname=input("Name your device: ")
    name=input("Enter a username: ")
    # Set region, locale and timezone
    os.system("ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime")
    os.system("hwclock --systohc")
    os.system("nano /etc/locale.gen")
    os.system("locale-gen")
    os.system("echo LANG=en_GB.UTF-8 > /etc/locale.conf")
    os.system("echo KEYMAP=uk > /etc/vconsole.conf")
    # Set locale and timezone
    os.system("echo "+hname+" > /etc/hostname")
    # Enable startup services
    os.system("systemctl enable sddm accounts-daemon ip6tables iptables iwd NetworkManager-dispatcher NetworkManager systemd-network-generator systemd-networkd udisks2 upower wpa_supplicant")
    os.system("clear")
    print("This is the password for the root account.")
    # Set root password
    os.system("passwd")
    # Install GRUB to the selected boot partition
    os.system("grub-install /dev/"+grubpart)
    os.system("clear")
    egrub=input("Edit the GRUB config? (y/n) ")
    if egrub.lower()=="y":
        os.system("nano /etc/default/grub")
    os.system("grub-mkconfig -o /boot/grub/grub.cfg")
    # Add a user with sudo privileges
    os.system("useradd -m -G wheel "+name)
    os.system("clear")
    print("This is the password for your user.")
    # Set user password
    os.system("passwd "+name)
    os.system("clear")
    print("Phase 2 complete!")
    print("Press Ctrl+Alt+Del to reboot.")

if phase==1:
    phase1()
elif phase==2:
    phase2()
else:
    print("Exiting...")