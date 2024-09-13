if $marker-neuter is %undefined then set marker-neuter 29ab3868-32b3-fca7-6b93-9e882287af64
if $marker-female is %undefined then set marker-female d92316c9-b2db-1c81-1c52-0c72d677cda8
if $marker-male is %undefined then set marker-male a9cb060a-7ca5-b953-6cd8-6ecbfd2097f7
if $rlv is %undefined then set rlv ~ARES
persona set marker $marker-neuter $marker-female $marker-male
persona set path $rlv/persona/xecalebmignano
persona set action {}

persona set action.yes Yes.
persona set action.no No.
persona set action.hi Hello.
persona set action.bye Goodbye.
persona set action.ok Acknowledged.
persona set action.lol Humor detected.
persona set action.thanks This unit thanks you.
persona set action.ready Ready.
persona set action.cannot This unit cannot comply.
persona set action.error An error has occurred.
persona set action.use This unit is available to assist.
persona set action.use? @say This unit offers \$pm.refl to assist.
persona set action.help This unit requires assistance.
persona set action.help? Do you require assistance?
persona set action.explain Please, explain further.
persona set action.mind @say This unit cannot comply while \$pm.gen cortex is disabled.

db id.prefix XE
name Caleb Mignano
id regen

db id.model Synthetic
db id.vendor Nanite Systems Field Robotics Group
db id.authority Wolf Howl
db id.serial 42-5985-84
db id.color.0 0 1.0 0.5
db id.color.1 0.7 0.4 1.0
db id.color.2 1 0 0
db id.color.3 0 1.0 0.5
db interface.sound.volume 1.0
db interface.compass.enabled 0
db interface.altimeter.enabled 1
db interface.width 1920
db interface.height 1009
db interface.height-mlook 1009
db interface.devices.scale 2
db interface.altimeter.enabled 1
db interface.speedometer.enabled 1
db interface.crosshair 16
db interface.sitrep.enabled 1
db interface.fov 90
db repair.autorepair 0

reset id
service interface restart
service repair restart
