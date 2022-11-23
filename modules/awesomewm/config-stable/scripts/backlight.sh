#!/bin/sh
val=$(cat /sys/class/backlight/nv_backlight/brightness)
if [ "$1" = "+" ] ; then
  val=`expr $val + 5`
else
  val=`expr $val - 5`
fi
echo $val | sudo tee /sys/class/backlight/nv_backlight/brightness
