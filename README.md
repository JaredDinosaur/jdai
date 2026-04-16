# File descriptions (in order of importance)

**jdai-efi.sh:** The main script. It is strongly recommended to use this one.

**jdai.sh:** Older, less polished script for legacy systems.

**jdai-efi-oem.sh:** Allows installation for another user, partially completing the install and running a setup script on startup. Currently a work in progress, may be unstable with some configurations.

**jdai-profile.sh:** Post-setup script run on startup, used by jdai-efi-oem.sh

**jdai-efi-2.sh:** Secondary script created and run by jdai-efi.sh - performs tasks within chroot.

**jdai-usr.sh:** Tertiary script created and run by jdai-efi.sh - performs tasks within chroot as the created user.

**README.md:** This text.

**jdai.py.old:** Deprecated Python version, will not be updated.

---

# How to install Arch with this script (applies to jdai-efi.sh only)
### None of these scripts will work without an internet connection! You will need an Ethernet cable or Wi-Fi.

## Using a real machine:
1) Put the Arch Linux installation media ([DOWNLOAD LINK](https://www.mirrorservice.org/sites/ftp.archlinux.org/iso/2026.04.01/archlinux-x86_64.iso)) onto a USB drive using [Rufus](https://rufus.ie/) or [Ventoy](https://www.ventoy.net/en/download.html).
* The next steps involve entering the BIOS and boot menu. To do this, turn on your machine and immediately start mashing a specific key on your keyboard. If you don't know which key to press, check [here](http://www.auditiait.es/en/list-of-keys-to-access-to-bios/) or Google your machine/motherboard model.
* WARNING: If you are planning to install alongside Windows, please ensure that BitLocker is disabled on your C: drive or that you have the recovery key on another device! If you do not do this, you may be locked out of Windows!
2) On the machine you wish to install Arch Linux to, enter the BIOS and ensure that Secure Boot is disabled and USB booting is enabled.
3) Insert the USB drive, save and exit the BIOS and enter the boot menu.
* Warning: The Arch installation media beeps upon boot by default. This might be louder than you expect.
4) Select the USB drive in the menu, either using your mouse/touchpad or with the arrow keys and Enter.
5) Once you see the text `root@archiso`, enter the following commands:
* If your Wi-Fi password contains symbols such as @ or #, you may need to change the keyboard layout (default is US) using loadkeys. For example, to load the British keyboard layout, use `loadkeys uk`. To see all available keyboard layouts, run `localectl list-keymaps`.
* Only run these commands if you need to connect to Wi-Fi:
```
iwctl station list
iwctl station (device name, usually wlan0) get-networks
iwctl station (device name) connect (your network)
```
After connecting to Wi-Fi (if needed), run these commands:
```
pacman-key --init
pacman-key --populate
pacman -Sy --noconfirm git archlinux-keyring
git clone https://github.com/JaredDinosaur/jdai
cd jdai
chmod +x jdai-efi.sh
./jdai-efi.sh
```
Then follow the script as normal.

## Using a virtual machine:
1) Create a new virtual machine. If a Windows 10 template option exists, it is recommended to use it. Otherwise, recommended VM settings are: 4 CPU cores, 4GB RAM and 64GB disk space. Ensure that the VM has network access.
2) Download the Arch Linux installation media ([DOWNLOAD LINK](https://www.mirrorservice.org/sites/ftp.archlinux.org/iso/2026.04.01/archlinux-x86_64.iso)), and select the .iso file to use with the virtual CD/DVD drive.
3) Power on the virtual machine.
* Warning: The Arch installation media beeps upon boot by default. This might be louder than you expect.
4) Once you see the text `root@archiso`, enter the following commands:
```
pacman-key --init
pacman-key --populate
pacman -Sy --noconfirm git archlinux-keyring
git clone https://github.com/JaredDinosaur/jdai
cd jdai
chmod +x jdai-efi.sh
./jdai-efi.sh
```
Then follow the script as normal.

---

# Which options should I choose?

## Filesystems

**ext4:** The default option, balances performance and simplicity

**Btrfs:** Has copy-on-write functionality for easy backups, good for data integrity but may slightly reduce performance

**XFS:** High performance filesystem, good for large drives and servers but is slightly more complicated

## Disk encryption

This will ask you for a password on every startup. It's not an essential feature, but is nice for users who want more security. It can cause issues with boot splash screens, and cannot be unlocked if you forget the password.

## Profile

**Desktop (Plasma):** Easy-to-use Windows-like desktop which is highly customisable and stable, but may be slower on low-end machines.

**Desktop (Hyprland):** Lightweight, extremely configurable tiling window manager; however, it is hugely complicated and prone to being unstable and buggy, especially on virtual machines.

**Desktop (Xfce):** Somewhat Mac-like desktop which is fast and customisable, but slightly more complicated than Plasma.

**Desktop (LXQt):** More advanced but very lightweight Windows-like desktop, ideal for low-end machines.

**Command line:** Basic text interface with a few utilities, ideal for those who want to install a different desktop environment.

**Minimal:** The most basic set of packages with no extras, recommended for servers or extremely slow machines.

## Additional packages

Includes packages such as extra terminal utilities, Firefox with uBlock Origin (an ad blocker), VLC media player, and support for more filesystems like NTFS (Windows filesystem) and APFS (Mac filesystem).

These packages may fail to install if the profile is set to Minimal, although having additional packages with the Minimal configuration already isn't a good idea.

## Hostname and username

The simpler the better, up to 63 characters. Try to keep it to lowercase letters, as numbers or dashes can cause issues at the start or end of a name.

Spaces and special characters (other than -) are forbidden and **will** cause issues if included.

## Root password

Using the same password as your normal user is easier to remember.

If the password is left blank, the user will be asked whether to lock the root account. This is not recommended and can be changed with `sudo passwd`.

## Boot menu

Automatic entry detection (such as Windows) is currently broken and therefore disabled. It can be done after installation by running `yay -S --noconfirm limine-entry-tool` and `sudo limine-scan`.

If the boot menu is shown, it will automatically boot into Arch after 10 seconds if there is no input from the user.

---

#### And that's it! From my testing, installation takes around 15 minutes, but this can vary based on how fast your internet and computer are. Enjoy your Arch!
