# Get option from zip name if applicable
#case $(basename $ZIP) in
#  *new*|*New*|*NEW*) NEW=true;;
#  *old*|*Old*|*OLD*) NEW=false;;
#esac
#might make this work later
# Change this path to wherever the keycheck binary is located in your installer
KEYCHECK=$INSTALLER/common/keycheck
chmod 755 $INSTALLER/common/keycheck

keytest() {
  ui_print " - Vol Key Test -"
  ui_print "   Press Vol Up:"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events) || return 1
  return 0
}

chooseport() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while (true); do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events
    if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

chooseportold() {
  # Calling it first time detects previous input. Calling it second time will do what we want
  $KEYCHECK
  $KEYCHECK
  SEL=$?
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 0
  elif [ $SEL -eq $DOWN ]; then
    return 1
  else
    ui_print "   Vol key not detected!"
    abort "   Use name change method in TWRP"
  fi
}

ui_print ""

if keytest; then
  FUNCTION=chooseport
else
  FUNCTION=chooseportold
  ui_print "   ! Legacy device detected! Using old keycheck method"
  ui_print " "
  ui_print "- Vol Key Programming -"
  ui_print "   Press Vol Up Again:"
  $FUNCTION "UP"
  ui_print "   Press Vol Down"
  $FUNCTION "DOWN"
fi

ui_print " "
ui_print "- Select Option -"
ui_print "   Do you want to modify libexynoscamera.so?:"
ui_print "(Enables over 10s shutter speed, only compatible with the S7)"
ui_print "   Vol Up = Yes, Vol Down = No"
if $FUNCTION; then 
  MODLIB=true
else 
  MODLIB=false
fi

if $MODLIB; then
  cp -f $INSTALLER/device_specific/S7/system/lib/libexynoscamera.so  $INSTALLER/system/lib/libexynoscamera.so
else
  ui_print "I'm supposed to copy an APK that disables the shutter speeds here but I haven't made one yet, so just make sure to NOT USE OVER 10S SHUTTER SPEEDS, THE CAMERA APP WILL CRASH"
fi

ui_print " "
ui_print "- Select Option -"
ui_print "   Do you want to enable 18.5:9 resolution support?"
ui_print "(Crashes on the S7)"
ui_print "   Vol Up = Yes, Vol Down = No"
if $FUNCTION; then 
  SEIGHT=true
else 
  SEIGHT=false
fi

if $SEIGHT; then
  echo '<local name="BACK_CAMCORDER_RESOLUTION_2224X1080" value="true" hdr="true" preview-size="2224x1080" snapshot-support="true" snapshot-size="4032x1960" vdis="true" effect="true" object-tracking="true"/>
    <local name="BACK_CAMCORDER_RESOLUTION_1920X936" value="true" hdr="true" preview-size="1920x936" snapshot-support="true" snapshot-size="4032x1960" vdis="true" effect="true" object-tracking="true"/>' >> $INSTALLER/system/cameradata/camera-feature-v7.xml
fi

ui_print " "
ui_print "- Select Option -"
ui_print "   Do you want to enable dual camera lens support?"
ui_print "   Vol Up = Yes, Vol Down = No"
if $FUNCTION; then 
  NEIGHT=true
else 
  NEIGHT=false
fi

if $NEIGHT; then
  echo "<!-- Dual camera features -->
    <local name=\"SUPPORT_DUAL_CAMERA_MODE\" value=\"true\"/>
    <local name=\"SUPPORT_DUAL_SEAMLESS_ZOOM\" value=\"true\"/>
    <local name=\"SUPPORT_ZOOM_IN_OUT_PHOTO\" value=\"true\"/>
    <local name=\"SUPPORT_JUMP_ZOOM_BUTTON\" value=\"true\"/>" >> $INSTALLER/system/cameradata/camera-feature-v7.xml
fi