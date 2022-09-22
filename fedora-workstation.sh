#!/bin/bash
#
# Script to setup Fedora 36 Workstation
#
# Usage:
#        ./fedora-workstation.sh
#

cd $HOME

# Enable RPM Fusion
echo -e "Enabling RPM Fusion\n"
sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Add flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install packages
echo -e "Installing and updating dnf packages ...\n"
sudo dnf install -y -qq \
    android-tools \
    discord \
    gnome-extensions-app.x86_64 \
    gnome-tweaks \
    htop \
    neofetch \
    nload \
    pavucontrol

function gnome_extensions(){
array=( https://extensions.gnome.org/extension/3193/blur-my-shell/
https://extensions.gnome.org/extension/4422/gnome-clipboard/
https://extensions.gnome.org/extension/8/places-status-indicator/
https://extensions.gnome.org/extension/19/user-themes/ )

for i in "${array[@]}"
do
    EXTENSION_ID=$(curl -s $i | grep -oP 'data-uuid="\K[^"]+')
    VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=$EXTENSION_ID" | jq '.extensions[0] | .shell_version_map | map(.pk) | max')
    wget -O ${EXTENSION_ID}.zip "https://extensions.gnome.org/download-extension/${EXTENSION_ID}.shell-extension.zip?version_tag=$VERSION_TAG"
    gnome-extensions install --force ${EXTENSION_ID}.zip
    if ! gnome-extensions list | grep --quiet ${EXTENSION_ID}; then
        busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s ${EXTENSION_ID}
    fi
    gnome-extensions enable ${EXTENSION_ID}
    rm ${EXTENSION_ID}.zip
done
}
echo -e "\nInstalling gnome-extensions..."
gnome_extensions

# Multimedia plugins
echo -e "\nInstalling multimedia plugins..."
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia

# vscode
echo -e "\nInstalling Visual Studio Code..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat <<EOF | sudo tee /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
sudo dnf check-update
sudo dnf install code

# pfetch
echo -e "\nInstalling pfetch..."
git clone https://github.com/dylanaraps/pfetch.git
sudo install pfetch/pfetch /usr/local/bin/
ls -l /usr/local/bin/pfetch
rm -rf pfetch

# git-cli
echo -e "\nInstalling git-cli..."
sudo dnf install 'dnf-command(config-manager)'
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf install gh
echo -e "Done."

# Platform tools
echo -e "\nInstalling Android SDK platform tools..."
wget -q https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip -qq platform-tools-latest-linux.zip
rm platform-tools-latest-linux.zip
echo -e "Done."

# Configure git
echo -e "\nSetting up Git..."

git config --global user.email "whyredfire@gmail.com"
git config --global user.name "Karan Parashar"

git config --global alias.cp 'cherry-pick'
git config --global alias.c 'commit'
git config --global alias.f 'fetch'
git config --global alias.rb 'rebase'
git config --global alias.rs 'reset'
git config --global alias.ck 'checkout'
git config --global credential.helper 'cache --timeout=99999999'
git config --global core.editor "nano"
echo "Done."
