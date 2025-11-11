# # #!/bin/zsh
# # ==============================================================================
# # Title: setup.sh
# # Author: Grace Hughes
# # Email: gracehughes2706@gmail.com
# # Description: Script for laptop setup
# # ==============================================================================


source ./config

error='\033[0;31m'
section='\033[104m'
info='\033[92m'
reset='\033[0m'


# Start
echo "${info}                                     "
echo "          _                    _     "
echo " ___  ___| |_ _   _ _ __   ___| |__  "
echo "/ __|/ _ \ __| | | | '_ \ / __| '_ \ "
echo "\__ \  __/ |_| |_| | |_) |\__ \ | | |"
echo "|___/\___|\__|\__,_| .__(_)___/_| |_|"
echo "                   |_|               "
echo "                                     ${reset}"

# Get root password
echo "Enter root password... "

# Ask for the administrator password upfront.
sudo -v

# Keep Sudo until script is finished
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &


# Update MacOS
echo "\n\n${section} - - - - - - - - - - -  U P D A T I N G    M A C  - - - - - - - - - - -${reset}"
echo "${info}Looking for updates..${reset}"
sudo softwareupdate -i -a
clear


# Install Rosetta
echo "\n\n${section} - - - - - - - - - - -  I N S T A L L I N G   R O S E T T A  - - - - - - - - - - -${reset}"
sudo softwareupdate --install-rosetta --agree-to-license
clear


# Install Homebrew
echo "\n\n${section} - - - - - - - - - - -  I N S T A L L I N G   H O M E B R E W  - - - - - - - - - - -${reset}"
echo "${info}Installing Homebrew${reset}"
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> /Users/gracehughes/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/gracehughes/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Check installation and update
echo "${info}Checking Homebrew installation...${reset}"
brew update && brew doctor
export HOMEBREW_NO_INSTALL_CLEANUP=1
clear


# Homebrew installs - Formulae
echo "\n\n${section} - - - - - - - - - - -  I N S T A L L I N G   H O M E B R E W   F O M U L A E  - - - - - - - - - - -${reset}"
echo "${info}Installing Formulae ...${reset}"
for tool in "${TOOLS[@]}"; do
brew install "$tool"
if [ $? -ne 0 ]; then
    echo "${error}Failed to install $tool. Continuing...${reset}"
fi
done
clear


echo "\n\n${section} - - - - - - - - - - -  H O M E B R E W   F O M U L A E  - - - - - - - - - - -${reset}"
echo "${info}Homebrew Formulae${reset}"
brew list --formulae -l
clear


# Homebrew installs - Casks
echo "\n\n${section} - - - - - - - - - - -  I N S T A L L I N G   H O M E B R E W   C A S K S  - - - - - - - - - - -${reset}"
echo "${info}Installing casks...${reset}"
for cask in "${CASKS[@]}"; do
brew install --cask "$cask"
if [ $? -ne 0 ]; then
    echo "${error}Failed to install $cask. Continuing...${reset}"
fi
done
clear


echo "\n\n${section} - - - - - - - - - - -  H O M E B R E W   C A S K S  - - - - - - - - - - -${reset}"
echo "${info} Homebrew Casks${reset}"
brew list --casks -l
clear


#Install VS Code Extensions
echo "\n\n${section} - - - - - - - - - - -  I N S T A L L I N G   V S C O D E   E X T E N S I O N S   - - - - - - - - - - -${reset}"
# Export path to use `code` command
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
echo "${info}Install VSCode Extensions? ${reset}[y/N]"
read REPLY
if [[ $REPLY =~ ^[Yy]$ ]]; then
for extension in "${VSCODE[@]}"; do
    code --install-extension "$extension"
done
fi
clear


# Install NPM Packages
echo "\n\n${section} - - - - - - - - - - -  I N S T A L L I N G   G L O B A L   N P M   P A C K A G E S   - - - - - - - - - - -${reset}"
echo "${info}Installing Global NPM Packages..."
npm install -g ${NPMPACKAGES[@]}
clear

# Install AWS CLI
echo "\n\n${section} - - - - - - - - - - - - - - - - - - - - - -  I N S T A L L I N G   A W S   C L I  - - - - - - - - - - - - - - - - - - - - - -${reset}"
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg ./AWSCLIV2.pkg -target /
echo "${info}\nValidating install..."
which aws
aws --version

# Cleanup
echo "\n\n${section} - - - - - - - - - - -  C L E A N I N G   U P . . .   - - - - - - - - - - -${reset}"
echo "${info}Cleaning up..."
brew update && brew upgrade && brew cleanup && brew doctor
mkdir -p ~/Library/LaunchAgents
brew tap homebrew/autoupdate
brew autoupdate start $HOMEBREW_UPDATE_FREQUENCY --upgrade --cleanup --immediate --sudo
clear


# Settings
echo "\n\n${section} - - - - - - - - - - -  I N S T A L L I N G   S Y S T E M   S E T T I N G S   - - - - - - - - - - -${reset}"
echo "${error}Configure default system settings? ${reset}[Y/n]"
read REPLY
if [[ -z $REPLY || $REPLY =~ ^[Yy]$ ]]; then
  echo "${info}Configuring default settings..."
  for setting in "${SETTINGS[@]}"; do
    eval $setting
  done
fi
clear


# Dock settings
echo "\n\n${section} - - - - - - - - - - -  U P D A T I N G   D O C K   - - - - - - - - - - -${reset}"
echo "${info}Update Dock? [y/N]${reset}"
read REPLY
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Handle additions
  for app in "${DOCK_ADD[@]}"; do
    echo "Adding $app to dock"
    dockutil --add "$app" &>/dev/null
  done
  # # Handle removals
  for app in "${DOCK_REMOVE[@]}"; do
    echo "Removing $app from dock"
    dockutil --remove "$app" &>/dev/null
  done
  defaults write com.apple.dock show-recents -bool false && killall
fi
clear


# Git Login
echo "\n\n${section} - - - - - - - - - - -  S E T T I N G   U P   G I T   - - - - - - - - - - -${reset}"
echo "${info}Please enter your git username:${reset}"
read name
echo "${info}Please enter your git email:${reset}"
read email

git config --global user.name "$name"
git config --global user.email "$email"
git config --global color.ui true
clear

if [ ! -f ~/.ssh/id_ed25519.pub ]; then
  ssh-keygen -t ed25519 -C "$email"
  echo "${info}Key created"
fi
pbcopy < ~/.ssh/id_ed25519.pub
echo "\n${section} Setting up new git SSH key for github. The key has been copied to your clipboard please create a new key at https://github.com/settings/ssh/new.${reset}"
printf "${error}"
read -p $'(ACTION REQUIRED) Press any key to continue once you have set up your SSH key\n'
clear

echo "\n\n${section} - - - - - - - - - - -  I N S T A L L I N G   Z S H   - - - - - - - - - - -${reset}"
ohmyzsh
echo "${info}Installing ohmyzsh!"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# update zsh configuration
sed -i t.bak s/ZSH_THEME\=\"robbyrussell\"/ZSH_THEME\=\"awesomepanda\"/g /Users/$USER/.zshrc
clear

# Add zsh alias'\
echo "\n\n${section} - - - - - - - - - - -  C R E A T I N G   A L I A S '   - - - - - - - - - - -${reset}"
echo "\n\n# # # # # # ALIAS' # # # # # #" >> ~/.zshrc
for a in  "${ALIAS[@]}"; do
echo "alias ${a}" >> ~/.zshrc
if [ $? -ne 0 ]; then
    echo "${error}Failed to add alias $a . Continuing...${reset}"
fi
done
clear

echo "${info}                                                                         "
echo " ____       _                  ____                      _      _        "
echo "/ ___|  ___| |_ _   _ _ __    / ___|___  _ __ ___  _ __ | | ___| |_ ___  "
echo "\___ \ / _ \ __| | | | '_ \  | |   / _ \| '_ \` _ \| '_ \| |/ _ \ __/ _ \ "
echo " ___) |  __/ |_| |_| | |_) | | |__| (_) | | | | | | |_) | |  __/ ||  __/ "
echo "|____/ \___|\__|\__,_| .__/   \____\___/|_| |_| |_| .__/|_|\___|\__\___| "
echo "                     |_|                          |_|                    "
echo "                                                                         ${reset}"

sleep 2

printf "${error}"
read -p $'Press ANY KEY to REBOOT \n'
sleep 2
sudo reboot
exit
