#!/bin/zsh

# Update PATH for given package
update_path() {
  set +x

  # Create or update the .zshrc file with updated PATH
  cat <<EOL>> ~/.zshrc

  # Add $1 executables to PATH
  export PATH="$2:\$PATH"

EOL
# Do NOT update the indentation of 'EOL' as the script will fail if 'EOL' has any indentation

  source ~/.zshrc
  set -x
}

# Update PATH for given package
update_java_home() {
  set +x

  # Create or update the .zshrc file with JAVA_HOME
  cat <<EOL>> ~/.zshrc

  export JAVA_HOME="$(brew --prefix openjdk@$1)"
  
EOL
# Do NOT update the indentation of 'EOL' as the script will fail if 'EOL' has any indentation

  source ~/.zshrc
  set -x
  echo $JAVA_HOME

}

# Function to install Homebrew on macOS
install_homebrew() {
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Update path to include brew
  update_path brew /opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

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

  update_java_home 17

  echo "Installing Gradle..."
  brew install gradle
  
  echo "Installing Android Studio..."
  brew install --cask android-studio

  update_path android-studio ~/Android/sdk/platform-tools
  update_path gradle /usr/local/opt/gradle/bin
}

# Function to update .zshrc with aliases
update_zshrc() {
  echo "Updating .zshrc with common aliases..."
  set +x
  
  # Create or update the .zshrc file with the aliases
  cat <<EOL>> ~/.zshrc

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
    if [ \$# -lt 1 ]
    then
      echo "Usage: \$funcstack[1] <Action filename>"
      return
    fi

    local branch_name=\$(git rev-parse --abbrev-ref HEAD)
    ghRun \$1 \$branch_name
    gh workflow run \$1 -r \$branch_name
  }

  ghRunWatch() {
    if [ \$# -lt 2 ]
    then
      echo "Usage: \$funcstack[1] <Action filename> <branch>"
      return
    fi

    local branch_name=\$(git rev-parse --abbrev-ref HEAD)
    ghRun \$1 \$branch_name
    run_id=\$(gh run list --json databaseId --workflow=\$1 --limit 1 -q '.[0].databaseId')
    ghWatch \$run_id && notify-send 'run is done!'
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
  source ~/.zshrc
  echo ".zshrc has been updated and changes applied."
}

# Main installation workflow
install_homebrew
install_packages

update_zshrc

echo "Installation complete!"
