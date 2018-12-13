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
    abort "   Vol key not detected, aborting installation!"
  fi
}

version_check() {
  if [ "$(grep_prop ro.build.version.sdk)" == "$1" ]; then
    return 0
  else
    return 1
  fi
}

soc_check() {
  if [ "$(grep_prop ro.board.platform)" == "$1" ]; then
    return 0
  else
    return 1
  fi
}

device_check() {
  if [ "$(grep_prop ro.product.device)" == "$1" ]; then
    return 0
  else
    return 1
  fi
}

if ! soc_check "exynos5"; then
  abort "This module is only compatible with Exynos based devices."
fi

if ! version_check "26"; then
  abort "This module is only compatible with Android 8.0.0."
fi

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

#device checks
FINISH=FALSE

if device_check "herolte" || device_check "hero2lte"; then
  ui_print " "
  ui_print "- Select Option -"
  ui_print "  [?] Samsung Galaxy S7 Detected - Do you want to load defaults?"
  ui_print ""
  ui_print "    -    libexynoscamera.so mod: Enabled (S7)"
  ui_print "    - 18.5:9 resolution support: Disabled"
  ui_print "    -  Dual camera lens support: Disabled"
  ui_print ""
  ui_print "   Vol Up = Yes, Vol Down = No"
  if $FUNCTION; then 
    MODLIB=true
    SEIGHT=false
    NEIGHT=false
    FINISH=true
  fi
fi

if device_check "dreamlte"; then
  ui_print " "
  ui_print "- Select Option -"
  ui_print "  [?] Samsung Galaxy S8 Detected - Do you want to load defaults?"
  ui_print ""
  ui_print "    -    libexynoscamera.so mod: Disabled (Not available)"
  ui_print "    - 18.5:9 resolution support: Enabled"
  ui_print "    -  Dual camera lens support: Disabled"
  ui_print ""
  ui_print "   Vol Up = Yes, Vol Down = No"
  if $FUNCTION; then 
    MODLIB=false
    SEIGHT=true
    NEIGHT=false
    FINISH=true
  fi
fi

if device_check "dream2lte" || device_check "greatlte"; then
  ui_print " "
  ui_print "- Select Option -"
  ui_print "  [?] Samsung Galaxy S8+ or Note 8 Detected - Do you want to load defaults?"
  ui_print ""
  ui_print "    -    libexynoscamera.so mod: Disabled (Not available)"
  ui_print "    - 18.5:9 resolution support: Enabled"
  ui_print "    -  Dual camera lens support: Enabled"
  ui_print ""
  ui_print "   Vol Up = Yes, Vol Down = No"
  if $FUNCTION; then 
    MODLIB=false
    SEIGHT=true
    NEIGHT=true
    FINISH=true
  fi
fi

if !$FINISH; then
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

  ui_print " "
  ui_print "- Select Option -"
  ui_print "   Do you want to enable dual camera lens support?"
  ui_print "   Vol Up = Yes, Vol Down = No"
  if $FUNCTION; then 
    NEIGHT=true
  else 
    NEIGHT=false
  fi
fi

ui_print ""
ui_print "=============="
ui_print "= Installing ="
ui_print "=============="
ui_print ""

if $MODLIB; then
  ui_print "Installing Samsung Galaxy S7 modded libexynoscamera.so"
  cp -f $INSTALLER/device_specific/S7/system/lib/libexynoscamera.so  $INSTALLER/system/lib/libexynoscamera.so
else
  cp -f $INSTALLER/device_specific/nolibapk/SamsungCamera7.apk  $INSTALLER/system/priv-app/SamsungCamera7/SamsungCamera7.apk
fi

if $SEIGHT; then
  ui_print "Enabling 18.5:9 support"
  echo '<local name="BACK_CAMCORDER_RESOLUTION_2224X1080" value="true" hdr="true" preview-size="2224x1080" snapshot-support="true" snapshot-size="4032x1960" vdis="true" effect="true" object-tracking="true"/>
    <local name="BACK_CAMCORDER_RESOLUTION_1920X936" value="true" hdr="true" preview-size="1920x936" snapshot-support="true" snapshot-size="4032x1960" vdis="true" effect="true" object-tracking="true"/>' >> $INSTALLER/system/cameradata/camera-feature-v7.xml
fi

if $NEIGHT; then
  ui_print "Enabling Dual Camera Features"
  echo "<!-- Dual camera features -->
    <local name=\"SUPPORT_DUAL_CAMERA_MODE\" value=\"true\"/>
    <local name=\"SUPPORT_DUAL_SEAMLESS_ZOOM\" value=\"true\"/>
    <local name=\"SUPPORT_ZOOM_IN_OUT_PHOTO\" value=\"true\"/>
    <local name=\"SUPPORT_JUMP_ZOOM_BUTTON\" value=\"true\"/>" >> $INSTALLER/system/cameradata/camera-feature-v7.xml
fi