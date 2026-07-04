{ pkgs, lib, ... }:

let
  steam-bpm-screen-saver-script = pkgs.writeShellScriptBin "steam-bpm-screen-saver" ''
    # Environment dependencies: kreadconfig6, kwriteconfig6, qdbus6, pgrep
    export PATH="${lib.makeBinPath [ pkgs.kdePackages.kconfig pkgs.qt6.qttools pkgs.procps pkgs.gnugrep pkgs.coreutils ]}:$PATH"

    ORIG_FILE="$XDG_CACHE_HOME/steam-bpm-screen-saver.orig"
    : "''${XDG_CACHE_HOME:=$HOME/.cache}"
    ORIG_FILE="$XDG_CACHE_HOME/steam-bpm-screen-saver.orig"

    is_steam_bpm_running() {
      # Check all running processes' cmdlines
      for cmdfile in /proc/[0-9]*/cmdline; do
        if [ -f "$cmdfile" ]; then
          # cmdline is null-separated, replace nulls with spaces
          cmdline=$(tr '\0' ' ' < "$cmdfile" 2>/dev/null)
          # Check if it contains "steam" (case-insensitive) and either "-gamepadui" or "-tenfoot"
          if echo "$cmdline" | grep -iq "steam" && echo "$cmdline" | grep -E -q -- "-(gamepadui|tenfoot)"; then
            return 0
          fi
        fi
      done
      return 1
    }

    # Clean up function to restore settings if the script receives a SIGTERM/SIGINT
    cleanup() {
      if [ -f "$ORIG_FILE" ]; then
        echo "Restoring original timeout and screen lock settings..."
        # Read from orig file
        . "$ORIG_FILE"
        
        if [ -n "$ORIG_DISPLAY_TIMEOUT_AC" ]; then
          kwriteconfig6 --file powerdevilrc --group AC --group Display --key TurnOffDisplayIdleTimeoutSec "$ORIG_DISPLAY_TIMEOUT_AC"
        fi
        if [ -n "$ORIG_DISPLAY_TIMEOUT_BATT" ]; then
          kwriteconfig6 --file powerdevilrc --group Battery --group Display --key TurnOffDisplayIdleTimeoutSec "$ORIG_DISPLAY_TIMEOUT_BATT"
        fi
        if [ -n "$ORIG_LOCK_TIMEOUT" ]; then
          kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout "$ORIG_LOCK_TIMEOUT"
        fi
        
        # Trigger reload
        qdbus6 org.freedesktop.PowerManagement /org/kde/Solid/PowerManagement org.kde.Solid.PowerManagement.reparseConfiguration 2>/dev/null || \
        qdbus org.freedesktop.PowerManagement /org/kde/Solid/PowerManagement org.kde.Solid.PowerManagement.reparseConfiguration 2>/dev/null
        
        qdbus6 org.freedesktop.ScreenSaver /ScreenSaver configure 2>/dev/null || \
        qdbus org.freedesktop.ScreenSaver /ScreenSaver configure 2>/dev/null
        
        rm -f "$ORIG_FILE"
      fi
      exit 0
    }

    trap cleanup SIGINT SIGTERM

    is_active=false

    # On startup, check if we need to clean up/restore from a previous crash/unclean exit
    if [ -f "$ORIG_FILE" ]; then
      if ! is_steam_bpm_running; then
        cleanup
      else
        is_active=true
      fi
    fi

    while true; do
      if is_steam_bpm_running; then
        if [ "$is_active" = "false" ]; then
          echo "Steam Big Picture Mode detected! Adjusting screen timeout and lock settings to higher values..."
          is_active=true
          
          # Read current config values
          ORIG_DISPLAY_TIMEOUT_AC=$(kreadconfig6 --file powerdevilrc --group AC --group Display --key TurnOffDisplayIdleTimeoutSec 2>/dev/null)
          ORIG_DISPLAY_TIMEOUT_BATT=$(kreadconfig6 --file powerdevilrc --group Battery --group Display --key TurnOffDisplayIdleTimeoutSec 2>/dev/null)
          ORIG_LOCK_TIMEOUT=$(kreadconfig6 --file kscreenlockerrc --group Daemon --key Timeout 2>/dev/null)
          
          # Use defaults if not set
          : "''${ORIG_DISPLAY_TIMEOUT_AC:=600}"
          : "''${ORIG_DISPLAY_TIMEOUT_BATT:=300}"
          : "''${ORIG_LOCK_TIMEOUT:=5}"
          
          # Save to the cache file
          mkdir -p "$(dirname "$ORIG_FILE")"
          cat <<EOF > "$ORIG_FILE"
ORIG_DISPLAY_TIMEOUT_AC="$ORIG_DISPLAY_TIMEOUT_AC"
ORIG_DISPLAY_TIMEOUT_BATT="$ORIG_DISPLAY_TIMEOUT_BATT"
ORIG_LOCK_TIMEOUT="$ORIG_LOCK_TIMEOUT"
EOF
          
          # Set new timeouts:
          # Display timeout: 7200 seconds (2 hours)
          # Lock timeout: 120 minutes (2 hours)
          kwriteconfig6 --file powerdevilrc --group AC --group Display --key TurnOffDisplayIdleTimeoutSec 7200
          kwriteconfig6 --file powerdevilrc --group Battery --group Display --key TurnOffDisplayIdleTimeoutSec 7200
          kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout 120
          
          # Apply the configuration
          qdbus6 org.freedesktop.PowerManagement /org/kde/Solid/PowerManagement org.kde.Solid.PowerManagement.reparseConfiguration 2>/dev/null || \
          qdbus org.freedesktop.PowerManagement /org/kde/Solid/PowerManagement org.kde.Solid.PowerManagement.reparseConfiguration 2>/dev/null
          
          qdbus6 org.freedesktop.ScreenSaver /ScreenSaver configure 2>/dev/null || \
          qdbus org.freedesktop.ScreenSaver /ScreenSaver configure 2>/dev/null
        fi
      else
        if [ "$is_active" = "true" ]; then
          echo "Steam Big Picture Mode is no longer running. Restoring original settings..."
          cleanup
          is_active=false
        fi
      fi
      sleep 10
    done
  '';
in
{
  # Install the script system-wide (optional, but good for testing or troubleshooting)
  environment.systemPackages = [ steam-bpm-screen-saver-script ];

  # Systemd user service to run the monitoring daemon
  systemd.user.services.steam-bpm-screen-saver = {
    description = "Steam Big Picture Mode Screen Saver / Timeout Adjuster";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    
    serviceConfig = {
      ExecStart = "${steam-bpm-screen-saver-script}/bin/steam-bpm-screen-saver";
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
