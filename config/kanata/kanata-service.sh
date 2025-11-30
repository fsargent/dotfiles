#!/bin/bash

# A script to manage the Kanata launchd service on macOS.

PLIST_NAME="com.user.kanata.plist"
SOURCE_PLIST_PATH="./${PLIST_NAME}"
DEST_PLIST_PATH="/Library/LaunchDaemons/${PLIST_NAME}"
SERVICE_LABEL="com.user.kanata"
LOG_PATH="/var/log/kanata.log"
LOG_ROTATION_CONF="kanata.conf"
LOG_ROTATION_DEST="/etc/newsyslog.d/${LOG_ROTATION_CONF}"

# Function to check if the service is loaded
is_loaded() {
    sudo launchctl list | grep -q "${SERVICE_LABEL}" || \
    sudo launchctl print system/${SERVICE_LABEL} >/dev/null 2>&1
}

# Main script logic
case "$1" in
    install)
        echo "Installing Kanata system service..."
        if [ ! -f "${SOURCE_PLIST_PATH}" ]; then
            echo "ERROR: ${PLIST_NAME} not found in the current directory."
            exit 1
        fi
        if [ -f "${DEST_PLIST_PATH}" ]; then
            echo "Service file already exists at ${DEST_PLIST_PATH}. Uninstalling first."
            sudo launchctl bootout system/${SERVICE_LABEL} 2>/dev/null || \
            sudo launchctl unload "${DEST_PLIST_PATH}" 2>/dev/null
        fi
        sudo cp "${SOURCE_PLIST_PATH}" "${DEST_PLIST_PATH}"
        if sudo launchctl bootstrap system "${DEST_PLIST_PATH}" 2>/dev/null; then
            echo "Kanata service installed and loaded."
        elif sudo launchctl load "${DEST_PLIST_PATH}" 2>/dev/null; then
            echo "Kanata service installed and loaded (using legacy load command)."
        else
            echo "ERROR: Failed to load Kanata service."
            exit 1
        fi
        if [ -f "${LOG_ROTATION_CONF}" ]; then
            echo "Installing log rotation configuration..."
            sudo cp "${LOG_ROTATION_CONF}" "${LOG_ROTATION_DEST}"
        fi
        ;;
    uninstall)
        echo "Uninstalling Kanata system service..."
        if [ ! -f "${DEST_PLIST_PATH}" ]; then
            echo "Service not installed."
            exit 1
        fi
        sudo launchctl bootout system/${SERVICE_LABEL} 2>/dev/null || \
        sudo launchctl unload "${DEST_PLIST_PATH}" 2>/dev/null
        sudo rm "${DEST_PLIST_PATH}"
        if [ -f "${LOG_ROTATION_DEST}" ]; then
            echo "Removing log rotation configuration..."
            sudo rm "${LOG_ROTATION_DEST}"
        fi
        echo "Kanata service unloaded and plist file removed from LaunchDaemons."
        ;;
    start)
        echo "Starting Kanata system service..."
        if [ ! -f "${DEST_PLIST_PATH}" ]; then
            echo "Service not installed. Please run 'sudo ./kanata-service.sh install' first."
            exit 1
        fi
        if is_loaded; then
            echo "Kanata service is already running."
            exit 0
        fi
        if sudo launchctl bootstrap system "${DEST_PLIST_PATH}" 2>/dev/null; then
            echo "Kanata service started."
        elif sudo launchctl load "${DEST_PLIST_PATH}" 2>/dev/null; then
            echo "Kanata service started (using legacy load command)."
        else
            echo "ERROR: Failed to start Kanata service."
            echo "Try running 'sudo launchctl bootstrap system ${DEST_PLIST_PATH}' manually for richer errors."
            exit 1
        fi
        ;;
    stop)
        echo "Stopping Kanata system service..."
        if [ ! -f "${DEST_PLIST_PATH}" ]; then
            echo "Service not installed."
            exit 1
        fi
        if sudo launchctl bootout system/${SERVICE_LABEL} 2>/dev/null; then
            echo "Kanata service stopped."
        elif sudo launchctl unload "${DEST_PLIST_PATH}" 2>/dev/null; then
            echo "Kanata service stopped (using legacy unload command)."
        else
            echo "ERROR: Failed to stop Kanata service."
            exit 1
        fi
        ;;
    restart)
        echo "Restarting Kanata system service..."
        if [ ! -f "${DEST_PLIST_PATH}" ]; then
            echo "Service not installed. Please run 'sudo ./kanata-service.sh install' first."
            exit 1
        fi
        sudo launchctl bootout system/${SERVICE_LABEL} 2>/dev/null || \
        sudo launchctl unload "${DEST_PLIST_PATH}" 2>/dev/null
        sleep 1
        if sudo launchctl bootstrap system "${DEST_PLIST_PATH}" 2>/dev/null; then
            echo "Kanata service restarted."
        elif sudo launchctl load "${DEST_PLIST_PATH}" 2>/dev/null; then
            echo "Kanata service restarted (using legacy load command)."
        else
            echo "ERROR: Failed to restart Kanata service."
            exit 1
        fi
        ;;
    logs)
        echo "Following Kanata logs... (Press Ctrl+C to stop)"
        if [ -f "${LOG_PATH}" ]; then
            sudo tail -f "${LOG_PATH}"
        else
            echo "Log file not found at ${LOG_PATH}. The service may not have run yet."
            exit 1
        fi
        ;;
    status)
        echo "Checking Kanata service status..."
        if [ ! -f "${DEST_PLIST_PATH}" ]; then
            echo "Service not installed."
            exit 0
        fi
        if is_loaded; then
            echo "Kanata service is RUNNING."
        else
            echo "Kanata service is STOPPED."
        fi
        ;;
    *)
        echo "Usage: sudo $0 {install|uninstall|start|stop|restart|status|logs}"
        exit 1
        ;;
esac

exit 0
