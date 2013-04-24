# Command Line, proc might not be mounted
[ -f /proc/cmdline ] || /bin/mount /proc
CMDLINE=""; CMDLINE=" $(cat /proc/cmdline)"
# ANSI COLORS
CRE="$(echo -e '\r\033[K')"
RED="$(echo -e '\033[1;31m')"
GREEN="$(echo -e '\033[1;32m')"
YELLOW="$(echo -e '\033[1;33m')"
BLUE="$(echo -e '\033[1;34m')"
MAGENTA="$(echo -e '\033[1;35m')"
CYAN="$(echo -e '\033[1;36m')"
WHITE="$(echo -e '\033[1;37m')"
NORMAL="$(echo -e '\033[0;39m')"

useBusybox(){
alias ar="busybox ar"
alias awk="busybox awk"
alias clear="busybox clear"
alias cp="busybox cp"
alias cpio="busybox cpio"
alias dc="busybox dc"
alias df="busybox df"
alias du="busybox du"
alias depmod="busybox depmod"
alias expr="busybox expr"
alias fdisk="busybox fdisk"
alias fold="busybox fold"
alias grep="busybox grep"
alias gunzip="busybox gunzip"
alias hostname="busybox hostname"
alias kill="busybox kill"
alias killall="busybox killall"
alias ls="busybox ls"
alias md5sum="busybox md5sum"
alias mount="busybox mount"
alias sed="busybox sed"
alias sort="busybox sort"
alias swapoff="busybox swapoff"
alias tar="busybox tar"
alias umount="busybox umount"
alias wc="busybox wc"
alias wget="busybox wget"
alias sudo='sudo '
}

trim() { echo $1; }

stringinfile(){
case "$(cat $2)" in *$1*) return 0;; esac
return 1
}

stringinstring(){
case "$2" in *$1*) return 0;; esac
return 1
}

getbootparam(){
stringinstring " $1=" "$CMDLINE" || return 1
result="${CMDLINE##*$1=}"
result="${result%%[ 	]*}"
echo "$result"
return 0
}

getparam(){
stringinstring " $1=" "$2" || return 1
result="${2##*$1=}"
result="${result%%[ 	]*}"
echo "$result"
return 0
}

checkbootparam(){
stringinstring " $1" "$CMDLINE"
return "$?"
}

getbasefile(){
BASENAME=`basename $1`
FIELDS=`echo $BASENAME|awk 'BEGIN{ FS="."} {print NF}'`
FIELDS=`busybox expr "$FIELDS" - "$2"`
INFO=`echo $BASENAME|cut -f1-$FIELDS -d.`
echo $INFO
return 0
}

mounted(){
grep $1 /etc/mtab >/dev/null 2>&1
if [ $? == 0 ]; then return 0; fi
return 1
}

find_mountpoint() {
 MOUNTPOINT=""
 MOUNTED="no"
 D2="$1"
 if [ "$D2" == "nfs" ]; then
    MOUNTPOINT=/mnt/nfs
    MOUNTED="yes"
    return
 fi
 if [ "${D2:0:5}" == "UUID=" ]; then
   D2=`/sbin/blkid -lt $D2 -o device`
   if [ "$?" != 0 ]; then
     MOUNTPOINT=""
     return
   else
     D2="${D2%%:*}"
   fi
 elif [ "${D2:0:6}" == "LABEL=" ]; then
   D2=`/sbin/blkid -lt $D2 -o device`
   if [ "$?" != 0 ]; then
     MOUNTPOINT=""
     return
   else
     D2="${D2%%:*}"
   fi
 else
   D2=/dev/$D2
 fi
 MOUNTPOINT="$(grep -i ^$D2\  /etc/mtab|awk '{print $2}'|head -n 1)"
 if [ -n "$MOUNTPOINT" ]; then
   MOUNTED="yes"
   return
 fi
 
# Special case for virtual disk 
 if [ "$D2" == "/dev/tcvd" ]; then
   MOUNTPOINT="$(awk '/\/mnt\/tcvd/{print $2}' /etc/mtab|head -n 1)"
   if [ -n "$MOUNTPOINT" ]; then
     MOUNTED="yes"
     return
   fi
 fi

 MOUNTPOINT="$(grep -i ^$D2\  /etc/fstab|awk '{print $2}'|head -n 1)"
}

autoscan(){
FOUND=""
for DEVICE in `autoscan-devices`; do
   find_mountpoint $DEVICE
   if [ -n "$MOUNTPOINT" ]; then
     if [ "$MOUNTED" == "no" ]; then
       mount "$MOUNTPOINT" >/dev/null 2>&1
     fi
     if [ "-$2" "$MOUNTPOINT"/$1 ]; then
       FOUND="yes"
     fi
     if [ "$MOUNTED" == "no" ]; then
       umount "$MOUNTPOINT" >/dev/null 2>&1
     fi
     if [ -n "$FOUND" ]; then 
       echo "$DEVICE"
       return 0
     fi
   fi
done
DEVICE=""
return 1
}

getpasswd(){
  readpassword(){
    PASSWD=""
    until [ ${#PASSWD} -ge 8 ] && [ ${#PASSWD} -le 56 ]; do
      PASSWD=""
      CH="."
      if [ "$2" == "confirm" ]; then
        echo -n "${BLUE} Re-enter${NORMAL}: "
      else
        echo -n "${BLUE}Enter password (8 to 56 characters) for ${YELLOW}$1${NORMAL}: "
      fi
      while [ "$CH" != "" ]; do
        read -s -n 1 CH
        if [ "$CH" == "" -a ${#PASSWD} -gt 0 ]; then
          PASSWD=`echo $PASSWD | busybox sed 's/.$//'`
          echo -n -e "\b \b"
        elif [ "$CH" != "" ]; then
          PASSWD="$PASSWD$CH"
          if [ "$CH" != "" ]; then echo -n "*"; fi
        fi
      done
      [ ${#PASSWD} -lt 8 ] && echo " Password is too short!"
      [ ${#PASSWD} -gt 56 ] && echo " Password is too long!"
    done
  }
  OK=0
  until [ "$OK" == 1 ]; do
    readpassword $1
    PASSWD1=$PASSWD
    readpassword $1 confirm
    if [ "$PASSWD1" == "$PASSWD" ]; then
      OK=1
      echo " ${GREEN}Accepted.${NORMAL}"
    else
      echo " ${RED}Mismatch.${NORMAL}"
    fi
  done
  return 0
}

status() {
  local CHECK=$?
  echo -en "\\033[70G[ "
  if [ $CHECK = 0 ]; then
    echo -en "\\033[1;33mOK"
  else
    echo -en "\\033[1;31mFailed"
  fi
  echo -e "\\033[0;39m ]"
}

usleep_progress() {
# Wait 2 seconds
  CHAR='.'
  for i in `seq 1 79`
  do
    echo -n "$CHAR"
    usleep 25316
  done
  echo "$CHAR"
}

checkroot() {
 if [ `/usr/bin/id -u` -ne 0 ]; then
   echo "Need root privileges." >&2
   exit 1
 fi
}
 
checknotroot() {
 if [ `/usr/bin/id -u` -eq 0 ]; then
   echo "Don't run this as root." >&2
   exit 1
 fi
}

checkX() {
 if [ -z ${DISPLAY} ]; then
   echo "Requires X windows." >&2
   exit 1
 fi
}

setupHome(){
   yes n | cp -ai /etc/skel/. /home/"$USER"/ 2>/dev/null
   chown -Rh "$USER".staff /home/"$USER"
   chmod g+s,o-rwx /home/"$USER"
}

merge() {
awk -v mergedata="$1" -v target="$3" '
{
  if ( index($0,target) ) 
  {
     while (( getline item < mergedata ) > 0 )
       print item
     close(mergedata)
  }
  print $0
} ' "$2"
}

replace() {                    
awk -v mergedata="$1" -v target="$3" '
{                                     
  if ( index($0,target) )       
  {                      
     while (( getline item < mergedata ) > 0 )
       print item                             
     close(mergedata)                    
  } else print $0    
} ' "$2"         
}

purge(){
awk -v startTarget="$2" -v endTarget="$3" '
BEGIN { writeFlag=1 }
{
  if (index($0, startTarget))
  {
    print $0 
    writeFlag=0
  } else
    if (index($0, endTarget)) writeFlag=1
  
  if (writeFlag) print $0
} ' "$1"
}

getMajorVer() {
awk '{printf "%d", $1}' /usr/share/doc/tc/release.txt 
}


getBuild() {
BUILD=`uname -m`
case ${BUILD} in
	armv6l) echo "armv6" ;;
	armv7l) echo "armv7" ;;
	i686)   echo "x86" ;;
	x86_64) [ -f /lib/ld-linux-x86-64.so.2 ] && echo "x86_64" || echo "x86" ;;
	*)      echo "x86" ;;
esac
}

getMirror() {
BUILD="$1"
[ -z "$BUILD" ] && BUILD=$(getBuild)
read MIRROR < /opt/tcemirror
#MIRROR="${MIRROR%/}/$(getMajorVer).x/x86/tcz"
MIRROR="${MIRROR%/}/$(getMajorVer).x/$BUILD/tcz"
}

installed() {
  if [ -e /usr/local/tce.installed/${1%.*} ]; then 
    return 0
  else 
    return 1
  fi
}  

getKeyEventDevice() {
e=0
for i in /sys/class/input/input*/name; do
  if grep -q "eyboard" $i; then break; fi 
  e=`busybox expr "$e" + 1`
done
[ $e -gt 0 ] || exit 1
echo /dev/input/event$e
}

parentOf()
{
	PID=$(pidof $1) || return
	PPID=$(awk '/^PPid:/{print $2}' /proc/$PID/status)
	awk '/^Name:/{print $2}' /proc/$PPID/status
}

myParent()
{
	PID=$$
	PPID=$(awk '/^PPid:/{print $2}' /proc/$PID/status)
	awk '/^Name:/{print $2}' /proc/$PPID/status
}

launchApp() {
	FREEDESKTOP=/usr/local/share/applications
	if [ -e "$FREEDESKTOP"/"$1".desktop ]
	then
		E=`awk 'BEGIN{FS="="}/^Exec/{print $2}' "$FREEDESKTOP"/"$1".desktop`
 		E="${E% \%*}"
 		shift 1
		exec ${E} $@
	fi
}
