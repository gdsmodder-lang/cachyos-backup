#!/bin/bash
#
# install-packages.sh
#
# Script AUTOCONTIDO: a lista de pacotes ja esta embutida abaixo, entao
# basta baixar/clonar este unico arquivo (ex.: do GitHub) para reinstalar
# tudo em uma migracao de sistema CachyOS / Arch-based. Nao depende de
# nenhum arquivo .txt externo.
#
# Uso:
#   chmod +x install-packages.sh
#   ./install-packages.sh
#

set -euo pipefail

# --- Lista de pacotes (nativos + AUR, ja sem Hyprland/caelestia/noctalia) --

PACKAGES=(
    7zip
    accountsservice
    alacritty
    alsa-firmware
    alsa-plugins
    alsa-utils
    awesome-terminal-fonts
    awww
    base
    base-devel
    bash-completion
    bind
    blueman
    bluez
    bluez-hid2hci
    bluez-libs
    bluez-obex
    bluez-utils
    brightnessctl
    btop
    btrfs-progs
    cachyos-fish-config
    cachyos-hello
    cachyos-hooks
    cachyos-kernel-manager
    cachyos-keyring
    cachyos-micro-settings
    cachyos-mirrorlist
    cachyos-packageinstaller
    cachyos-plymouth-bootanimation
    cachyos-plymouth-theme
    cachyos-rate-mirrors
    cachyos-settings
    cachyos-v3-mirrorlist
    cachyos-v4-mirrorlist
    cachyos-wallpapers
    cachyos-zsh-config
    cantarell-fonts
    cava
    chess-tui
    chromium
    chwd
    clinfo
    cliphist
    code
    colord
    cpupower
    cryptsetup
    device-mapper
    diffutils
    dmidecode
    dmraid
    dms-shell-niri
    dnsmasq
    dosfstools
    duf
    dunst
    e2fsprogs
    efibootmgr
    efitools
    ethtool
    exfatprogs
    f2fs-tools
    fastfetch
    faugus-launcher
    feh
    ffmpegthumbnailer
    file-roller
    firefox
    flameshot
    flatpak
    fsarchiver
    git
    glances
    gnome-keyring
    grimblast-git
    gst-libav
    gst-plugin-pipewire
    gst-plugin-va
    gst-plugins-bad
    gst-plugins-ugly
    gvfs
    hdparm
    htop
    hwdetect
    hwinfo
    inetutils
    intel-compute-runtime
    intel-media-driver
    intel-media-sdk
    intel-ucode
    iwd
    jfsutils
    kitty
    kvantum
    kvantum-qt5
    less
    lib32-mangohud
    lib32-mesa
    lib32-opencl-mesa
    lib32-vulkan-intel
    libdvdcss
    libgsf
    libopenraw
    libreoffice-fresh-pt-br
    limine
    limine-mkinitcpio-hook
    linux-cachyos
    linux-cachyos-headers
    linux-cachyos-lts
    linux-cachyos-lts-headers
    linux-firmware
    linuxtoys
    logrotate
    lsb-release
    lsof
    lsscsi
    lvm2
    man-db
    man-pages
    mangohud
    materia-gtk-theme
    matugen
    mdadm
    meld
    mesa
    mesa-utils
    micro
    mkinitcpio
    modemmanager
    mtools
    nano
    nano-syntax-highlighting
    nemo
    neofetch
    neovim
    net-tools
    netctl
    networkmanager
    networkmanager-openvpn
    nfs-utils
    nilfs-utils
    niri
    nodejs
    noise-suppression-for-voice
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    nss-mdns
    nwg-look
    obsidian
    okular
    opencl-mesa
    openssh
    os-prober
    pacman-contrib
    pamixer
    papirus-icon-theme
    paru
    pavucontrol
    perl
    pipewire-alsa
    pipewire-pulse
    pkgfile
    playerctl
    plocate
    plymouth
    polkit-kde-agent
    poppler-glib
    power-profiles-daemon
    pv
    python
    python-defusedxml
    python-packaging
    python-requests
    qt5-imageformats
    qt5-quickcontrols
    qt5-quickcontrols2
    qt5-wayland
    qt5ct
    qt6-wayland
    realtime-privileges
    rebuild-detector
    reflector
    ripgrep
    rofi
    rofi-emoji
    rsync
    rust
    s-nail
    satty
    scrot
    sg3_utils
    shelly
    smartmontools
    sof-firmware
    sqlitebrowser
    starship
    steam
    steam-devices
    stow
    sudo
    swaylock-effects-git
    swaync
    sysfsutils
    texinfo
    thunar-archive-plugin
    thunar-volman
    tmux
    ttf-bitstream-vera
    ttf-dejavu
    ttf-icomoon-feather
    ttf-jetbrains-mono
    ttf-jetbrains-mono-nerd
    ttf-liberation
    ttf-meslo-nerd
    ttf-opensans
    ttf-roboto
    udiskie
    ufw
    ufw-extras
    unrar
    unzip
    upower
    usb_modeswitch
    usbutils
    viewnior
    vim
    vivid
    vlc-plugins-all
    vte3
    vulkan-intel
    waybar
    waypaper
    wget
    which
    wireplumber
    wl-clipboard
    wlogout
    wlsunset
    woff2-font-awesome
    wofi
    wpa_supplicant
    xdg-desktop-portal-gnome
    xdg-user-dirs
    xdg-utils
    xdotool
    xf86-input-libinput
    xfsprogs
    xl2tpd
    xorg-server
    xorg-xinit
    xorg-xrandr
    xorg-xrdb
    xorg-xset
    xwayland-satellite
    yay
    zathura
    zathura-pdf-mupdf
    zenity
    zip
    zoxide
)

echo "Total de pacotes a instalar: ${#PACKAGES[@]}"
echo ""

# --- Pre-requisitos ---------------------------------------------------

# A lista contem pacotes lib32-* (lib32-mesa, lib32-mangohud, etc.),
# que exigem o repositorio [multilib] habilitado.
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "Aviso: o repositorio [multilib] nao parece estar habilitado em /etc/pacman.conf."
    echo "Pacotes lib32-* podem falhar na instalacao."
    read -rp "Deseja continuar mesmo assim? [s/N] " resp
    [[ "$resp" =~ ^[sS]$ ]] || exit 1
fi

sudo pacman -Sy --noconfirm

# --- Instala um AUR helper, se necessario ------------------------------
#
# A lista mistura pacotes de repositorio oficial com pacotes AUR
# (paru, yay, awww, grimblast-git, swaylock-effects-git, matugen,
# dms-shell-niri, linuxtoys, faugus-launcher, chess-tui, etc.).
# O paru resolve os dois tipos em uma unica chamada, entao ele e
# instalado primeiro caso ainda nao exista no sistema novo.

if ! command -v paru &>/dev/null; then
    echo "paru nao encontrado. Instalando..."
    sudo pacman -S --needed --noconfirm base-devel git
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$tmpdir/paru"
    (cd "$tmpdir/paru" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
fi

# --- Instalacao ---------------------------------------------------------

echo ""
echo "Iniciando instalacao. Pacotes AUR podem pedir confirmacao durante"
echo "o build (revisao de PKGBUILD, chaves PGP, etc.)."
echo ""

paru -S --needed "${PACKAGES[@]}"

echo ""
echo "Instalacao concluida."
echo "Revise o log acima em busca de pacotes que falharam (renomeados,"
echo "removidos do AUR, orfaos, etc.) e resolva manualmente se necessario."
echo ""
echo "Lembre-se: Hyprland, caelestia-shell, noctalia-qs e hyprcursor/hyprshot"
echo "foram propositalmente deixados fora desta lista. Instale-os a parte"
echo "se quiser recria-los no sistema novo."
