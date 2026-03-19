#!/usr/bin/env bash
# ---
# Tool: JDTLS (Java Development Tools Language Server)
# Source: https://github.com/eclipse-jdtls/eclipse.jdt.ls
# Purpose: Language server for Java development
# Updated: 2026-03-19
# ---

set -euo pipefail

# =============================================================================
# Configuration with fallbacks
# =============================================================================

JDTLS_HOME="${JDTLS_HOME:-$HOME/.local/share/opencode/bin/jdtls}"
JDTLS_LOMBOK_JAR="${JDTLS_LOMBOK_JAR:-$HOME/.lombok/lombok.jar}"

# Cache directory for platform config (XDG_CACHE_HOME with fallback)
JDTLS_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/jdtls"

# =============================================================================
# OS/Arch Detection
# =============================================================================

detect_platform_config() {
  local os
  local arch

  case "$(uname -s)" in
    Darwin)
      os="mac"
      ;;
    Linux)
      os="linux"
      ;;
    *)
      echo "ERROR: Unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac

  case "$(uname -m)" in
    x86_64)
      arch=""
      ;;
    arm64|aarch64)
      arch="_arm"
      ;;
    *)
      echo "ERROR: Unsupported architecture: $(uname -m)" >&2
      exit 1
      ;;
  esac

  echo "config_${os}${arch}"
}

# =============================================================================
# Validation Functions
# =============================================================================

validate_jdtls() {
  if [[ ! -d "$JDTLS_HOME" ]]; then
    echo "ERROR: JDTLS_HOME not found: $JDTLS_HOME" >&2
    echo "Please install JDTLS or set JDTLS_HOME environment variable" >&2
    exit 1
  fi
  echo "✓ JDTLS_HOME: $JDTLS_HOME" >&2
}

find_launcher_jar() {
  local launcher_pattern="$JDTLS_HOME/plugins/org.eclipse.equinox.launcher_*.jar"
  local launcher

  # Use nullglob to get matching files
  shopt -s nullglob
  local launchers=($launcher_pattern)
  shopt -u nullglob

  if [[ ${#launchers[@]} -eq 0 ]]; then
    echo "ERROR: Launcher jar not found: $launcher_pattern" >&2
    echo "Please ensure JDTLS is properly installed" >&2
    exit 1
  fi

  if [[ ${#launchers[@]} -gt 1 ]]; then
    echo "ERROR: Multiple launcher jars found under $JDTLS_HOME/plugins" >&2
    printf ' - %s\n' "${launchers[@]}" >&2
    echo "Please clean up old JDTLS launcher jars so only one remains" >&2
    exit 1
  fi

  # Take the first match (should be only one)
  launcher="${launchers[0]}"
  echo "$launcher"
}

find_platform_config() {
  local platform_config="$JDTLS_HOME/$1"

  if [[ ! -d "$platform_config" ]]; then
    echo "ERROR: Platform config not found: $platform_config" >&2
    echo "Please ensure JDTLS platform config is installed" >&2
    exit 1
  fi

  # Return full path for fail-fast validation
  echo "$platform_config"
}

validate_java() {
  local java_cmd="$1"
  local java_version

  if ! command -v "$java_cmd" >/dev/null 2>&1; then
    echo "ERROR: Java not found: $java_cmd" >&2
    exit 1
  fi

  java_version=$("$java_cmd" -version 2>&1 | head -1 | awk -F '"' '{print $2}')

  # Extract major version (e.g., "21.0.1" -> 21)
  local major_version
  major_version=$(echo "$java_version" | awk -F '.' '{print $1}')

  if [[ -z "$major_version" || "$major_version" -lt 21 ]]; then
    echo "ERROR: Java major version must be >= 21, found: $major_version ($java_version)" >&2
    exit 1
  fi

  # Print validation to stderr, return only path via stdout
  echo "✓ Java: $java_version" >&2
  echo "$java_cmd"
}

validate_lombok() {
  if [[ ! -f "$JDTLS_LOMBOK_JAR" ]]; then
    echo "ERROR: Lombok jar not found: $JDTLS_LOMBOK_JAR" >&2
    echo "Please install Lombok or set JDTLS_LOMBOK_JAR environment variable" >&2
    exit 1
  fi
  echo "✓ Lombok: $JDTLS_LOMBOK_JAR" >&2
}

# =============================================================================
# Workspace Generation
# =============================================================================

generate_workspace() {
  # Generate unique workspace based on current directory hash
  # Supports both Linux (md5sum) and macOS (md5 -q)
  local pwd_hash
  if command -v md5sum >/dev/null 2>&1; then
    pwd_hash=$(echo "$PWD" | md5sum | awk '{print $1}')
  elif command -v md5 >/dev/null 2>&1; then
    pwd_hash=$(echo "$PWD" | md5 -q)
  else
    echo "ERROR: No md5 utility found (md5sum or md5)" >&2
    exit 1
  fi
  echo "$JDTLS_CACHE_DIR/workspace-$pwd_hash"
}

# =============================================================================
# Platform Config Caching
# =============================================================================

copy_platform_config_to_cache() {
  local src_config="$1"
  local cache_config="$JDTLS_CACHE_DIR/config"

  # Create cache directory
  mkdir -p "$JDTLS_CACHE_DIR"
  mkdir -p "$cache_config"

  # Remove old config to avoid stale files
  rm -rf "$cache_config"/*

  # Copy platform config to cache
  cp -r "$src_config/"* "$cache_config/"

  # Create marker file in writable config directory (with launcher jar path and mtime)
  local launcher_mtime
  local src_config_ini="$src_config/config.ini"
  local config_mtime
  launcher_mtime=$(stat -f %m "$LAUNCHER_JAR" 2>/dev/null || stat -c %Y "$LAUNCHER_JAR" 2>/dev/null)
  config_mtime=$(stat -f %m "$src_config_ini" 2>/dev/null || stat -c %Y "$src_config_ini" 2>/dev/null)

  printf '%s\n%s\n%s\n%s\n' \
    "$LAUNCHER_JAR" \
    "$launcher_mtime" \
    "$src_config_ini" \
    "$config_mtime" > "$cache_config/.opencode-jdtls-cache-marker"

  echo "$cache_config"
}

should_refresh_cache() {
  local cache_config="$JDTLS_CACHE_DIR/config"
  local cache_marker="$cache_config/.opencode-jdtls-cache-marker"
  local src_config="$1"
  local src_config_ini="$src_config/config.ini"

  # Check if marker exists
  if [[ ! -f "$cache_marker" ]]; then
    return 0  # No marker, need to copy
  fi

  # Check if config.ini exists (may have been deleted)
  if [[ ! -f "$cache_config/config.ini" ]]; then
    return 0  # Missing config.ini, need to refresh
  fi

  local cached_info
  cached_info=$(cat "$cache_marker")

  local launcher_mtime
  local config_mtime
  launcher_mtime=$(stat -f %m "$LAUNCHER_JAR" 2>/dev/null || stat -c %Y "$LAUNCHER_JAR" 2>/dev/null)
  config_mtime=$(stat -f %m "$src_config_ini" 2>/dev/null || stat -c %Y "$src_config_ini" 2>/dev/null)

  local expected_info
  expected_info=$(printf '%s\n%s\n%s\n%s\n' \
    "$LAUNCHER_JAR" \
    "$launcher_mtime" \
    "$src_config_ini" \
    "$config_mtime")

  if [[ "$cached_info" != "$expected_info" ]]; then
    return 0  # Launcher changed, need to refresh
  fi

  return 1  # No refresh needed
}

# =============================================================================
# Main
# =============================================================================

main() {
  echo "=== JDTLS Launcher ===" >&2
  echo "" >&2

  # Validate JDTLS installation
  validate_jdtls

  # Find launcher jar
  LAUNCHER_JAR=$(find_launcher_jar)
  echo "✓ Launcher: $LAUNCHER_JAR" >&2

  # Detect and find platform config (fail-fast validation)
  PLATFORM_CONFIG=$(detect_platform_config)
  # find_platform_config validates and returns full path
  config_path=$(find_platform_config "$PLATFORM_CONFIG")
  echo "✓ Platform: $PLATFORM_CONFIG ($config_path)" >&2

  # Check if platform config is writable (can modify)
  if [[ -w "$config_path" ]]; then
    echo "✓ Config: using $config_path (writable)" >&2
    FINAL_CONFIG="$config_path"
  else
    # Need to copy to cache
    if should_refresh_cache "$config_path"; then
      echo "⚡ Copying platform config to cache..." >&2
      FINAL_CONFIG=$(copy_platform_config_to_cache "$config_path")
      echo "✓ Config: using $FINAL_CONFIG (cached)" >&2
    else
      echo "✓ Config: using cached config" >&2
      FINAL_CONFIG="$JDTLS_CACHE_DIR/config"
    fi
  fi

  # Validate Java
  local java_cmd
  if [[ -n "${JDTLS_JAVA_HOME:-}" ]]; then
    java_cmd="$JDTLS_JAVA_HOME/bin/java"
  elif [[ -n "${JAVA_HOME:-}" ]]; then
    java_cmd="$JAVA_HOME/bin/java"
  else
    java_cmd="java"
  fi
  JAVA_PATH=$(validate_java "$java_cmd")

  # Validate Lombok
  validate_lombok

  # Generate workspace
  local workspace
  workspace=$(generate_workspace)
  mkdir -p "$workspace"
  echo "✓ Workspace: $workspace" >&2

  echo "" >&2
  echo "=== Starting JDTLS ===" >&2

  # Build JVM args
  local jvm_args=(
    "-javaagent:$JDTLS_LOMBOK_JAR"
    "-XX:+UseParallelGC"
    "-XX:+TieredCompilation"
    "-XX:TieredStopAtLevel=1"
    "-Xss4m"
    "-Xmx2g"
  )

  # Execute JDTLS
  exec "$JAVA_PATH" "${jvm_args[@]}" \
    -jar "$LAUNCHER_JAR" \
    -configuration "$FINAL_CONFIG" \
    -data "$workspace"
}

main "$@"
