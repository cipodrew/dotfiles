#!/bin/bash
# sandbox.sh
# eg: sandbox.sh ai-agent
set -euo pipefail

VERBOSE=${SANDBOX_VERBOSE:-0}

log() {
    if [[ $VERBOSE -eq 1 ]]; then
        echo "[sandbox] $*" >&2
    fi
}

add_config_bindings() {
    local configs=(
        "$HOME/.gitconfig"
        "$HOME/.npmrc"
        "$HOME/.cargo/config.toml"
        "$HOME/.config/git"
        "$HOME/.pip/pip.conf"
    )
    
    echo "Checking config files..."
    for config in "${configs[@]}"; do
        if [[ -e "$config" ]]; then
            echo "  ✓ Binding config: $config"
            BWRAP_CMD+=(--ro-bind-try "$config" "$config")
        else
            log "  ✗ Not found: $config"
        fi
    done
}

add_clipboard_bindings() {
    echo "Checking clipboard support..."
    
    # Create tmpfs for /tmp first
    BWRAP_CMD+=(--tmpfs /tmp)
    
    # X11 clipboard support
    if [[ -n "${DISPLAY:-}" ]]; then
        echo "  ✓ Setting DISPLAY: $DISPLAY"
        BWRAP_CMD+=(--setenv DISPLAY "$DISPLAY")
        
        # Bind X11 socket directory on top of tmpfs
        local x11_dir="/tmp/.X11-unix"
        if [[ -d "$x11_dir" ]]; then
            echo "  ✓ Binding X11 socket directory (read-write)"
            BWRAP_CMD+=(--bind "$x11_dir" "$x11_dir")
        fi
        
        # X authority file
        if [[ -n "${XAUTHORITY:-}" && -f "$XAUTHORITY" ]]; then
            echo "  ✓ Binding XAUTHORITY: $XAUTHORITY"
            BWRAP_CMD+=(--ro-bind "$XAUTHORITY" "$XAUTHORITY")
            BWRAP_CMD+=(--setenv XAUTHORITY "$XAUTHORITY")
        elif [[ -f "$HOME/.Xauthority" ]]; then
            echo "  ✓ Binding .Xauthority"
            BWRAP_CMD+=(--ro-bind "$HOME/.Xauthority" "$HOME/.Xauthority")
        fi
    fi
    
    # Wayland clipboard support
    if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        echo "  ✓ Setting WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
        BWRAP_CMD+=(--setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY")
        
        local wayland_socket="${XDG_RUNTIME_DIR:-/run/user/$UID}/$WAYLAND_DISPLAY"
        if [[ -S "$wayland_socket" ]]; then
            echo "  ✓ Binding Wayland socket"
            BWRAP_CMD+=(--bind "$wayland_socket" "$wayland_socket")
        fi
    fi
    
    # XDG_RUNTIME_DIR for both X11 and Wayland
    local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$UID}"
    if [[ -d "$runtime_dir" ]]; then
        echo "  ✓ Binding XDG_RUNTIME_DIR: $runtime_dir"
        BWRAP_CMD+=(--bind "$runtime_dir" "$runtime_dir")
        BWRAP_CMD+=(--setenv XDG_RUNTIME_DIR "$runtime_dir")
    fi
    
    # Session bus for X11/dbus communication
    if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
        echo "  ✓ Setting DBUS_SESSION_BUS_ADDRESS"
        BWRAP_CMD+=(--setenv DBUS_SESSION_BUS_ADDRESS "$DBUS_SESSION_BUS_ADDRESS")
    fi
}

add_path_bindings() {
    local IFS=':'
    local path_entries=($PATH)
    declare -A seen_dirs
    
    echo "Checking PATH directories..."
    for dir in "${path_entries[@]}"; do
        dir="${dir/#\~/$HOME}"
        [[ -z "$dir" ]] && continue
        
        if [[ -d "$dir" ]]; then
            dir=$(realpath "$dir" 2>/dev/null || echo "$dir")
            
            if [[ -z "${seen_dirs[$dir]:-}" && \
                  "$dir" != "$PWD"* && \
                  "$dir" != "/usr/"* && \
                  "$dir" != "/bin" && \
                  "$dir" != "/sbin" && \
                  "$dir" != "/lib"* && \
                  "$dir" != "/mnt/c/"* && \
                  "$dir" != "/opt/"* ]]; then
                echo "  ✓ Binding PATH directory: $dir"
                BWRAP_CMD+=(--ro-bind-try "$dir" "$dir")
                seen_dirs[$dir]=1
            else
                log "  - Skipping (system/windows/already bound): $dir"
            fi
        else
            log "  ✗ Not a directory: $dir"
        fi
    done
}

# add_runtime_bindings() {
#     echo "Checking runtime directories..."
#
#     # fnm runtime shims (changes per shell session)
#     if [[ -d "/run/user/$UID/fnm_multishells" ]]; then
#         echo "  ✓ Binding fnm runtime shims"
#         BWRAP_CMD+=(--ro-bind-try "/run/user/$UID/fnm_multishells" "/run/user/$UID/fnm_multishells")
#     fi
#
#     # You can add other runtime directories here
#     # nvm, pyenv, rbenv, etc. if they use similar patterns
# }

add_fnm_bindings() {
    # Bind fnm directories
    if [[ -d "$HOME/.local/share/fnm" ]]; then
        echo "  ✓ Binding fnm data directory"
        BWRAP_CMD+=(--ro-bind-try "$HOME/.local/share/fnm" "$HOME/.local/share/fnm")
    fi
    # Bind fnm runtime shims
    if [[ -d "/run/user/$UID/fnm_multishells" ]]; then
        echo "  ✓ Binding fnm runtime shims"
        BWRAP_CMD+=(--ro-bind-try "/run/user/$UID/fnm_multishells" "/run/user/$UID/fnm_multishells")
    fi

    if [[ -d "$HOME/.local/share/pnpm" ]]; then
        echo "  ✓ Binding pnpm cache directory"
        BWRAP_CMD+=(--ro-bind-try "$HOME/.local/share/pnpm" "$HOME/.local/share/pnpm")
    fi
}

add_bun_bindings() {
    echo "Checking Bun directories..."
    
    # Bun installation directory
    if [[ -d "$HOME/.bun" ]]; then
        echo "  ✓ Binding Bun installation directory"
        BWRAP_CMD+=(--ro-bind-try "$HOME/.bun" "$HOME/.bun")
    fi
    
    # Bun cache directory
    if [[ -d "$HOME/.cache/bun" ]]; then
        echo "  ✓ Binding Bun cache (read-write)"
        BWRAP_CMD+=(--bind "$HOME/.cache/bun" "$HOME/.cache/bun")
    fi
    
    # Pass BUN_INSTALL if set
    if [[ -n "${BUN_INSTALL:-}" ]]; then
        BWRAP_CMD+=(--setenv BUN_INSTALL "$BUN_INSTALL")
        if [[ -d "$BUN_INSTALL" ]]; then
            echo "  ✓ Binding custom BUN_INSTALL: $BUN_INSTALL"
            BWRAP_CMD+=(--ro-bind-try "$BUN_INSTALL" "$BUN_INSTALL")
        fi
    fi
}

add_uv_bindings() {
    # Bind uv directories
    if [[ -d "$HOME/.local/share/uv" ]]; then
        echo "  ✓ Binding uv directory"
        BWRAP_CMD+=(--ro-bind-try "$HOME/.local/share/uv" "$HOME/.local/share/uv")
    fi
}

add_go_bindings() {
    echo "Checking Go directories..."
    
    # Honor GOMODCACHE environment variable, fallback to default
    local gomodcache="${GOMODCACHE:-$HOME/go/pkg/mod}"
    if [[ -d "$gomodcache" ]]; then
        echo "  ✓ Binding Go module cache (read-write): $gomodcache"
        BWRAP_CMD+=(--bind "$gomodcache" "$gomodcache")
    fi
    
    # Honor GOCACHE environment variable, fallback to default
    local gocache="${GOCACHE:-$HOME/.cache/go-build}"
    if [[ -d "$gocache" ]]; then
        echo "  ✓ Binding Go build cache (read-write): $gocache"
        BWRAP_CMD+=(--bind "$gocache" "$gocache")
    fi
    
    # General Go cache directory (contains gopls and other tools)
    if [[ -d "$HOME/.cache/go" ]]; then
        echo "  ✓ Binding Go cache directory (read-write)"
        BWRAP_CMD+=(--bind "$HOME/.cache/go" "$HOME/.cache/go")
    fi
    
    # gopls (Go language server) cache
    if [[ -d "$HOME/.cache/gopls" ]]; then
        echo "  ✓ Binding gopls cache (read-write)"
        BWRAP_CMD+=(--bind "$HOME/.cache/gopls" "$HOME/.cache/gopls")
    fi
    
    # Honor GOPATH environment variable, fallback to default
    local gopath="${GOPATH:-$HOME/go}"
    
    # GOPATH/bin - where installed binaries live
    if [[ -d "$gopath/bin" ]]; then
        echo "  ✓ Binding Go bin directory: $gopath/bin"
        BWRAP_CMD+=(--ro-bind-try "$gopath/bin" "$gopath/bin")
    fi
    
    # Pass Go environment variables to sandbox
    if [[ -n "${GOMODCACHE:-}" ]]; then
        BWRAP_CMD+=(--setenv GOMODCACHE "$GOMODCACHE")
    fi
    if [[ -n "${GOCACHE:-}" ]]; then
        BWRAP_CMD+=(--setenv GOCACHE "$GOCACHE")
    fi
    if [[ -n "${GOPATH:-}" ]]; then
        BWRAP_CMD+=(--setenv GOPATH "$GOPATH")
    fi
}

add_cache_bindings() {
    echo "Checking cache directories..."
    
    # Bind the entire .cache directory (covers go-build, gopls, pip, rust, etc.)
    if [[ -d "$HOME/.cache" ]]; then
        echo "  ✓ Binding .cache directory (read-write)"
        BWRAP_CMD+=(--bind "$HOME/.cache" "$HOME/.cache")
    fi
}

print_help(){
    cat <<EOF
    usage: $0 <command_to_sandbox>
EOF
}

if (( $# < 1 )); then
    echo  "ERROR: not enough arguments"
    print_help
    exit 1
fi

if [[ $1 == "--help" || $1 == "-h" ]]; then
    print_help
    exit 1
fi

if ! command -v bwrap >/dev/null 2>&1; then
  echo "ERROR: you need bubblewrap installed"
  echo "eg: sudo apt install bubblewrap"
  exit 1
fi

echo "Starting sandbox for: $*"
echo "Current directory: $PWD"
echo >&2

# Build the command as an array
BWRAP_CMD=(
    bwrap
    --unshare-all
    --share-net
    --ro-bind /usr /usr
    --ro-bind /lib /lib
    --ro-bind /lib64 /lib64
    --ro-bind /bin /bin
    --ro-bind /sbin /sbin
    --ro-bind-try /opt /opt
    --ro-bind /etc/resolv.conf /etc/resolv.conf
    --ro-bind /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
)

add_vibe_rw() {
    # Bind mistral vibe directories
    if [[ -d "$HOME/.vibe" ]]; then
        echo "  ✓ Binding .vibe in readwrite"
        BWRAP_CMD+=(--bind "$HOME/.vibe" "$HOME/.vibe")
    fi
}

add_opencode_rw() {
    # Bind mistral vibe directories
    if [[ -d "$HOME/.config/opencode" ]]; then
        echo "  ✓ Binding $HOME/.config/opencode in readwrite"
        BWRAP_CMD+=(--bind "$HOME/.config/opencode" "$HOME/.config/opencode")
    fi
}

# Add all bindings
add_clipboard_bindings
add_path_bindings
add_fnm_bindings
add_bun_bindings 
add_uv_bindings
add_cache_bindings
add_go_bindings

if [[ $1 == "vibe" ]]; then
    add_vibe_rw
fi
if [[ $1 == "opencode" ]]; then
    add_opencode_rw
fi
add_config_bindings

# Add remaining arguments
BWRAP_CMD+=(
    --bind "$PWD" "$PWD"
    --chdir "$PWD"
    # --tmpfs /tmp
    --proc /proc
    --dev /dev
    --setenv PATH "$PATH"
    --setenv HOME "$HOME"
)

# Add the command to execute
BWRAP_CMD+=("$@")

# Print the full command if verbose
if [[ $VERBOSE -eq 1 ]]; then
    echo "[sandbox] FULL COMMAND:" >&2
    printf '[sandbox]   %s \\\n' "${BWRAP_CMD[@]}" >&2
    echo >&2
fi

echo "------------DONE---------------"

# Execute
exec "${BWRAP_CMD[@]}"

