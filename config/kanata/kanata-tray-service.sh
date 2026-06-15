#!/bin/bash

# Manage kanata-tray as a user LaunchAgent on macOS.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_NAME="com.user.kanata-tray.plist"
SOURCE_PLIST_PATH="${SCRIPT_DIR}/${PLIST_NAME}"
DEST_PLIST_PATH="${HOME}/Library/LaunchAgents/${PLIST_NAME}"
SERVICE_LABEL="com.user.kanata-tray"
LOG_DIR="${HOME}/Library/Logs/kanata-tray"
OLD_DAEMON_PLIST="/Library/LaunchDaemons/com.user.kanata.plist"
OLD_DAEMON_LABEL="com.user.kanata"
SUDOERS_PATH="/etc/sudoers.d/kanata"
OLD_TRAY_SUDOERS_PATH="/etc/sudoers.d/kanata-tray"
GUI_UID="$(id -u)"

find_kanata() {
	if [[ -x /usr/local/bin/kanata ]]; then
		echo /usr/local/bin/kanata
	elif [[ -x /opt/homebrew/bin/kanata ]]; then
		echo /opt/homebrew/bin/kanata
	else
		return 1
	fi
}

find_kanata_tray() {
	if command -v kanata-tray >/dev/null 2>&1; then
		command -v kanata-tray
	elif [[ -x /opt/homebrew/bin/kanata-tray ]]; then
		echo /opt/homebrew/bin/kanata-tray
	else
		return 1
	fi
}

is_loaded() {
	launchctl print "gui/${GUI_UID}/${SERVICE_LABEL}" >/dev/null 2>&1
}

render_plist() {
	local kanata_tray_bin="$1"
	sed \
		-e "s|__HOME__|${HOME}|g" \
		-e "s|__KANATA_TRAY_BIN__|${kanata_tray_bin}|g" \
		"${SOURCE_PLIST_PATH}"
}

bootout_launch_agent() {
	launchctl bootout "gui/${GUI_UID}/${SERVICE_LABEL}" 2>/dev/null
}

unload_launch_agent() {
	launchctl unload "${DEST_PLIST_PATH}" 2>/dev/null
}

bootstrap_launch_agent() {
	launchctl bootstrap "gui/${GUI_UID}" "${DEST_PLIST_PATH}" 2>/dev/null
}

load_launch_agent() {
	launchctl load "${DEST_PLIST_PATH}" 2>/dev/null
}

remove_old_system_daemon() {
	if [[ ! -f ${OLD_DAEMON_PLIST} ]]; then
		return 0
	fi

	echo "Removing legacy system kanata daemon..."
	sudo launchctl bootout "system/${OLD_DAEMON_LABEL}" 2>/dev/null ||
		sudo launchctl unload "${OLD_DAEMON_PLIST}" 2>/dev/null || true
	sudo rm -f "${OLD_DAEMON_PLIST}"
	sudo rm -f /etc/newsyslog.d/kanata.conf
	echo "Legacy system daemon removed."
}

install_sudoers() {
	local kanata_bin="$1"
	local kanata_hash
	kanata_hash="$(shasum -a 256 "${kanata_bin}" | awk '{print $1}')"

	echo "Installing passwordless sudo for kanata..."
	echo "${USER} ALL=(root) NOPASSWD: sha256:${kanata_hash} ${kanata_bin}" |
		sudo tee "${SUDOERS_PATH}" >/dev/null
	sudo chmod 440 "${SUDOERS_PATH}"
	sudo visudo -cf "${SUDOERS_PATH}" >/dev/null

	if [[ -f ${OLD_TRAY_SUDOERS_PATH} ]]; then
		echo "Removing legacy kanata-tray sudoers entry..."
		sudo rm -f "${OLD_TRAY_SUDOERS_PATH}"
	fi
}

install_service() {
	local kanata_bin kanata_tray_bin
	local kanata_status kanata_tray_status bootstrap_status load_status

	set +e
	kanata_bin="$(find_kanata)"
	kanata_status=$?
	kanata_tray_bin="$(find_kanata_tray)"
	kanata_tray_status=$?
	set -e

	if [[ ${kanata_status} -ne 0 ]]; then
		echo "ERROR: kanata not found. Install it first (e.g. brew install kanata)."
		exit 1
	fi
	if [[ ${kanata_tray_status} -ne 0 ]]; then
		echo "ERROR: kanata-tray not found. Install it first (e.g. brew install kanata-tray)."
		exit 1
	fi

	chmod +x "${SCRIPT_DIR}/kanata-root.sh"
	mkdir -p "${HOME}/Library/LaunchAgents" "${LOG_DIR}"

	remove_old_system_daemon
	install_sudoers "${kanata_bin}"

	echo "Installing kanata-tray LaunchAgent..."
	render_plist "${kanata_tray_bin}" >"${DEST_PLIST_PATH}"

	bootout_launch_agent || true

	set +e
	bootstrap_launch_agent
	bootstrap_status=$?
	set -e
	if [[ ${bootstrap_status} -eq 0 ]]; then
		echo "kanata-tray installed and started."
		return 0
	fi

	set +e
	load_launch_agent
	load_status=$?
	set -e
	if [[ ${load_status} -eq 0 ]]; then
		echo "kanata-tray installed and started (using legacy load command)."
		return 0
	fi

	echo "ERROR: Failed to load kanata-tray LaunchAgent."
	exit 1
}

uninstall_service() {
	echo "Uninstalling kanata-tray LaunchAgent..."
	bootout_launch_agent || unload_launch_agent || true
	rm -f "${DEST_PLIST_PATH}"
	sudo rm -f "${SUDOERS_PATH}"
	echo "kanata-tray LaunchAgent removed."
}

start_service() {
	local bootstrap_status load_status loaded_status

	if [[ ! -f ${DEST_PLIST_PATH} ]]; then
		echo "Service not installed. Run './kanata-tray-service.sh install' first."
		exit 1
	fi

	set +e
	is_loaded
	loaded_status=$?
	set -e
	if [[ ${loaded_status} -eq 0 ]]; then
		echo "kanata-tray is already running."
		exit 0
	fi

	set +e
	bootstrap_launch_agent
	bootstrap_status=$?
	set -e
	if [[ ${bootstrap_status} -ne 0 ]]; then
		set +e
		load_launch_agent
		load_status=$?
		set -e
		if [[ ${load_status} -ne 0 ]]; then
			echo "ERROR: Failed to start kanata-tray LaunchAgent."
			exit 1
		fi
	fi
	echo "kanata-tray started."
}

stop_service() {
	if [[ ! -f ${DEST_PLIST_PATH} ]]; then
		echo "Service not installed."
		exit 1
	fi
	bootout_launch_agent || unload_launch_agent || true
	echo "kanata-tray stopped."
}

restart_service() {
	stop_service
	sleep 1
	start_service
}

show_status() {
	local loaded_status

	if [[ ! -f ${DEST_PLIST_PATH} ]]; then
		echo "kanata-tray is NOT INSTALLED."
		exit 0
	fi

	set +e
	is_loaded
	loaded_status=$?
	set -e
	if [[ ${loaded_status} -eq 0 ]]; then
		echo "kanata-tray is RUNNING."
	else
		echo "kanata-tray is STOPPED."
	fi
}

show_logs() {
	mkdir -p "${LOG_DIR}"
	if [[ -f ${LOG_DIR}/kanata_tray_lastrun.log ]]; then
		tail -f "${LOG_DIR}/kanata_tray_lastrun.log"
	else
		echo "Log file not found in ${LOG_DIR}."
		exit 1
	fi
}

case "${1-}" in
install) install_service ;;
uninstall) uninstall_service ;;
start) start_service ;;
stop) stop_service ;;
restart) restart_service ;;
status) show_status ;;
logs) show_logs ;;
*)
	echo "Usage: $0 {install|uninstall|start|stop|restart|status|logs}"
	exit 1
	;;
esac
