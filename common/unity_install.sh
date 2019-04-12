# Get option from zip name if applicable
#case $(basename $ZIP) in
#  *new*|*New*|*NEW*) NEW=true;;
#  *old*|*Old*|*OLD*) NEW=false;;
#esac
#might make this work later
# Change this path to wherever the keycheck binary is located in your installer
KEYCHECK=$TMPDIR/common/keycheck
chmod 755 $TMPDIR/common/keycheck

keytest() {
  ui_print " - Vol Key Test -"
  ui_print "   Press Vol Up:"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events) || return 1
  return 0
}

chooseport() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while (true); do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events
    if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
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

reset_defaults(){
  SETTINGS_APK_NODEVICESPECIFIC=true
  SETTINGS_SUPPORT_18by9=Disabled
  SETTINGS_SUPPORT_DUALCAMERA=Disabled
  SETTINGS_FRONT_PARAMETERS_S8=Disabled
  SETTINGS_DEVICESPECIFIC=none
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

#device checks
FRONT_SUPPORT_AF=true
FRONT_4by3_RESOLUTION="3264x2448"
FRONT_1by1_RESOLUTION="2448x2448"
FRONT_16by9_RESOLUTION="3264x1836"
FRONT_18by9_RESOLUTION="3264x1592"

INSTALLER_ISFINISHED=FALSE
SETTINGS_DEVICESPECIFIC=none

case "$(grep -o 'androidboot\.bootloader=...' /proc/cmdline)" in
    androidboot.bootloader=G93|androidboot.bootloader=N93)
      DETECTDEVICE=true
      DETECTDEVICE_MODEL=S7
      DETECTDEVICE_NAME="S7 / S7 Edge / Note 7 / Note FE"
      SETTINGS_APK_NODEVICESPECIFIC=false
      SETTINGS_SUPPORT_18by9=Disabled
      SETTINGS_SUPPORT_DUALCAMERA=Disabled
      SETTINGS_FRONT_PARAMETERS_S8=Disabled
      ;;
    androidboot.bootloader=G95)
      DETECTDEVICE=true
      DETECTDEVICE_MODEL=S8
      DETECTDEVICE_NAME="S8 / S8+"
      SETTINGS_APK_NODEVICESPECIFIC=false
      SETTINGS_SUPPORT_18by9=Enabled
      SETTINGS_SUPPORT_DUALCAMERA=Disabled
      SETTINGS_FRONT_PARAMETERS_S8=Enabled
      ;;
    androidboot.bootloader=N95)
      DETECTDEVICE=true
      DETECTDEVICE_MODEL=N8
      DETECTDEVICE_NAME="Note 8"
      SETTINGS_APK_NODEVICESPECIFIC=false
      SETTINGS_SUPPORT_18by9=Enabled
      SETTINGS_SUPPORT_DUALCAMERA=Enabled
      SETTINGS_FRONT_PARAMETERS_S8=Enabled
      ;;
esac

if version_check "28"; then
  DETECTDEVICE_VERSION=PIE
else
  DETECTDEVICE_VERSION=OREO
fi

SETTINGS_DEVICESPECIFIC="${DETECTDEVICE_MODEL}_${DETECTDEVICE_VERSION}"

if $DETECTDEVICE; then
  ui_print " "
  ui_print "- Select Option -"
  ui_print "  [?] Samsung Galaxy ${DETECTDEVICE_NAME} Detected"
  ui_print "  [?] Do you want to load the following settings?"
  ui_print "      (Recommended)"
  ui_print ""
  ui_print "    -     libexynoscamera.so mod: ${SETTINGS_DEVICESPECIFIC}"
  ui_print "    -  18.5:9 resolution support: ${SETTINGS_SUPPORT_18by9}"
  ui_print "    -   Dual camera lens support: ${SETTINGS_SUPPORT_DUALCAMERA}"
  ui_print "    - 8MP + Autofocus selfie cam: ${SETTINGS_FRONT_PARAMETERS_S8}"
  ui_print ""
  ui_print "   Vol Up = Yes, Vol Down = No"
  if $FUNCTION; then 
    INSTALLER_ISFINISHED=true
  else
    INSTALLER_ISFINISHED=false
    reset_defaults
  fi
else
  INSTALLER_ISFINISHED=false
  reset_defaults
fi

if ! $INSTALLER_ISFINISHED; then
  ui_print " "
  ui_print "- Select Option -"
  ui_print "   Do you want to modify libexynoscamera.so?:"
  ui_print "(Enables over 10s shutter speed,"
  ui_print "only compatible with the S7, S8 and Note 8)"
  ui_print "   Vol Up = Yes, Vol Down = No"
  if $FUNCTION; then 
    ui_print " "
    ui_print "- Select Option -"
    ui_print "   Choose version?:"
    ui_print "   Vol Up = Oreo, Vol Down = Pie"
    if $FUNCTION; then 
      MODLIBROM=
    else
      MODLIBROM=PIE
    fi
    ui_print " "
    ui_print "- Select Option -"
    ui_print "   Choose version?:"
    ui_print "   Vol Up = S7, Vol Down = Other (S8/N8)"
    if $FUNCTION; then 
      SETTINGS_APK_NODEVICESPECIFIC=false
      MODLIBDEVICE=S7
    else 
      ui_print " "
      ui_print "- Select Option -"
      ui_print "   Choose version?:"
      ui_print "   Vol Up = S8, Vol Down = Note 8"
      if $FUNCTION; then 
        SETTINGS_APK_NODEVICESPECIFIC=false
        MODLIBDEVICE=S8
      else 
        SETTINGS_APK_NODEVICESPECIFIC=false
        MODLIBDEVICE=N8
      fi
    fi
    SETTINGS_DEVICESPECIFIC="${MODLIBDEVICE}${MODLIBROM}"
  else 
    ui_print " "
    ui_print "- Select Option -"
    ui_print "   Do you want to enable features"
    ui_print "   requiring the modded lib anyway?:"
    ui_print "(only enable if you're going to provide your own one)"
    ui_print "   Vol Up = Yes, Vol Down = No"
    if $FUNCTION; then 
      SETTINGS_APK_NODEVICESPECIFIC=false
    else 
      SETTINGS_APK_NODEVICESPECIFIC=true
    fi
    SETTINGS_DEVICESPECIFIC=none
  fi

  ui_print " "
  ui_print "- Select Option -"
  ui_print "   Do you want to enable 18.5:9 resolution support?"
  ui_print "(Crashes on the S7)"
  ui_print "   Vol Up = Yes, Vol Down = No"
  if $FUNCTION; then 
    SETTINGS_SUPPORT_18by9=Enabled
  else 
    SETTINGS_SUPPORT_18by9=Disabled
  fi

  ui_print " "
  ui_print "- Select Option -"
  ui_print "   Do you want to enable dual camera lens support?"
  ui_print "(Disable unless you have the Note 8)"
  ui_print "   Vol Up = Yes, Vol Down = No"
  if $FUNCTION; then 
    SETTINGS_SUPPORT_DUALCAMERA=Enabled
  else 
    SETTINGS_SUPPORT_DUALCAMERA=Disabled
  fi

  ui_print " "
  ui_print "- Select Option -"
  ui_print "   Use S8 preset for selfie camera (8 MP + Autofocus enabled)"
  ui_print "or S7 preset (5 MP + Autofocus disabled)?"
  ui_print "   Vol Up = S8, Vol Down = S7"
  if $FUNCTION; then 
    SETTINGS_FRONT_PARAMETERS_S8=Enabled
  else 
    SETTINGS_FRONT_PARAMETERS_S8=Disabled
  fi
fi

ui_print ""
ui_print "=============="
ui_print "= Installing ="
ui_print "=============="
ui_print ""

if [ "$SETTINGS_DEVICESPECIFIC" != "none" ]; then
  ui_print "Installing Samsung Galaxy $SETTINGS_DEVICESPECIFIC modded libexynoscamera.so"
  cp -f "$TMPDIR/device_specific/$SETTINGS_DEVICESPECIFIC/system/lib/libexynoscamera.so"  "$TMPDIR/system/lib/libexynoscamera.so"
else
  ui_print "Skipping modded lib instalation"
fi

if $SETTINGS_APK_NODEVICESPECIFIC; then
  ui_print "Installing alternate APK with modded lib features disabled"
  cp -f $TMPDIR/device_specific/nolibapk/SamsungCamera7.apk  $TMPDIR/system/priv-app/SamsungCamera7/SamsungCamera7.apk
else
  ui_print "Installing normal APK with all features enabled"
fi

if [ "$SETTINGS_FRONT_PARAMETERS_S8" = "Enabled" ]; then
  FRONT_SUPPORT_AF=true
  FRONT_4by3_RESOLUTION="3264x2448"
  FRONT_1by1_RESOLUTION="2448x2448"
  FRONT_16by9_RESOLUTION="3264x1836"
  FRONT_18by9_RESOLUTION="3264x1592"

  ui_print "Using Galaxy S8 settings for the front facing camera (Autofocus enabled + 8 MP)"
  
else
  FRONT_SUPPORT_AF=false
  FRONT_4by3_RESOLUTION="2592x1944"
  FRONT_1by1_RESOLUTION="1936x1936"
  FRONT_16by9_RESOLUTION="2592x1458"

  ui_print "Using Galaxy S7 settings for the front facing camera (Autofocus disabled + 5 MP)"
fi

echo "  <local name=\"FRONT_CAMERA_RESOLUTION_16BY9_LARGE\" value=\"${FRONT_16by9_RESOLUTION}\" />
  <local name=\"FRONT_CAMERA_RESOLUTION_4BY3_LARGE\" value=\"${FRONT_4by3_RESOLUTION}\" />
  <local name=\"FRONT_CAMERA_RESOLUTION_1BY1_LARGE\" value=\"${FRONT_1by1_RESOLUTION}\" />
  <local name=\"FRONT_CAMERA_PICTURE_DEFAULT_RESOLUTION\" value=\"${FRONT_4by3_RESOLUTION}\" />
  <local name=\"SUPPORT_FRONT_AF\" value=\"${FRONAF}\" />
  <local name=\"FRONT_CAMCORDER_RESOLUTION_2560X1440\" value=\"true\" hdr=\"true\" preview-size=\"2560x1440\" snapshot-support=\"true\" snapshot-size=\"${FRONT_16by9_RESOLUTION}\" vdis=\"false\" effect=\"true\" object-tracking=\"false\" seamless-zoom-support=\"false\"/>
  <local name=\"FRONT_CAMCORDER_RESOLUTION_1920X1080\" value=\"true\" hdr=\"true\" preview-size=\"1920x1080\" snapshot-support=\"true\" snapshot-size=\"${FRONT_16by9_RESOLUTION}\" vdis=\"true\" effect=\"true\" object-tracking=\"false\" seamless-zoom-support=\"false\"/>
  <local name=\"FRONT_CAMCORDER_RESOLUTION_1440X1440\" value=\"true\" hdr=\"true\" preview-size=\"1072x1072\" snapshot-support=\"true\" snapshot-size=\"${FRONT_1by1_RESOLUTION}\" vdis=\"false\" effect=\"true\" object-tracking=\"false\" seamless-zoom-support=\"false\"/>
  <local name=\"FRONT_CAMCORDER_RESOLUTION_1280X720\" value=\"true\" hdr=\"true\" preview-size=\"1280x720\" snapshot-support=\"true\" snapshot-size=\"${FRONT_16by9_RESOLUTION}\" vdis=\"true\" effect=\"true\" object-tracking=\"false\" seamless-zoom-support=\"false\"/>
  <local name=\"FRONT_CAMCORDER_RESOLUTION_720X480\" value=\"true\" hdr=\"true\" preview-size=\"720x480\" snapshot-support=\"true\" snapshot-size=\"${FRONT_4by3_RESOLUTION}\" vdis=\"false\" effect=\"true\" object-tracking=\"false\" seamless-zoom-support=\"false\"/>
  <local name=\"FRONT_CAMCORDER_RESOLUTION_320X240\" value=\"true\" hdr=\"true\" preview-size=\"1440x1080\" snapshot-support=\"true\" snapshot-size=\"${FRONT_4by3_RESOLUTION}\" vdis=\"false\" effect=\"true\" object-tracking=\"false\" seamless-zoom-support=\"false\"/>
  <local name=\"FRONT_CAMCORDER_RESOLUTION_640X480\" value=\"true\" hdr=\"true\" preview-size=\"1440x1080\" snapshot-support=\"true\"  snapshot-size=\"${FRONT_4by3_RESOLUTION}\" vdis=\"false\" effect=\"true\" object-tracking=\"false\" seamless-zoom-support=\"false\"/>" >> $TMPDIR/system/cameradata/camera-feature-v7.xml

if [ "$SETTINGS_SUPPORT_18by9" = "Enabled" ]; then
  ui_print "Enabling 18.5:9 support"
  echo '<local name="BACK_CAMCORDER_RESOLUTION_2224X1080" value="true" hdr="true" preview-size="2224x1080" snapshot-support="true" snapshot-size="4032x1960" vdis="true" effect="true" object-tracking="true"/>
    <local name="FRONT_CAMCORDER_RESOLUTION_2224X1080" value="true" hdr="true" preview-size="2224x1080" snapshot-support="true" snapshot-size="${FRONT_18by9_RESOLUTION}" vdis="true" effect="true" object-tracking="true"/>
    <local name="BACK_CAMCORDER_RESOLUTION_1920X936" value="true" hdr="true" preview-size="1920x936" snapshot-support="true" snapshot-size="4032x1960" vdis="true" effect="true" object-tracking="true"/>
    <local name="FRONT_CAMERA_RESOLUTION_18DOT5BY9" value="${FRONT_18by9_RESOLUTION}" />
    <local name="BACK_CAMERA_RESOLUTION_18DOT5BY9" value="4032x1960" />' >> $TMPDIR/system/cameradata/camera-feature-v7.xml
else
  ui_print "Disabling 18.5:9 support"
fi

if [ "$SETTINGS_SUPPORT_DUALCAMERA" = "Enabled" ]; then
  ui_print "Enabling Dual Camera Features"
  echo "<!-- Dual camera features -->
    <local name=\"SUPPORT_DUAL_CAMERA_MODE\" value=\"true\"/>
    <local name=\"SUPPORT_DUAL_SEAMLESS_ZOOM\" value=\"true\"/>
    <local name=\"SUPPORT_ZOOM_IN_OUT_PHOTO\" value=\"true\"/>
    <local name=\"SUPPORT_JUMP_ZOOM_BUTTON\" value=\"true\"/>" >> $TMPDIR/system/cameradata/camera-feature-v7.xml
else
  ui_print "Disabling Dual Camera Features"
fi

echo '</resources>' >> $TMPDIR/system/cameradata/camera-feature-v7.xml

cp $TMPDIR/system/cameradata/camera-feature-v7.xml $TMPDIR/system/cameradata/camera-feature.xml

ui_print "Clearing ShootingModeProvider's data"
rm -rf '/data/data/com.samsung.android.provider.shootingmodeprovider'

if [ ! -f "/system/priv-app/SamsungCamera7/SamsungCamera7.apk" ]; then
  ui_print "Clearing Samsung Camera data"
  rm -rf '/data/data/com.sec.android.app.camera'
fi