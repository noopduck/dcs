#!/bin/bash
set -e

# === CONFIG ===
SAVED_GAMES="$HOME/.local/share/Steam/steamapps/compatdata/3809653855/pfx/drive_c/users/steamuser/Saved Games/DCS"
DCS_INSTALL="$HOME/.local/share/Steam/steamapps/compatdata/2954704094/pfx/drive_c/Program Files/Eagle Dynamics/DCS World"
RESOLUTION_WIDTH=2560
RESOLUTION_HEIGHT=1440

echo "==> Installing pip3..."
sudo dnf install -y python3-pip

echo "==> Installing protonup..."
pip install protonup

echo "==> Installing GE-Proton..."
protonup

echo "==> Creating options.lua..."
mkdir -p "$SAVED_GAMES/Config"
cat > "$SAVED_GAMES/Config/options.lua" << EOF
options = 
{
    ["graphics"] = 
    {
        ["Launcher"] = false,
        ["visibRange"] = "High",
        ["shaderErrors"] = false,
        ["multiMonitorSetup"] = "1monitor",
        ["fullscreen"] = false,
        ["width"] = $RESOLUTION_WIDTH,
        ["height"] = $RESOLUTION_HEIGHT,
        ["aspectRatio"] = $(echo "scale=13; $RESOLUTION_WIDTH/$RESOLUTION_HEIGHT" | bc),
    },
    ["misc"] = 
    {
        ["autologin"] = false,
    },
}
EOF

echo "==> Stubbing broken particle shaders..."
SHADERS="$DCS_INSTALL/Bazar/shaders/ParticleSystem2"
cp "$SHADERS/groundPuff.fx" "$SHADERS/groundPuff.fx.bak" 2>/dev/null || true
cp "$SHADERS/groundPuffComp.fx" "$SHADERS/groundPuffComp.fx.bak" 2>/dev/null || true
echo "" > "$SHADERS/groundPuff.fx"
echo "" > "$SHADERS/groundPuffComp.fx"

echo "==> Patching TableUtils.lua..."
TABLEUTILS="$DCS_INSTALL/Scripts/TableUtils.lua"
cp "$TABLEUTILS" "$TABLEUTILS.bak" 2>/dev/null || true
sed -i 's/assert(target ~= src)/if src == nil then return target end/' "$TABLEUTILS"

echo ""
echo "==> All done!"
echo "    Set GE-Proton as compatibility tool for DCS in Steam."
echo "    Add '--no-launcher' to DCS launch options in Steam."
