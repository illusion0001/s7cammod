# 4k60 Camera Mod
### For Samsung Exynos devices

[Telegram Group](https://t.me/note8_4K60FPS)

## Features:
* UHD @ 60 FPS, QHD @ 120 FPS and more custom resolutions
* Change audio bitrate, video encoder (enable HEVC), video bitrate
* Front facing camera Pro Mode
* Unlock Pro mode for Slow Motion resolutions
* Unlock Auto mode for front camera - Disable post-processing
* Custom ISO values in Pro mode (up to 6400)
* Custom long exposure Shutter Speed values (up to 90 seconds)
* Unlock Shutter Speeds slower than 1/30 for recording
* Change ISO while recording
* Enable HDR in UHD resolutions
* Remove Low Battery Flash Limit at 15%.
* Change Quick Launch Key from Home to Power in the settings and vice-versa

## How to install:
* Install the zip
* Clear ShootingModeProvider's data if you have any issues

## Compatibility
* Magisk 17+
* Most Exynos based Samsung devices running a Samsung Experience Android 8.0.0 Oreo ROM

## Changelog
### 7.6.86-2.2.2
* Enabled some region/CSC specific features
  * Enabled Anti-fog mode
  * Enabled shutter sound toggle
* Fixed effect UHD 30 FPS recording
* Fixed UHD 48 FPS recording
* Fixed S8/N8 unable to record selfie cam video bug
* Fixed non-functional 720x480 and 320x240 on the S7 selfie cam
* Made the module replace Samsung Camera 8 too
* Started distributing the LVB APK - Live Broadcast mode enabled
* Enabled AR Emoji

### 7.6.86-2.2.1
* Fixed device detection bugs

### 7.6.86-2.2.0
* Fixed UHFR modes for non-S7 devices
* Made Samsung Gallery recognize UHFR videos as Slow Motion
* Enabled AF/AE tracking for all non-UHFR modes
* Fixed QCIF and NTSC preview aspect ratios
* Created S8 modded lib
* Enabled ISO changing during recording
* Enabled Pro Mode for Selfie Cam (buggy/experimental)
* Added custom mod settings
  * You can now save all videos as slow motion
  * Custom audio bitrates
  * Change video encoder
  * Change video bitrate

### 7.6.86-2.1.0
* Updated the base APK to 7.6.86 (taken from the S7)
* Added 1080p240

### 7.6.39-2.0.4
* Fixed a bug where it installed N8 lib on S8 by default
* Fixed a bug in the N8 lib itself
* Made it automatically clear ShootingModeProvider's data to avoid bugs
* Fixed QCIF 10 FPS on the N8

### 7.6.39-2.0.3
* Improved S8/N8 compatibility
  * Fixed S8+ device recognition
  * Created Note 8 modded lib
  * Fixed selfie camera crash
  * Fixed 60 FPS modes for the N8
* Fixed the Unity installer

### 7.6.39-2.0.2
* Added device specific defaults

### 7.6.39-2.0.1
* Created alternate APK for people who don't want to patch libexynoscamera.so

### 7.6.39-2.0.0
* Started using the Unity installer
* Improved compatibility with other devices

### 7.6.39-1.0.1
* Added a device check

### 7.6.39-1.0.0
* Initial Release