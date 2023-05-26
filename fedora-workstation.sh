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
cat > "$HOME/.config/Code/User/settings.json" <<EOF
{
    "workbench.editor.untitled.hint": "hidden",
    "security.workspace.trust.untrustedFiles": "open",
    "editor.minimap.enabled": false,
    "git.openRepositoryInParentFolders": "never",
    "liveServer.settings.donotShowInfoMsg": true
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

# gnome shell
echo -e "\nSetting gnome shell ..."

sudo dnf install -y gnome-tweaks
flatpak install flathub com.mattjakeman.ExtensionManager -y

gsettings set org.gnome.shell disable-user-extensions false
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.interface locate-pointer true
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
