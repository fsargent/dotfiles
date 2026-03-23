#!/usr/bin/env bash
# Enable shell script strictness
set -eu

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Required Homebrew formulas (packages)
REQUIRED_FORMULAS="eza git-delta ripgrep starship mise autojump 1password trunk fish"

# Map formula names to their command names (for formulas where name != command)
# Format: "formula_name:command_name"
FORMULA_COMMAND_MAP="git-delta:delta 1password:op"

# Required Homebrew casks (GUI applications)
REQUIRED_CASKS="1password-cli adguard-vpn cursor discord font-fira-code-nerd-font font-geist-mono font-geist-mono-nerd-font font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font font-monaspace gcloud-cli ghostty keycastr raycast setapp spotify steam tailscale visual-studio-code warp"

# Map cask names to their command names (for casks that install CLI tools)
# Format: "cask_name:command_name"
CASK_COMMAND_MAP="1password-cli:op gcloud-cli:gcloud visual-studio-code:code"

# Function to check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Function to find available shells
find_available_shells() {
	local shells=""
	# Check common shell locations
	for shell_path in /bin/zsh /bin/bash /bin/sh /opt/homebrew/bin/fish /usr/local/bin/fish /bin/fish; do
		if [[ -x ${shell_path} ]]; then
			shells="${shells} ${shell_path}"
		fi
	done
	REPLY="${shells# }"
}

# Function to add shell to /etc/shells if not present
add_shell_to_etc_shells() {
	local shell_path="$1"

	if [[ -z ${shell_path} ]]; then
		return 1
	fi

	# Check if shell is already in /etc/shells
	if grep -Fxq "${shell_path}" /etc/shells 2>/dev/null; then
		return 0
	fi

	# Add shell to /etc/shells (requires sudo)
	printf "\n${YELLOW}Adding ${shell_path} to /etc/shells (requires sudo)...${NC}\n"
	if echo "${shell_path}" | sudo tee -a /etc/shells >/dev/null 2>&1; then
		printf "${GREEN}✓${NC} Added ${shell_path} to /etc/shells\n"
		return 0
	else
		printf "${RED}✗${NC} Failed to add ${shell_path} to /etc/shells\n"
		return 1
	fi
}

# Function to change shell
change_shell() {
	local shell_path="$1"
	local current_shell="${SHELL}"

	if [[ ${shell_path} == "${current_shell}" ]]; then
		printf "${GREEN}✓${NC} Already using ${shell_path}\n"
		return 0
	fi

	# Ensure shell is in /etc/shells
	if ! grep -Fxq "${shell_path}" /etc/shells 2>/dev/null; then
		if ! add_shell_to_etc_shells "${shell_path}"; then
			printf "${RED}Cannot change shell: ${shell_path} is not in /etc/shells${NC}\n"
			return 1
		fi
	fi

	printf "\n${YELLOW}Changing default shell to ${shell_path}...${NC}\n"
	printf "${BLUE}You will be prompted for your password.${NC}\n"

	if chsh -s "${shell_path}"; then
		printf "${GREEN}✓${NC} Shell changed successfully!\n"
		printf "${YELLOW}Note: The change will take effect in new terminal sessions.${NC}\n"
		return 0
	else
		printf "${RED}✗${NC} Failed to change shell\n"
		return 1
	fi
}

# Function to prompt user for shell selection
prompt_shell_selection() {
	local current_shell="${SHELL}"
	local available_shells=""

	find_available_shells
	available_shells="${REPLY}"

	printf "\n${YELLOW}Current shell: ${current_shell}${NC}\n"
	printf "${BLUE}Would you like to change your default shell? (y/n): ${NC}"
	read -r response

	if [[ ${response} != "y" ]] && [[ ${response} != "Y" ]]; then
		printf "${YELLOW}Skipping shell change${NC}\n"
		return 0
	fi

	printf "\n${YELLOW}Available shells:${NC}\n"
	local count=1
	local shell_list=""
	for shell_path in ${available_shells}; do
		local shell_name=""
		shell_name=$(basename "${shell_path}")
		printf "  ${count}) ${shell_path} (${shell_name})\n"
		shell_list="${shell_list} ${shell_path}"
		count=$((count + 1))
	done

	printf "\n${BLUE}Select a shell (1-$((count - 1))) or press Enter to skip: ${NC}"
	read -r selection

	if [[ -z ${selection} ]]; then
		printf "${YELLOW}Skipping shell change${NC}\n"
		return 0
	fi

	# Validate selection
	if ! echo "${selection}" | grep -qE '^[0-9]+$'; then
		printf "${RED}Invalid selection${NC}\n"
		return 1
	fi

	local selected_shell=""
	count=1
	for shell_path in ${shell_list}; do
		if [[ ${count} -eq ${selection} ]]; then
			selected_shell="${shell_path}"
			break
		fi
		count=$((count + 1))
	done

	if [[ -z ${selected_shell} ]]; then
		printf "${RED}Invalid selection${NC}\n"
		return 1
	fi

	change_shell "${selected_shell}"
}

# Function to check if Homebrew is installed
check_homebrew() {
	if command_exists brew; then
		printf "${GREEN}✓${NC} Homebrew is installed\n"
		return 0
	else
		printf "${RED}✗${NC} Homebrew is not installed\n"
		return 1
	fi
}

# Function to install Homebrew
install_homebrew() {
	printf "\n${YELLOW}Installing Homebrew...${NC}\n"
	printf "This will run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"\n"
	printf "${BLUE}Press Enter to continue or Ctrl+C to cancel...${NC}\n"
	read -r
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	# Add Homebrew to PATH
	# Apple Silicon Macs
	if [[ -d "/opt/homebrew/bin" ]]; then
		export PATH="/opt/homebrew/bin:${PATH}"
		eval "$(/opt/homebrew/bin/brew shellenv)"
	# Intel Macs
	elif [[ -d "/usr/local/bin" ]]; then
		export PATH="/usr/local/bin:${PATH}"
		eval "$(/usr/local/bin/brew shellenv)"
	fi
}

# Function to ensure brew is in PATH
ensure_brew_in_path() {
	if ! command_exists brew; then
		# Try to add Homebrew to PATH
		if [[ -d "/opt/homebrew/bin" ]]; then
			export PATH="/opt/homebrew/bin:${PATH}"
			eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
		elif [[ -d "/usr/local/bin" ]]; then
			export PATH="/usr/local/bin:${PATH}"
			eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
		fi
	fi
}

# Function to get command name for a formula
get_formula_command() {
	local formula="$1"
	# Check if there's a mapping
	for mapping in ${FORMULA_COMMAND_MAP}; do
		local formula_name=""
		local command_name=""
		formula_name=$(echo "${mapping}" | cut -d: -f1)
		command_name=$(echo "${mapping}" | cut -d: -f2)
		if [[ ${formula_name} == "${formula}" ]]; then
			REPLY="${command_name}"
			return 0
		fi
	done
	# Default: command name is same as formula name
	REPLY="${formula}"
}

# Function to check if a Homebrew formula is installed
is_formula_installed() {
	local formula="$1"
	local command_name=""

	get_formula_command "${formula}"
	command_name="${REPLY}"

	# First check if command exists in PATH
	if command -v "${command_name}" >/dev/null 2>&1; then
		return 0
	fi

	# Then check Homebrew
	ensure_brew_in_path
	brew list --formula "${formula}" >/dev/null 2>&1
}

# Function to get command name for a cask
get_cask_command() {
	local cask="$1"
	# Check if there's a mapping
	for mapping in ${CASK_COMMAND_MAP}; do
		local cask_name=""
		local command_name=""
		cask_name=$(echo "${mapping}" | cut -d: -f1)
		command_name=$(echo "${mapping}" | cut -d: -f2)
		if [[ ${cask_name} == "${cask}" ]]; then
			REPLY="${command_name}"
			return 0
		fi
	done
	# Default: no command (GUI-only app)
	REPLY=""
}

# Function to check if a Homebrew cask is installed
is_cask_installed() {
	local cask="$1"
	local command_name=""

	get_cask_command "${cask}"
	command_name="${REPLY}"

	# First check if command exists in PATH (for casks that install CLI tools)
	if [[ -n ${command_name} ]]; then
		if command -v "${command_name}" >/dev/null 2>&1; then
			return 0
		fi
	fi

	# Then check Homebrew
	ensure_brew_in_path
	# Check if cask is in the list of installed casks
	# Try --casks (plural) first, then --cask (singular)
	if brew list --casks "${cask}" >/dev/null 2>&1; then
		return 0
	elif brew list --cask "${cask}" >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

# Function to check and install missing formulas
check_and_install_formulas() {
	local missing_formulas=""

	printf "\n${YELLOW}Checking required Homebrew formulas...${NC}\n"
	for formula in ${REQUIRED_FORMULAS}; do
		if is_formula_installed "${formula}"; then
			printf "${GREEN}✓${NC} ${formula} is installed\n"
		else
			printf "${RED}✗${NC} ${formula} is missing\n"
			missing_formulas="${missing_formulas} ${formula}"
		fi
	done

	if [[ -n ${missing_formulas} ]]; then
		printf "\n${YELLOW}Missing formulas:${missing_formulas}${NC}\n"
		printf "${BLUE}Would you like to install them? (y/n): ${NC}"
		read -r response
		if [[ ${response} == "y" ]] || [[ ${response} == "Y" ]]; then
			ensure_brew_in_path
			printf "\n${YELLOW}Installing missing formulas...${NC}\n"
			# Install all missing formulas in one command
			brew install "${missing_formulas}" || printf "${RED}Some formulas failed to install${NC}\n"
		else
			printf "${YELLOW}Skipping formula installation${NC}\n"
		fi
	else
		printf "${GREEN}✓ All required formulas are installed${NC}\n"
	fi
}

# Function to check and install missing casks
check_and_install_casks() {
	local missing_casks=""

	printf "\n${YELLOW}Checking required Homebrew casks...${NC}\n"
	for cask in ${REQUIRED_CASKS}; do
		if is_cask_installed "${cask}"; then
			printf "${GREEN}✓${NC} ${cask} is installed\n"
		else
			printf "${RED}✗${NC} ${cask} is missing\n"
			missing_casks="${missing_casks} ${cask}"
		fi
	done

	if [[ -n ${missing_casks} ]]; then
		printf "\n${YELLOW}Missing casks:${missing_casks}${NC}\n"
		printf "${BLUE}Would you like to install them? (y/n): ${NC}"
		read -r response
		if [[ ${response} == "y" ]] || [[ ${response} == "Y" ]]; then
			ensure_brew_in_path
			printf "\n${YELLOW}Installing missing casks...${NC}\n"
			# Install all missing casks in one command
			brew install --cask "${missing_casks}" || printf "${RED}Some casks failed to install${NC}\n"
		else
			printf "${YELLOW}Skipping cask installation${NC}\n"
		fi
	else
		printf "${GREEN}✓ All required casks are installed${NC}\n"
	fi
}

# Function to create symlink with feedback
link_config() {
	local src="$1"
	local dest="$2"
	local name="$3"
	local fix_automatically="${4-}" # Optional: "yes" to fix automatically

	if [[ -e ${dest} ]]; then
		if [[ -L ${dest} ]]; then
			# It's already a symlink
			current_target=$(readlink "${dest}")
			if [[ ${current_target} == "${src}" ]]; then
				printf "${GREEN}✓${NC} ${name} already linked correctly\n"
				return 0
			else
				printf "${YELLOW}⚠${NC} ${name} symlink points to wrong target\n"
				printf "  Current: ${current_target}\n"
				printf "  Expected: ${src}\n"
				return 1
			fi
		else
			# File/dir exists but is NOT a symlink
			printf "${RED}✗${NC} ${name} exists but is NOT a symlink\n"
			printf "  Location: ${dest}\n"
			printf "  Expected symlink target: ${src}\n"

			# Show diff using delta if both exist and delta is available
			if [[ -e ${src} ]] && command_exists delta; then
				if [[ -f ${dest} ]] && [[ -f ${src} ]]; then
					printf "\n${BLUE}File differences:${NC}\n"
					diff -u "${dest}" "${src}" 2>/dev/null | delta 2>/dev/null || true
				elif [[ -d ${dest} ]] && [[ -d ${src} ]]; then
					printf "\n${BLUE}Directory differences:${NC}\n"
					diff -u "${dest}" "${src}" 2>/dev/null | delta 2>/dev/null || true
				fi
			fi

			# Ask if user wants to fix it (unless fix_automatically is set)
			if [[ ${fix_automatically} != "yes" ]]; then
				printf "\n${BLUE}Would you like to backup and replace it with a symlink? (y/n): ${NC}"
				read -r response
				if [[ ${response} != "y" ]] && [[ ${response} != "Y" ]]; then
					return 1
				fi
			fi

			# Backup and replace
			local backup_dest="${dest}.backup.$(date +%s)"
			if mv "${dest}" "${backup_dest}" 2>/dev/null; then
				printf "${YELLOW}  Backed up to: ${backup_dest}${NC}\n"
				if ln -s "${src}" "${dest}"; then
					printf "${GREEN}✓${NC} ${name} linked successfully (backup created)\n"
					return 0
				else
					printf "${RED}✗${NC} Failed to create symlink, restoring backup...\n"
					mv "${backup_dest}" "${dest}" 2>/dev/null
					return 1
				fi
			else
				printf "${RED}✗${NC} Failed to backup ${dest}\n"
				return 1
			fi
		fi
	else
		# Doesn't exist, create the symlink
		if ln -s "${src}" "${dest}"; then
			printf "${GREEN}✓${NC} ${name} linked successfully\n"
			return 0
		else
			printf "${RED}✗${NC} Failed to create symlink for ${name}\n"
			return 1
		fi
	fi
}

# Link a config and record failures without relying on shell conditionals.
track_link() {
	local src="$1"
	local dest="$2"
	local name="$3"

	set +e
	link_config "${src}" "${dest}" "${name}"
	local status=$?
	set -e

	if [[ ${status} -ne 0 ]]; then
		failed=$((failed + 1))
		failed_items="${failed_items}\n  - ${name}"
	fi
}

# Retry a failed link and count successful automatic fixes.
attempt_fix_link() {
	local failed_label="$1"
	local src="$2"
	local dest="$3"
	local name="$4"

	if printf '%b' "${failed_items}" | grep -Fq "${failed_label}"; then
		set +e
		link_config "${src}" "${dest}" "${name}" "yes"
		local status=$?
		set -e

		if [[ ${status} -eq 0 ]]; then
			fixed=$((fixed + 1))
		fi
	fi
}

# Main setup flow
main() {
	printf "\n${BLUE}╔════════════════════════════════════════╗${NC}\n"
	printf "${BLUE}║     Dotfiles Setup Script              ║${NC}\n"
	printf "${BLUE}╚════════════════════════════════════════╝${NC}\n\n"

	# Ensure brew is in PATH before checking
	ensure_brew_in_path

	# Ask if user wants to check Homebrew apps first
	printf "${BLUE}Would you like to check and install Homebrew packages first? (y/n): ${NC}"
	read -r check_brew_response
	if [[ ${check_brew_response} == "y" ]] || [[ ${check_brew_response} == "Y" ]]; then
		# Check for Homebrew
		if ! check_homebrew; then
			printf "\n${YELLOW}Homebrew is required to install dependencies.${NC}\n"
			printf "${BLUE}Would you like to install Homebrew now? (y/n): ${NC}"
			read -r response
			if [[ ${response} == "y" ]] || [[ ${response} == "Y" ]]; then
				install_homebrew
				# Verify installation
				if ! check_homebrew; then
					printf "${RED}Homebrew installation failed. Please install manually and run this script again.${NC}\n"
					exit 1
				fi
			else
				printf "${RED}Cannot proceed without Homebrew. Exiting.${NC}\n"
				exit 1
			fi
		fi

		# Check and install missing formulas
		check_and_install_formulas

		# Ask about casks (optional, as they're GUI apps)
		printf "\n${YELLOW}Would you like to check and install GUI applications (casks)? (y/n): ${NC}"
		read -r response
		if [[ ${response} == "y" ]] || [[ ${response} == "Y" ]]; then
			check_and_install_casks
		else
			printf "${YELLOW}Skipping cask installation${NC}\n"
		fi
	else
		printf "${YELLOW}Skipping Homebrew package checks${NC}\n"
	fi

	# Prompt for shell selection
	prompt_shell_selection

	# Ensure config directories exist
	mkdir -p ~/.config
	mkdir -p ~/.config/ghostty

	printf "\n${YELLOW}Setting up dotfiles symlinks...${NC}\n\n"

	# Track failures and failed items
	local failed=0
	local failed_items=""

	# Link configurations
	track_link "${PWD}/config/git" ~/.config/git "Git config"
	track_link "${PWD}/config/zsh" ~/.config/zsh "Zsh config"
	track_link "${PWD}/config/fish" ~/.config/fish "Fish config"
	track_link "${PWD}/config/kanata" ~/.config/kanata "Kanata config"
	track_link "${PWD}/config/nvim" ~/.config/nvim "Neovim config"
	track_link "${PWD}/config/helix" ~/.config/helix "Helix config"
	track_link "${PWD}/config/ghostty/config" ~/.config/ghostty/config "Ghostty config"
	track_link "${PWD}/config/ghostty/themes" ~/.config/ghostty/themes "Ghostty themes"
	track_link "${PWD}/starship.toml" ~/.config/starship.toml "Starship config"
	track_link "${PWD}/config/ripgreprc" ~/.config/ripgreprc "Ripgrep config"
	track_link "${PWD}/config/zsh/.zshrc" ~/.zshrc ".zshrc"
	track_link "${PWD}/config/zsh/.zshenv" ~/.zshenv ".zshenv"

	# Report results
	printf "\n"
	if [[ ${failed} -eq 0 ]]; then
		printf "${GREEN}✓ All symlinks set up successfully!${NC}\n"
		printf "\n${GREEN}Setup complete! You may need to restart your terminal for changes to take effect.${NC}\n"
		exit 0
	else
		printf "${RED}✗ Setup completed with ${failed} failure(s)${NC}\n"
		printf "${YELLOW}Failed items:${failed_items}${NC}\n"
		printf "\n${BLUE}Would you like to try fixing the failed symlinks automatically? (y/n): ${NC}"
		read -r fix_response
		if [[ ${fix_response} == "y" ]] || [[ ${fix_response} == "Y" ]]; then
			printf "\n${YELLOW}Attempting to fix failed symlinks...${NC}\n\n"
			local fixed=0

			# Try to fix each failed item by checking the failed_items string
			attempt_fix_link "Git config" "${PWD}/config/git" ~/.config/git "Git config"
			attempt_fix_link "Zsh config" "${PWD}/config/zsh" ~/.config/zsh "Zsh config"
			attempt_fix_link "Fish config" "${PWD}/config/fish" ~/.config/fish "Fish config"
			attempt_fix_link "Kanata config" "${PWD}/config/kanata" ~/.config/kanata "Kanata config"
			attempt_fix_link "Neovim config" "${PWD}/config/nvim" ~/.config/nvim "Neovim config"
			attempt_fix_link "Helix config" "${PWD}/config/helix" ~/.config/helix "Helix config"
			attempt_fix_link "Ghostty config" "${PWD}/config/ghostty/config" ~/.config/ghostty/config "Ghostty config"
			attempt_fix_link "Ghostty themes" "${PWD}/config/ghostty/themes" ~/.config/ghostty/themes "Ghostty themes"
			attempt_fix_link "Starship config" "${PWD}/starship.toml" ~/.config/starship.toml "Starship config"
			attempt_fix_link "Ripgrep config" "${PWD}/config/ripgreprc" ~/.config/ripgreprc "Ripgrep config"
			attempt_fix_link ".zshrc" "${PWD}/config/zsh/.zshrc" ~/.zshrc ".zshrc"
			attempt_fix_link ".zshenv" "${PWD}/config/zsh/.zshenv" ~/.zshenv ".zshenv"

			printf "\n${GREEN}Fixed ${fixed} of ${failed} failed symlink(s)${NC}\n"
			printf "${GREEN}Setup complete!${NC}\n"
			exit 0
		else
			printf "\nTo fix manually:\n"
			printf "  1. Backup the file: mv ~/.config/file ~/.config/file.backup\n"
			printf "  2. Re-run this script: ./setup.sh\n"
			exit 1
		fi
	fi
}

# Run main setup
main
