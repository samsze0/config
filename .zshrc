# =============================================================================
# ZSH Plugins
# =============================================================================

# zsh-autosuggestions: Suggests commands as you type based on history/completions
# https://github.com/zsh-users/zsh-autosuggestions
. ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
# Use both command history and shell completions for suggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# zsh-syntax-highlighting: Colors commands as you type them
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
. ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Configure syntax highlighting styles
typeset -A ZSH_HIGHLIGHT_STYLES
# Make valid commands appear in bold blue
ZSH_HIGHLIGHT_STYLES[command]='fg=blue,bold'

# =============================================================================
# Homebrew Configuration (macOS only)
# =============================================================================

if [ $(uname) == "Darwin" ]; then # macOS
	# Define Homebrew installation paths for different architectures
	HOMEBREW_PREFIX="/opt/homebrew"         # Apple Silicon (M1/M2) location
	HOMEBREW_X86_PREFIX="/opt/homebrew-x86" # Intel/Rosetta location

	# Configure shell environment based on current architecture
	if [ $(arch) = "i386" ]; then # Running under Rosetta (Intel compatibility)
		eval "$($HOMEBREW_X86_PREFIX/bin/brew shellenv)"
	else # Running natively on Apple Silicon
		eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
	fi
fi

# =============================================================================
# PATH Configuration
# =============================================================================

# Create personal bin directory if it doesn't exist
mkdir -p "$HOME/bin"
# Add personal bin directory to PATH (highest priority)
export PATH=$HOME/bin:${PATH}
# Ensure /usr/local/bin is in PATH (for locally installed tools)
export PATH=/usr/local/bin:${PATH}

# =============================================================================
# Key Bindings (ZLE - Zsh Line Editor)
# =============================================================================

# Home key: Move cursor to beginning of line
bindkey "^[[H" beginning-of-line
# End key: Move cursor to end of line
bindkey "^[[F" end-of-line
# Ctrl+Backspace: Delete word backwards
bindkey "^H" backward-kill-word
# Ctrl+Left Arrow: Move cursor one word backwards
bindkey "^[[1;5D" backward-word
# Ctrl+Right Arrow: Move cursor one word forwards
bindkey "^[[1;5C" forward-word
