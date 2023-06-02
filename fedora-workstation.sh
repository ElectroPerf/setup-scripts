#!/usr/bin/env bash
#
# Script to setup Fedora 38 Workstation
#
# Usage:
#        ./fedora-workstation.sh
#

cd $HOME

# Enable RPM Fusion
echo -e "Enabling RPM Fusion\n"
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Enable flatpak
flatpak remote-modify --enable flathub

# Install packages
echo -e "Installing and updating dnf packages ...\n"
sudo dnf update -y
sudo dnf install -y android-tools \
                    htop \
                    java-latest-openjdk-devel.x86_64 \
                    java-latest-openjdk.x86_64 \
                    neofetch \
                    neovim \
                    nload \
                    pavucontrol \
                    ripgrep \                     
		    tldr

flatpak install flathub -y com.anydesk.Anydesk \
			   com.discordapp.Discord \
                           com.github.IsmaelMartinez.teams_for_linux \
			   com.microsoft.EdgeDev \
			   com.visualstudio.code \
			   io.github.mimbrero.WhatsAppDesktop \
			   org.telegram.desktop \
			   org.videolan.VLC \
			   us.zoom.Zoom

# Provide host terminal to vscode flatpak
mkdir -p $HOME/.config/Code/User && touch $HOME/.config/Code/User/settings.json
cat > "$HOME/.config/Code/User/settings.json" <<EOF
{
    "terminal.integrated.defaultProfile.linux": "bash",
    "terminal.integrated.profiles.linux": {
        "bash": {
          "path": "/usr/bin/flatpak-spawn",
          "args": ["--host", "--env=TERM=xterm-256color", "bash"]
        }
    }
}
EOF

# battop
echo -e "\nInstalling battop..."
wget https://github.com/svartalf/rust-battop/releases/download/v0.2.4/battop-v0.2.4-x86_64-unknown-linux-gnu -O battop
sudo mv battop /usr/bin/
sudo chmod +x /usr/bin/battop

# Multimedia plugins
echo -e "\nInstalling multimedia plugins..."
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install -y lame\* --exclude=lame-devel
sudo dnf group upgrade -y --with-optional Multimedia

# Platform tools
echo -e "\nInstalling Android SDK platform tools..."
wget -q https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip -qq platform-tools-latest-linux.zip
rm platform-tools-latest-linux.zip

echo -e "\nSetting up android udev rules..."
git clone https://github.com/M0Rf30/android-udev-rules.git
cd android-udev-rules
sudo cp -v 51-android.rules /etc/udev/rules.d/51-android.rules
sudo chmod a+r /etc/udev/rules.d/51-android.rules
sudo cp android-udev.conf /usr/lib/sysusers.d/
sudo systemd-sysusers
sudo gpasswd -a $(whoami) adbusers
sudo udevadm control --reload-rules
sudo systemctl restart systemd-udevd.service
adb kill-server
rm -rf android-udev-rules

# git
echo -e "\nSetting up Git..."

sudo dnf install 'dnf-command(config-manager)'
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf install -y gh

if [[ $USER == "karan" ]]; then
  git config --global user.email "karan@pixelos.net"
  git config --global user.name "Karan Parashar"
fi

git config --global alias.cp 'cherry-pick'
git config --global alias.c 'commit'
git config --global alias.f 'fetch'
git config --global alias.m 'merge'
git config --global alias.rb 'rebase'
git config --global alias.rs 'reset'
git config --global alias.ck 'checkout'
git config --global credential.helper 'cache --timeout=99999999'
git config --global core.editor "nvim"

# Setup nvchad for neovim
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.fonts
fc-cache -f -v

git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1

# docker
sudo dnf remove -y docker \
                   docker-client \
                   docker-client-latest \
                   docker-common \
                   docker-latest \
                   docker-latest-logrotate \
                   docker-logrotate \
                   docker-selinux \
                   docker-engine-selinux \
                   docker-engine

sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

sudo dnf install -y docker-ce \
                    docker-ce-cli \
                    containerd.io \ 
                    docker-buildx-plugin \
                    docker-compose-plugin

sudo usermod -aG docker $USER
sudo systemctl start docker

# gnome shell
echo -e "\nSetting gnome shell ..."

sudo dnf install -y gnome-tweaks
flatpak install flathub com.mattjakeman.ExtensionManager -y

# To list all GNOME desktop interface settings - gsettings list-recursively org.gnome.desktop.interface
gsettings set org.gnome.shell disable-user-extensions false
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.interface locate-pointer true
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface clock-format '12h'
