#!/bin/bash

#   ______       _                               __ _              _____           _        _ _       _   _             
# |  ____|     | |                _      /\    / _| |            |_   _|         | |      | | |     | | (_)            
# | |__ ___  __| | ___  _ __ __ _(_)    /  \  | |_| |_ ___ _ __    | |  _ __  ___| |_ __ _| | | __ _| |_ _  ___  _ __  
# |  __/ _ \/ _` |/ _ \| '__/ _` |     / /\ \ |  _| __/ _ \ '__|   | | | '_ \/ __| __/ _` | | |/ _` | __| |/ _ \| '_ \ 
# | | |  __/ (_| | (_) | | | (_| |_   / ____ \| | | ||  __/ |     _| |_| | | \__ \ || (_| | | | (_| | |_| | (_) | | | |
# |_|  \___|\__,_|\___/|_|  \__,_(_) /_/    \_\_|  \__\___|_|    |_____|_| |_|___/\__\__,_|_|_|\__,_|\__|_|\___/|_| |_|
                                                                                                                                                                                                                                            
# ⚙️ : Script for after installing Fedora, making it ready for everything i generally use.
# 🐈‍⬛ - Github Author: @darrkksz 

#   ___             _   _             
# | __|  _ _ _  __| |_(_)___ _ _  ___
# | _| || | ' \/ _|  _| / _ \ ' \(_-<
# |_| \_,_|_||_\__|\__|_\___/_||_/__/
                                    
info() { echo -e "\e[1;32m[INFO]\e[0m $1"; }
warn() { echo -e "\e[1;33m[WARN]\e[0m $1"; }
error() { echo -e "\e[1;31m[ERRO]\e[0m $1"; }

# --- 1. Starter Update ---
info "🔃 Updating System..."
sudo dnf upgrade --refresh -y

# --- 2. RPM Fusion ---
info "🚀 Enabling RPM Fusion..."
sudo dnf install -y \
 https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
 https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf upgrade --refresh -y

# --- 3. Drivers ---
GPU=$(lspci | grep -E "VGA|3D")
if echo "$GPU" | grep -qi nvidia; then
    info "🟢 NVIDIA detected, updating and installing drivers..."
    sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
elif echo "$GPU" | grep -qi amd; then
    info "🔴 AMD detected, installing and updating Vulkan drivers..."
    sudo dnf install -y mesa-vulkan-drivers mesa-vulkan-drivers.i686
elif echo "$GPU" | grep -qi intel; then
    info "🔵 Intel detected, installing and updating Vulkan drivers..."
    sudo dnf install -y mesa-vulkan-drivers mesa-vulkan-drivers.i686
else
    warn "⚠️ No supported GPU detected, skipped this Drivers step."
fi

# --- 4. Fonts ---
info "🔠 Installing fonts..."
sudo dnf install xorg-x11-font-utils -y
sudo dnf install fira-code-fonts -y
sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# --- 5. Gaming Packages ---
info "🎮 Installling packages for games..."
sudo dnf install -y mangohud gamemode wine winetricks
sudo flatpak install io.github.radiolamp.mangojuice -y

# --- 6. Tuned ---
info "⚡ Configuring Tuned..."
sudo systemctl enable --now tuned
sudo tuned-adm profile latency-performance

# --- 7. Browsers ---
info "🌐 Installing Browsers..."
sudo dnf install fedora-workstation-repositories --y
flatpak install com.microsoft.Edge -y

# --- 8. Codecs ---
info "📼 Installing codecs..."
sudo dnf groupupdate multimedia --setop="install_weak_deps=False" \
 --exclude=PackageKit-gstreamer-plugin -y
sudo dnf groupupdate sound-and-video -y

# --- 9. DNF Config ---
info "📦 Configuring DNF for more speed..."
sudo tee -a /etc/dnf/dnf.conf > /dev/null <<EOL
max_parallel_downloads=10
fastestmirror=True
EOL

# --- 10. Flatpaks ---
info "📥 Installing Flatpaks..."
sudo flatpak install com.valvesoftware.Steam io.github.Foldex.AdwSteamGtk com.discordapp.Discord dev.overlayed.Overlayed com.heroicgameslauncher.hgl sh.ppy.osu org.vinegarhq.Sober org.vinegarhq.Vinegar org.prismlauncher.PrismLauncher md.obsidian.Obsidian com.github.PintaProject.Pinta io.github.flattool.Warehouse it.mijorus.gearlever io.missioncenter.MissionCenter io.mrarm.mcpelauncher com.dec05eba.gpu_screen_recorder com.usebottles.bottles com.obsproject.Studio page.kramo.Sly io.github.giantpinkrobots.flatsweep com.rafaelmardojai.Blanket io.github.realmazharhussain.GdmSettings io.github.seadve.Mousai io.gitlab.adhami3310.Converter dev.qwery.AddWater io.github.flattool.Ignition page.codeberg.libre_menu_editor.LibreMenuEditor io.github.zaedus.spider io.github.giantpinkrobots.varia com.spotify.Client com.github.tchx84.Flatseal org.onlyoffice.desktopeditors com.github.ADBeveridge.Raider me.iepure.devtoolbox org.gnome.Mahjongg org.gnome.Crosswords it.mijorus.smile io.mgba.mGBA app.drey.Dialect io.github.diegopvlk.Dosage -y

# --- 11. GNOME Debloat ---
info "🧹 Removing unwanted GNOME apps..."
sudo dnf remove gnome-maps gnome-contacts gnome-characters gnome-tour libreoffice* mediawriter simple-scan baobab gnome-disk-utility gnome-logs gnome-parents-control abrt gnome-system-monitor gnome-connections gnome-camera -y

# --- 12. Kitty Terminal ---
info "🐱 Installing Kitty terminal..."
sudo dnf install kitty -y

# --- 13. Zsh + Oh My Zsh ---
info "💻 Installing Zsh and configuring..."
sudo dnf install -y zsh git curl wget

info "➡️ Setting Zsh as default shell..."
chsh -s "$(which zsh)"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "📦 Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

info "🔌 Installing plugins..."
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

info "⚙️ Updating ~/.zshrc with plugins and theme..."
sed -i 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="agnoster"/' ~/.zshrc

# --- 14. Cleaning ---
info "🧽 Cleaning unused packages..."
sudo dnf autoremove -y
sudo dnf clean all

info "✅ After installation completed! Restart the system to apply everything."
