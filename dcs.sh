#!/bin/bash
set -e

COMPATDATA="$HOME/.local/share/Steam/steamapps/compatdata"

echo "==> Detecting DCS prefixes..."
INSTALL_PREFIX=$(find "$COMPATDATA" -path "*/drive_c/Program Files/Eagle Dynamics/DCS World/bin-mt/DCS.exe" 2>/dev/null | head -1 | sed 's|/pfx/drive_c/.*||')
SAVED_PREFIX=$(find "$COMPATDATA" -path "*/drive_c/users/steamuser/Saved Games/DCS/Logs/dcs.log" 2>/dev/null | head -1 | sed 's|/pfx/drive_c/.*||')

if [ -z "$INSTALL_PREFIX" ]; then
    echo "ERROR: Could not find DCS install prefix. Is DCS installed?"
    exit 1
fi

if [ -z "$SAVED_PREFIX" ]; then
    echo "ERROR: Could not find DCS saved games prefix. Launch DCS at least once first."
    exit 1
fi

SAVED_APP_ID=$(basename "$SAVED_PREFIX")

echo "    Install prefix: $INSTALL_PREFIX"
echo "    Saved prefix:   $SAVED_PREFIX (app ID: $SAVED_APP_ID)"

DCS_INSTALL="$INSTALL_PREFIX/pfx/drive_c/Program Files/Eagle Dynamics/DCS World"
SAVED_GAMES="$SAVED_PREFIX/pfx/drive_c/users/steamuser/Saved Games/DCS"

RESOLUTION_WIDTH=2560
RESOLUTION_HEIGHT=1440

echo "==> Installing pip3 and protontricks..."
sudo dnf install -y python3-pip protontricks

echo "==> Installing protonup..."
pip install protonup

echo "==> Installing GE-Proton..."
protonup

echo "==> Installing d3dcompiler_47 into DCS prefix..."
protontricks "$SAVED_APP_ID" d3dcompiler_47

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
        ["aspectRatio"] = 1.7777777777778,
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
