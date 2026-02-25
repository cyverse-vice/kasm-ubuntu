#!/bin/bash
### every exit != 0 fails the script
set -e

# ===== HIPAA Clean Room -- Force disable all peripheral services =====
# Re-export at script level as defense-in-depth to prevent
# `docker run -e KASM_SVC_UPLOADS=1` from overriding hardening
export KASM_SVC_AUDIO=0
export KASM_SVC_AUDIO_INPUT=0
export KASM_SVC_UPLOADS=0
export KASM_SVC_GAMEPAD=0
export KASM_SVC_WEBCAM=0
export KASM_SVC_PRINTER=0
export DLP_PROCESS_FAIL_SECURE=1
echo "=== HIPAA Clean Room Mode ==="
echo "Clipboard: DISABLED | File upload: DISABLED | Audio: DISABLED"
echo "Peripheral services: DISABLED | DLP fail-secure: ENABLED"
echo "=============================="

# ===== Network Firewall (defense-in-depth) =====
# Applies iptables if CAP_NET_ADMIN is available.
# In Kubernetes with capabilities dropped, this silently skips
# and relies on NetworkPolicy for egress control.
# For standalone Docker: run with --cap-add NET_ADMIN
if iptables -L -n >/dev/null 2>&1; then
    echo "[FIREWALL] Applying HIPAA Clean Room network rules..."
    iptables -F OUTPUT 2>/dev/null || true
    iptables -P OUTPUT DROP
    # Loopback (X11, VNC internal communication)
    iptables -A OUTPUT -o lo -j ACCEPT
    # Established/related (reply traffic for VNC connections)
    iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    # DNS (required for iRODS hostname resolution)
    iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
    iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
    # iRODS data transfer (CyVerse Data Store)
    iptables -A OUTPUT -p tcp --dport 1247 -j ACCEPT
    iptables -A OUTPUT -p tcp --dport 20000:20199 -j ACCEPT
    # Drop everything else
    iptables -A OUTPUT -j DROP
    echo "[FIREWALL] Rules active: loopback + DNS + iRODS only"
else
    echo "[FIREWALL] CAP_NET_ADMIN not available -- relying on orchestrator network policy"
fi

# Inject IPLANT_USER into the KasmVNC watermark template
# Copy defaults to user-writable location, modify there
cp /usr/share/kasmvnc/kasmvnc_defaults.yaml /tmp/kasmvnc_defaults.yaml
if [ -n "$IPLANT_USER" ]; then
    sed -i "s/\${USER}/${IPLANT_USER}/g" /tmp/kasmvnc_defaults.yaml
    echo "Watermark user: $IPLANT_USER"
else
    echo "WARNING: IPLANT_USER not set, watermark will show 'unknown'"
    sed -i "s/\${USER}/unknown/g" /tmp/kasmvnc_defaults.yaml
fi
cp /tmp/kasmvnc_defaults.yaml /usr/share/kasmvnc/kasmvnc_defaults.yaml 2>/dev/null || true
# Also write as user-level override
mkdir -p ${HOME}/.vnc
cp /tmp/kasmvnc_defaults.yaml ${HOME}/.vnc/kasmvnc.yaml

no_proxy="localhost,127.0.0.1"

# Set lang values
if [ "${LC_ALL}" != "en_US.UTF-8" ]; then
  export LANG=${LC_ALL}
  export LANGUAGE=${LC_ALL}
fi

# dict to store processes
declare -A KASM_PROCS

# switch passwords to local variables
tmpval=$VNC_VIEW_ONLY_PW
unset VNC_VIEW_ONLY_PW
VNC_VIEW_ONLY_PW=$tmpval
tmpval=$VNC_PW
unset VNC_PW
VNC_PW=$tmpval

BUILD_ARCH=$(uname -p)
if [ -z ${DRINODE+x} ]; then
  DRINODE="/dev/dri/renderD128"
fi
KASMNVC_HW3D=''
if [ ! -z ${HW3D+x} ]; then
  KASMVNC_HW3D="-hw3d"
fi
STARTUP_COMPLETE=0

######## FUNCTION DECLARATIONS ##########

## print out help
function help (){
	echo "
		USAGE:

		OPTIONS:
		-w, --wait      (default) keeps the UI and the vncserver up until SIGINT or SIGTERM will received
		-s, --skip      skip the vnc startup and just execute the assigned command.
		                example: docker run kasmweb/core --skip bash
		-d, --debug     enables more detailed startup output
		                e.g. 'docker run kasmweb/core --debug bash'
		-h, --help      print out this help

		Fore more information see: https://github.com/ConSol/docker-headless-vnc-container
		"
}

trap cleanup SIGINT SIGTERM SIGQUIT SIGHUP ERR

## correct forwarding of shutdown signal
function cleanup () {
    kill -s SIGTERM $!
    exit 0
}

function start_kasmvnc (){
	if [[ $DEBUG == true ]]; then
	  echo -e "\n------------------ Start KasmVNC Server ------------------------"
	fi

	DISPLAY_NUM=$(echo $DISPLAY | grep -Po ':\d+')

	if [[ $STARTUP_COMPLETE == 0 ]]; then
	    vncserver -kill $DISPLAY &> $STARTUPDIR/vnc_startup.log \
	    || rm -rfv /tmp/.X*-lock /tmp/.X11-unix &> $STARTUPDIR/vnc_startup.log \
	    || echo "no locks present"
	fi

	rm -rf $HOME/.vnc/*.pid
	echo "exit 0" > $HOME/.vnc/xstartup
	chmod +x $HOME/.vnc/xstartup

	VNCOPTIONS="$VNCOPTIONS -select-de manual"

	if [[ "${BUILD_ARCH}" =~ ^aarch64$ ]] && [[ -f /lib/aarch64-linux-gnu/libgcc_s.so.1 ]] ; then
		LD_PRELOAD=/lib/aarch64-linux-gnu/libgcc_s.so.1 vncserver $DISPLAY -disableBasicAuth $KASMVNC_HW3D -drinode $DRINODE -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION -websocketPort $NO_VNC_PORT -httpd ${KASM_VNC_PATH}/www -FrameRate=$MAX_FRAME_RATE -interface 0.0.0.0 -BlacklistThreshold=0 -FreeKeyMappings $VNCOPTIONS $KASM_SVC_SEND_CUT_TEXT $KASM_SVC_ACCEPT_CUT_TEXT
	else
		vncserver $DISPLAY -disableBasicAuth $KASMVNC_HW3D -drinode $DRINODE -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION -websocketPort $NO_VNC_PORT -httpd ${KASM_VNC_PATH}/www -FrameRate=$MAX_FRAME_RATE -interface 0.0.0.0 -BlacklistThreshold=0 -FreeKeyMappings $VNCOPTIONS $KASM_SVC_SEND_CUT_TEXT $KASM_SVC_ACCEPT_CUT_TEXT
	fi

	KASM_PROCS['kasmvnc']=$(cat $HOME/.vnc/*${DISPLAY_NUM}.pid)

	#Disable X11 Screensaver
	if [ "${DISTRO}" != "alpine" ]; then
		echo "Disabling X Screensaver Functionality"
		xset -dpms
		xset s off
		xset q
	else
		echo "Disabling of X Screensaver Functionality for $DISTRO is not required."
	fi

	if [[ $DEBUG == true ]]; then
	  echo -e "\n------------------ Started Websockify  ----------------------------"
	  echo "Websockify PID: ${KASM_PROCS['kasmvnc']}";
	fi
}

function start_window_manager (){
	echo -e "\n------------------ Xfce4 window manager startup------------------"

	if [ "${START_XFCE4}" == "1" ] ; then
		if [ -f /opt/VirtualGL/bin/vglrun ] && [ ! -z "${KASM_EGL_CARD}" ] && [ ! -z "${KASM_RENDERD}" ] && [ -O "${KASM_RENDERD}" ] && [ -O "${KASM_EGL_CARD}" ] ; then
		echo "Starting XFCE with VirtualGL using EGL device ${KASM_EGL_CARD}"
			DISPLAY=:1 /opt/VirtualGL/bin/vglrun -d "${KASM_EGL_CARD}" /usr/bin/startxfce4 --replace &
		else
			echo "Starting XFCE"
			if [ -f '/usr/bin/zypper' ]; then
				DISPLAY=:1 /usr/bin/dbus-launch /usr/bin/startxfce4 --replace &
			else
				/usr/bin/startxfce4 --replace &
			fi
		fi
		KASM_PROCS['window_manager']=$!
	else
		echo "Skipping XFCE Startup"
	fi
}

function custom_startup (){
	custom_startup_script=/dockerstartup/custom_startup.sh
	if [ -f "$custom_startup_script" ]; then
		if [ ! -x "$custom_startup_script" ]; then
			echo "${custom_startup_script}: not executable, exiting"
			exit 1
		fi

		"$custom_startup_script" &
		KASM_PROCS['custom_startup']=$!
	fi
}

############ END FUNCTION DECLARATIONS ###########

if [[ $1 =~ -h|--help ]]; then
    help
    exit 0
fi

# should also source $STARTUPDIR/generate_container_user
if [ -f $HOME/.bashrc ]; then
    source $HOME/.bashrc
fi

if [[ ${KASM_DEBUG:-0} == 1 ]]; then
    echo -e "\n\n------------------ DEBUG KASM STARTUP -----------------"
    export DEBUG=true
    set -x
fi

## resolve_vnc_connection
VNC_IP=$(hostname -i)
if [[ $DEBUG == true ]]; then
    echo "IP Address used for external bind: $VNC_IP"
fi

# Create cert for KasmVNC
mkdir -p ${HOME}/.vnc
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout ${HOME}/.vnc/self.pem -out ${HOME}/.vnc/self.pem -subj "/C=US/ST=VA/L=None/O=None/OU=DoFu/CN=kasm/emailAddress=none@none.none"

# first entry is control, second is view (if only one is valid for both)
mkdir -p "$HOME/.vnc"
PASSWD_PATH="$HOME/.kasmpasswd"
if [[ -f $PASSWD_PATH ]]; then
    echo -e "\n---------  purging existing VNC password settings  ---------"
    rm -f $PASSWD_PATH
fi
VNC_PW_HASH=$(python3 -c "import crypt; print(crypt.crypt('${VNC_PW}', '\$5\$kasm\$'));")
VNC_VIEW_PW_HASH=$(python3 -c "import crypt; print(crypt.crypt('${VNC_VIEW_ONLY_PW}', '\$5\$kasm\$'));")
echo "kasm_user:${VNC_PW_HASH}:ow" > $PASSWD_PATH
echo "kasm_viewer:${VNC_VIEW_PW_HASH}:" >> $PASSWD_PATH
chmod 600 $PASSWD_PATH


# start processes (VNC + window manager only -- no peripheral services)
start_kasmvnc
start_window_manager

STARTUP_COMPLETE=1


## log connect options
echo -e "\n\n------------------ KasmVNC environment started ------------------"

# tail vncserver logs
tail -f $HOME/.vnc/*$DISPLAY.log &

KASMIP=$(hostname -i)
echo "Kasm User ${KASM_USER}(${KASM_USER_ID}) started container id ${HOSTNAME} with local IP address ${KASMIP}"

# start custom startup script
custom_startup

# Monitor Kasm Services
sleep 3
while :
do
	for process in "${!KASM_PROCS[@]}"; do
		if ! kill -0 "${KASM_PROCS[$process]}" ; then

			# DLP Policy: fail secure -- exit on any process crash
			if [[ ${DLP_PROCESS_FAIL_SECURE:-0} == 1 ]]; then
				exit 1
			fi

			case $process in
				kasmvnc)
					if [ "$KASMVNC_AUTO_RECOVER" = true ] ; then
						echo "KasmVNC crashed, restarting"
						start_kasmvnc
					else
						echo "KasmVNC crashed, exiting container"
						exit 1
					fi
					;;
				window_manager)
					echo "Window manager crashed, restarting"
					start_window_manager
					;;
				custom_script)
					echo "The custom startup script exited."
					custom_startup
					;;
				*)
					echo "Unknown Service: $process"
					;;
			esac
		fi
	done
	sleep 3
done


echo "Exiting Kasm container"
