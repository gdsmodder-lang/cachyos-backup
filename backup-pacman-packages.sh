#!/bin/bash
#
# backup-pacman-packages.sh
#
# Gera uma lista completa dos pacotes explicitamente instalados no CachyOS,
# excluindo tudo relacionado a Hyprland, caelestia-shell e noctalia.
#
# Uso:
#   chmod +x backup-pacman-packages.sh
#   ./backup-pacman-packages.sh
#

set -euo pipefail

# --- Configuração -----------------------------------------------------

# Pasta onde os arquivos de backup serão salvos
BACKUP_DIR="${HOME}/pkg-backup-$(date +%Y%m%d-%H%M)"

# Padrões (regex, case-insensitive) usados para excluir pacotes.
# Adicione aqui qualquer pacote que você saiba pertencer ao ecossistema
# do Hyprland / caelestia-shell / noctalia mas que não contém esses
# nomes literalmente (ex.: quickshell, matugen, app2unit, etc).
EXCLUDE_PATTERNS=(
    "hypr"          # hyprland, hyprpaper, hypridle, hyprlock, hyprcursor,
                     # hyprwayland-scanner, xdg-desktop-portal-hyprland...
    "caelestia"      # caelestia-shell e pacotes derivados
    "noctalia"       # noctalia-shell e pacotes derivados
    "quickshell"     # engine usada tanto por caelestia-shell quanto noctalia
)

mkdir -p "$BACKUP_DIR"

# Monta a regex final unindo os padrões com "|"
EXCLUDE_REGEX=$(IFS='|'; echo "${EXCLUDE_PATTERNS[*]}")

# --- Coleta dos pacotes -------------------------------------------------

# Pacotes nativos explicitamente instalados (repositórios oficiais)
pacman -Qqen > "$BACKUP_DIR/native-explicit-raw.txt"

# Pacotes estrangeiros explicitamente instalados (AUR ou instalados manualmente)
pacman -Qqem > "$BACKUP_DIR/foreign-explicit-raw.txt"

# --- Filtragem -----------------------------------------------------------

grep -viE "$EXCLUDE_REGEX" "$BACKUP_DIR/native-explicit-raw.txt" \
    > "$BACKUP_DIR/native-explicit-filtered.txt" || true

grep -viE "$EXCLUDE_REGEX" "$BACKUP_DIR/foreign-explicit-raw.txt" \
    > "$BACKUP_DIR/foreign-explicit-filtered.txt" || true

cat "$BACKUP_DIR/native-explicit-filtered.txt" \
    "$BACKUP_DIR/foreign-explicit-filtered.txt" \
    | sort > "$BACKUP_DIR/pacotes-completo-filtrado.txt"

# --- Pacotes removidos (para conferência) --------------------------------

cat "$BACKUP_DIR/native-explicit-raw.txt" "$BACKUP_DIR/foreign-explicit-raw.txt" \
    | sort > "$BACKUP_DIR/todos-explicitos.txt"

comm -23 "$BACKUP_DIR/todos-explicitos.txt" "$BACKUP_DIR/pacotes-completo-filtrado.txt" \
    > "$BACKUP_DIR/pacotes-excluidos.txt"

# --- Resumo ---------------------------------------------------------------

echo "Backup salvo em: $BACKUP_DIR"
echo ""
echo "Total de pacotes explicitos:  $(wc -l < "$BACKUP_DIR/todos-explicitos.txt")"
echo "Pacotes no backup filtrado:   $(wc -l < "$BACKUP_DIR/pacotes-completo-filtrado.txt")"
echo "Pacotes excluidos:            $(wc -l < "$BACKUP_DIR/pacotes-excluidos.txt")"
echo ""
echo "Confira '$BACKUP_DIR/pacotes-excluidos.txt' para garantir que nada"
echo "importante foi removido por engano."
