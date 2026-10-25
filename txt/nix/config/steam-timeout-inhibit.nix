{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.steam-bpm-screen-saver;

  steam-bpm-screen-saver-script = pkgs.writeShellScriptBin "steam-bpm-screen-saver" ''
    # Environment dependencies: kreadconfig6, kwriteconfig6, qdbus6, pgrep
    export PATH="${lib.makeBinPath [ pkgs.kdePackages.kconfig pkgs.qt6.qttools pkgs.procps pkgs.gnugrep pkgs.coreutils ]}:$PATH"

    # Configuration
    DISPLAY_TIMEOUT_AC=${toString cfg.displayTimeoutAc}
    DISPLAY_TIMEOUT_BATT=${toString cfg.displayTimeoutBatt}
    LOCK_TIMEOUT=${toString cfg.lockTimeout}
    
    : "''${XDG_CACHE_HOME:=$HOME/.cache}"
    ORIG_FILE="$XDG_CACHE_HOME/steam-bpm-screen-saver.orig"
    LOG_TAG="steam-bpm-screen-saver"

    # Helper function to run dbus commands with fallback
    run_dbus() {
      qdbus6 "$@" 2>/dev/null || qdbus "$@" 2>/dev/null
      return 0
    }

    is_steam_bpm_running() {
      # Use pgrep to efficiently find Steam BPM processes
      # Matches: steam, steamerror, etc. with -gamepadui or -tenfoot flags
      pgrep -af 'steam.*-(gamepadui|tenfoot)' >/dev/null 2>&1
      return $?
    }

    # Restore original settings and clean up
    cleanup() {
      if [ -f "$ORIG_FILE" ]; then
        echo "[$LOG_TAG] Restoring original timeout and screen lock settings..." >&2
        # Read from orig file (source in subshell to avoid pollution)
        (
          . "$ORIG_FILE"
          
          if [ -n "$ORIG_DISPLAY_TIMEOUT_AC" ]; then
            kwriteconfig6 --file powerdevilrc --group AC --group Display \
              --key TurnOffDisplayIdleTimeoutSec "$ORIG_DISPLAY_TIMEOUT_AC"
          fi
          if [ -n "$ORIG_DISPLAY_TIMEOUT_BATT" ]; then
            kwriteconfig6 --file powerdevilrc --group Battery --group Display \
              --key TurnOffDisplayIdleTimeoutSec "$ORIG_DISPLAY_TIMEOUT_BATT"
          fi
          if [ -n "$ORIG_LOCK_TIMEOUT" ]; then
            kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout "$ORIG_LOCK_TIMEOUT"
          fi
        )
        
        # Trigger reload
        run_dbus org.freedesktop.PowerManagement /org/kde/Solid/PowerManagement \
          org.kde.Solid.PowerManagement.reparseConfiguration
        
        run_dbus org.freedesktop.ScreenSaver /ScreenSaver configure
        
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
          echo "[$LOG_TAG] Steam Big Picture Mode detected! Adjusting screen timeout and lock settings..." >&2
          is_active=true
          
          # Read current config values
          ORIG_DISPLAY_TIMEOUT_AC=$(kreadconfig6 --file powerdevilrc --group AC --group Display \
            --key TurnOffDisplayIdleTimeoutSec 2>/dev/null)
          ORIG_DISPLAY_TIMEOUT_BATT=$(kreadconfig6 --file powerdevilrc --group Battery --group Display \
            --key TurnOffDisplayIdleTimeoutSec 2>/dev/null)
          ORIG_LOCK_TIMEOUT=$(kreadconfig6 --file kscreenlockerrc --group Daemon --key Timeout 2>/dev/null)
          
          # Use defaults if not set
          : "''${ORIG_DISPLAY_TIMEOUT_AC:=600}"
          : "''${ORIG_DISPLAY_TIMEOUT_BATT:=300}"
          : "''${ORIG_LOCK_TIMEOUT:=5}"
          
          # Save to the cache file
          if ! mkdir -p "$(dirname "$ORIG_FILE")" 2>/dev/null; then
            echo "[$LOG_TAG] Error: Failed to create cache directory" >&2
            sleep 10
            continue
          fi
          
          if ! cat > "$ORIG_FILE" <<EOF; then
            echo "[$LOG_TAG] Error: Failed to write original settings file" >&2
            sleep 10
            continue
          fi
ORIG_DISPLAY_TIMEOUT_AC="$ORIG_DISPLAY_TIMEOUT_AC"
ORIG_DISPLAY_TIMEOUT_BATT="$ORIG_DISPLAY_TIMEOUT_BATT"
ORIG_LOCK_TIMEOUT="$ORIG_LOCK_TIMEOUT"
EOF
          
          # Set new timeouts
          kwriteconfig6 --file powerdevilrc --group AC --group Display \
            --key TurnOffDisplayIdleTimeoutSec "$DISPLAY_TIMEOUT_AC"
          kwriteconfig6 --file powerdevilrc --group Battery --group Display \
            --key TurnOffDisplayIdleTimeoutSec "$DISPLAY_TIMEOUT_BATT"
          kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout "$LOCK_TIMEOUT"
          
          # Apply the configuration
          run_dbus org.freedesktop.PowerManagement /org/kde/Solid/PowerManagement \
            org.kde.Solid.PowerManagement.reparseConfiguration
          
          run_dbus org.freedesktop.ScreenSaver /ScreenSaver configure
        fi
      else
        if [ "$is_active" = "true" ]; then
          echo "[$LOG_TAG] Steam Big Picture Mode is no longer running. Restoring original settings..." >&2
          cleanup
          is_active=false
        fi
      fi
      sleep 10
    done
  '';
in
{
  options.services.steam-bpm-screen-saver = {
    enable = mkEnableOption "Steam Big Picture Mode screen saver timeout inhibitor";
    
    displayTimeoutAc = mkOption {
      type = types.int;
      default = 7200;
      description = "Display idle timeout in seconds when Steam BPM is active (AC power). Default: 2 hours.";
    };
    
    displayTimeoutBatt = mkOption {
      type = types.int;
      default = 7200;
      description = "Display idle timeout in seconds when Steam BPM is active (battery). Default: 2 hours.";
    };
    
    lockTimeout = mkOption {
      type = types.int;
      default = 120;
      description = "Screen lock timeout in minutes when Steam BPM is active. Default: 2 hours.";
    };
  };

  config = mkIf cfg.enable {
    # Install the script system-wide
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
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "steam-bpm-screen-saver";
      };
    };
  };
}
