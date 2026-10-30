#!/bin/bash
# Jagged Alliance 2 v1.13 (1vibe13 SDL3 engine) for the TrimUI Brick
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

$ESUDO chmod 666 /dev/uinput

GAMEDIR="/$directory/ports/ja2-113"
cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

echo "== device: $DEVICE_NAME  cfw: $CFW_NAME  dir: $GAMEDIR"
ldd --version 2>&1 | head -1
cat /sys/class/graphics/fb0/virtual_size /sys/class/graphics/fb0/bits_per_pixel 2>/dev/null

chmod +x ./JA2_ENGLISH ./JA2UB_ENGLISH 2>/dev/null

export SDL_VIDEO_DRIVER=fbdev
export SDL_AUDIO_DRIVER=alsa
export TEXTINPUTINTERACTIVE="Y"

$GPTOKEYB "JA2_ENGLISH" $HOTKEY textinput -c "./ja2.gptk" &
./JA2_ENGLISH
echo "== exit code: $?"

$ESUDO kill -9 $(pidof gptokeyb) 2>/dev/null
printf "\033c" >> /dev/tty1
