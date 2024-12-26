#!/bin/zsh

# Update PATH for given package
update_path() {
  echo "Updating PATH to include $1..."
  
  # Create or update the .zshrc file with the aliases
  cat <<EOL>> ~/.zshrc

  # Add $1 executables to PATH
  export PATH="$2:\$PATH"

EOL
# Do NOT update the indentation of 'EOL' as the script will fail if 'EOL' has any indentation

  source ~/.zshrc
  cat ~/.zshrc
  echo $PATH
  echo ".zshrc has been updated and changes applied."


}

# Function to install Homebrew on macOS
install_homebrew() {
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Update path to include brew
  update_path brew /usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

  fi
}

# Function to install Git, GitHub CLI, Gradle, and Android Studio
install_packages() {
  echo "Installing Git..."
  /usr/bin/brew install git
  
  echo "Installing GitHub CLI..."
  /usr/bin/brew install gh

  echo "Installing Java 11..."
  /usr/bin/brew install openjdk@11 

  echo "Installing Java 17..."
  /usr/bin/brew install openjdk@17 
  
  echo "Installing Gradle..."
  /usr/bin/brew install gradle
  
  echo "Installing Android Studio..."
  /usr/bin/brew install --cask android-studio

  update_path android-studio ~/Android/sdk/platform-tools
  update_path gradle /usr/local/opt/gradle/bin
}

# Function to update .zshrc with aliases
update_zshrc() {
  echo "Updating .zshrc with common aliases..."
  set +x
  
  # Create or update the .zshrc file with the aliases
  cat <<EOL>> ~/.zshrc

  # Set Java to default to v17
  export JAVA_HOME=\$(/usr/libexec/java_home -v 17)

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
  alias ghWatch='gh run watch'
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
        local branch_name=\$(git rev-parse --abbrev-ref HEAD)

        # Set up the prompt (with git branch name)
        PROMPT="[%1~] %{$fg[green]%}\$branch_name%{\$reset_color%} %# "
     else
        # Use default prompt
        PROMPT="\$DEFAULT_PROMPT"
     fi   
  }
  
  # Call the update_prompt function to set the initial prompt
  update_prompt
    
  # Automatically update the prompt when the directory changes
  chpwd_functions+=(update_prompt)
      
  # Automatically update the prompt when the branch changes
  precmd_functions+=(update_prompt)

EOL
# Do NOT update the indentation of 'EOL' as the script will fail if 'EOL' has any indentation

  set -x
  echo ".zshrc has been updated and changes applied."
  source ~/.zshrc
  echo ".zshrc updated!"
  echo $PATH
}

# Main installation workflow
install_homebrew
install_packages

update_zshrc

echo "Installation complete!"
