#!/bin/zsh

# Function to install Homebrew on macOS
install_homebrew() {
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

# Function to install Git, GitHub CLI, Gradle, and Android Studio
install_packages() {
  echo "Installing Git..."
  brew install git
  
  echo "Installing GitHub CLI..."
  brew install gh

  echo "Installing Java 11..."
  brew install openjdk@11 

  echo "Installing Java 17..."
  brew install openjdk@17 
  
  echo "Installing Gradle..."
  brew install gradle
  
  echo "Installing Android Studio..."
  brew install --cask android-studio
}

# Function to update .zshrc with aliases
update_zshrc() {
  echo "Updating .zshrc with common aliases..."
  
  # Create or update the .zshrc file with the aliases
  cat <<EOL >> ~/.zshrc

  # Add commands to PATH
  export PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:~/Android/sdk/platform-tools:/usr/local/opt/gradle/bin"

  # Set Java to default to v17
  export JAVA_HOME=$(/usr/libexec/java_home -v 17)

  # Common aliases for Git
  alias g='git'
  alias gs='git status'
  alias ga='git add'
  alias gc='git commit'
  alias gcm='git commit -m'
  alias gp='git push'
  alias gl='git pull'
  alias gco='git checkout'
  alias gbr='git branch'
  alias gcl='git clone'
  alias gpr='gh pr list'

  # Common aliases for Gradle
  alias gw='./gradlew'
  alias gbuild='gw build'
  alias gtest='gw test'
  alias gCAT='gw connectedAndroidTest'
  alias gclean='gw clean'

  # Common aliases for GitHub
  alias ghWatch = 'gh run watch'
  ghRun() {
    if [ $# -lt 2 ]
    then
      echo "Usage: $funcstack[1] <Action filename> <branch>"
      return
    fi

    gh workflow run $1 -r $2
  }

  ghRunWatch() {
    if [ $# -lt 2 ]
    then
      echo "Usage: $funcstack[1] <Action filename> <branch>"
      return
    fi

    ghRun $1 $2
    run_id=$(gh run list --json databaseId --workflow=$1 --limit 1 -q '.[0].databaseId')
    ghWatch $run_id && notify-send 'run is done!'
  }
  
  update_prompt() {
     # Default prompt 
     local DEFAULT_PROMPT="%n@%m %1~ %# "

     # Check if in a Git repository
     if git rev-parse --is-inside-work-tree &>/dev/null; then
        # If in a Git repo, set a specific prompt with branch name
        local branch_name=$(git rev-parse --abbrev-ref HEAD)

        autoload -U colors && colors

        # Format the vcs_info_msg_0_ variable
        zstyle ':vcs_info:git:*' formats '%b'

        # Set up the prompt (with git branch name)
        PROMPT="[%1~] %{$fg[green]%}$branch_name%{$reset_color%} %# "
     else
        # Use default prompt
        PROMPT="$DEFAULT_PROMPT"
     fi   
  }
  
  # Call the update_prompt function to set the initial prompt
  update_prompt
    
  # Automatically update the prompt when the directory changes
  chpwd_functions+=(update_prompt)

  EOL

  source ~/.zshrc
  echo ".zshrc updated!"
}

# Main installation workflow
install_homebrew
install_packages

update_zshrc

echo "Installation complete!"
