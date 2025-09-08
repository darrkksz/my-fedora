#!/bin/bash

#  ______       _                    _____           _       _   
# |  ____|     | |                  / ____|         (_)     | |  
# | |__ ___  __| | ___  _ __ __ _  | (___   ___ _ __ _ _ __ | |_ 
# |  __/ _ \/ _` |/ _ \| '__/ _` |  \___ \ / __| '__| | '_ \| __|
# | | |  __/ (_| | (_) | | | (_| |  ____) | (__| |  | | |_) | |_ 
# |_|  \___|\__,_|\___/|_|  \__,_| |_____/ \___|_|  |_| .__/ \__|
#                                                    | |        
#                                                    |_|        
                                                                                                                                                                                                                                            
# ⚙️ : Script for after installing Fedora, making it ready for everything i generally use automatically.
# 📦️ - Contains: Packages, Optimizations, Customizations, Themes/Fonts, and Applications.

#   ___             _   _             
# | __|  _ _ _  __| |_(_)___ _ _  ___
# | _| || | ' \/ _|  _| / _ \ ' \(_-<
# |_| \_,_|_||_\__|\__|_\___/_||_/__/
                                    
info() { echo -e "\e[1;32m[INFO]\e[0m $1"; }
warn() { echo -e "\e[1;33m[WARN]\e[0m $1"; }
error() { echo -e "\e[1;31m[ERROR]\e[0m $1"; }

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

# --- 4. Fonts & Customizations ---
info "🔠 Installing fonts and customizations..."
sudo dnf install xorg-x11-font-utils -y
sudo dnf install fira-code-fonts -y
sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
sudo flatpak install io.github.realmazharhussain.GdmSettings -y

# --- 5. Gaming Packages ---
info "🎮 Installling packages for games..."
sudo dnf install -y mangohud gamemode wine winetricks
sudo flatpak install io.github.radiolamp.mangojuice io.github.Foldex.AdwSteamGtk com.valvesoftware.Steam com.discordapp.Discord dev.overlayed.Overlayed sh.ppy.osu org.vinegarhq.Sober org.vinegarhq.Vinegar org.prismlauncher.PrismLauncher io.mrarm.mcpelauncher io.mgba.mGBA -y

# --- 6. Tuned ---
info "⚡ Configuring Tuned..."
sudo systemctl enable --now tuned
sudo tuned-adm profile latency-performance

# --- 7. Browsers ---
info "🌐 Installing Browsers and repos..."
sudo dnf install fedora-workstation-repositories -y
flatpak install com.microsoft.Edge dev.qwery.AddWater -y

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
sudo flatpak install md.obsidian.Obsidian com.github.PintaProject.Pinta io.github.flattool.Warehouse it.mijorus.gearlever io.missioncenter.MissionCenter com.dec05eba.gpu_screen_recorder com.usebottles.bottles com.obsproject.Studio io.github.giantpinkrobots.flatsweep io.github.seadve.Mousai io.gitlab.adhami3310.Converter io.github.flattool.Ignition page.codeberg.libre_menu_editor.LibreMenuEditor io.github.zaedus.spider io.github.giantpinkrobots.varia com.spotify.Client com.github.tchx84.Flatseal org.onlyoffice.desktopeditors com.github.ADBeveridge.Raider me.iepure.devtoolbox it.mijorus.smile app.drey.Dialect -y

# --- 11. GNOME Debloat ---
info "🧹 Removing unwanted GNOME apps..."
sudo dnf remove gnome-maps gnome-contacts gnome-characters gnome-tour libreoffice* simple-scan baobab gnome-disk-utility gnome-logs gnome-parents-control abrt gnome-system-monitor gnome-connections gnome-camera -y

# --- 12. Terminal ---
info "⌨️ Installing Terminal and extra packages..."
sudo dnf install fastfetch cava btop -y
sudo flatpak install com.raggesilver.BlackBox -y

# --- 13. VSCode ---
info "🔩 Installing VSCode..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install code -y

# --- 14. Zsh + Oh My Zsh ---
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

# --- 15. Cleaning ---
info "🧽 Cleaning unused packages..."
sudo dnf autoremove -y
sudo dnf clean all

info "✅ After installation completed! Restart the system to apply everything."
