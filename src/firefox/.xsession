Xvesa -br -screen 1024x768x32 -shadow -2button -mouse /dev/input/mice,5 -nolisten tcp -I >/dev/null 2>&1 &
export XPID=$!
waitforX || ! echo failed in waitforX || exit
"$DESKTOP" 2>/tmp/wm_errors &
export WM_PID=$!
[ -x ./.setbackground ] && ./.setbackground 
[ -x ./.mouse_config ] && ./.mouse_config &
[ $(which "$ICONS".sh) ] && ${ICONS}.sh &
[ -d ".X.d" ] && find ".X.d" -type f -print | while read F; do . "$F"; done

#Invoking the startup script of 
#the network intensive GUI application
#Mount Shared Folders
sh ./scriptMount.sh

#Invoke abiword during startup
sh ./invoke.sh
