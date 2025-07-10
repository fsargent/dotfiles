# Kanata as a macOS System Service

This document explains how to run Kanata as a system-wide background service on macOS using `launchd`. This setup runs Kanata as the `root` user, ensuring it works correctly even at the login screen.

A management script, `kanata-service.sh`, is provided to simplify the process.

**IMPORTANT**: All commands for the management script must be run with `sudo`.

## Features

*   **System-Wide Service**: Runs as `root` via `launchd`.
*   **Logging**: Stores logs in `/var/log/kanata.log`.
*   **Log Rotation**: Automatically rotates logs when they reach 1MB, keeping 5 archived logs. This is handled by `newsyslog`.

## Quick Start with `kanata-service.sh`

1.  **Make the script executable:**
    You only need to do this once.
    ```bash
    chmod +x kanata-service.sh
    ```

2.  **Install and start the service:**
    This command will copy the `com.user.kanata.plist` file to `/Library/LaunchDaemons`, install the log rotation configuration, and load the service.
    ```bash
    sudo ./kanata-service.sh install
    ```

Kanata is now running as a system-wide background service.

## Managing the Service with the Script

The `kanata-service.sh` script provides several commands to manage the service. Remember to use `sudo` for all of them.

*   **Install the service:**
    ```bash
    sudo ./kanata-service.sh install
    ```

*   **Uninstall the service:**
    This stops the service and removes the `.plist` and log rotation configuration files.
    ```bash
    sudo ./kanata-service.sh uninstall
    ```

*   **Start the service:**
    ```bash
    sudo ./kanata-service.sh start
    ```

*   **Stop the service:**
    ```bash
    sudo ./kanata-service.sh stop
    ```

*   **Restart the service:**
    ```bash
    sudo ./kanata-service.sh restart
    ```

*   **Check the service status:**
    ```bash
    sudo ./kanata-service.sh status
    ```

*   **Follow the logs:**
    ```bash
    sudo ./kanata-service.sh logs
    ```

## Manual Setup (without the script)

If you prefer to set up the service manually, follow these steps:

1.  **Place the Service File**:
    Copy the `com.user.kanata.plist` file to `/Library/LaunchDaemons/`.
    ```bash
    sudo cp com.user.kanata.plist /Library/LaunchDaemons/
    ```

2.  **Place the Log Rotation File**:
    Copy the `kanata.conf` file to `/etc/newsyslog.d/`.
    ```bash
    sudo cp kanata.conf /etc/newsyslog.d/
    ```

3.  **Load the Service**:
    Use `launchctl` with `sudo` to load the service.
    ```bash
    sudo launchctl load /Library/LaunchDaemons/com.user.kanata.plist
