#!/system/bin/sh
config="$1"
BLUETOOTH_SLEEP_PATH=/proc/bluetooth/sleep/proto
hciattach_pid=""
failed ()
{
  exit $2
}

program_bdaddr ()
{
}

config_bt ()
{
  baseband=`getprop ro.baseband`
  target=`getprop ro.board.platform`
  soc_hwid=`cat /sys/devices/soc0/soc_id`
  btsoc=`getprop qcom.bluetooth.soc`

  case $baseband in
    "msm")
        setprop ro.qualcomm.bluetooth.opp true
        setprop ro.qualcomm.bluetooth.hfp true
        setprop ro.qualcomm.bluetooth.hsp true
        setprop ro.qualcomm.bluetooth.pbap true
        setprop ro.qualcomm.bluetooth.ftp true
        setprop ro.qualcomm.bluetooth.nap true
        setprop ro.bluetooth.sap true
        setprop ro.bluetooth.dun true
        case $btsoc in
          "ath3k")
              setprop ro.qualcomm.bluetooth.map false
              ;;
          *)
              setprop ro.qualcomm.bluetooth.map true
              ;;
        esac
        ;;
  esac

if [ -f /system/etc/bluetooth/stack.conf ]; then
stack=`cat /system/etc/bluetooth/stack.conf`
fi

case "$stack" in
    "bluez")
	   setprop ro.qc.bluetooth.stack $stack
	   reason=`getprop vold.decrypt`
	   case "$reason" in
	       "trigger_restart_framework")
	           start dbus
	           ;;
	   esac
        ;;
    *)
        ;;
esac

}

start_hciattach ()
{
  /system/bin/hciattach -n $BTS_DEVICE $BTS_TYPE $BTS_BAUD &
  hciattach_pid=$!
  echo 1 > $BLUETOOTH_SLEEP_PATH
}

kill_hciattach ()
{
  echo 0 > $BLUETOOTH_SLEEP_PATH
  kill -TERM $hciattach_pid
}

case "$config" in
    "onboot")
        config_bt
        exit 0
        ;;
    *)
        ;;
esac

USAGE="hciattach [-n] [-p] [-b] [-t timeout] [-s initial_speed] <tty> <type | id> [speed] [flow|noflow] [bdaddr]"

while getopts "blnpt:s:" f
do
  case $f in
  b | l | n | p)  opt_flags="$opt_flags -$f" ;;
  t)      timeout=$OPTARG;;
  s)      initial_speed=$OPTARG;;
  \?)     echo $USAGE; exit 1;;
  esac
done
shift $(($OPTIND-1))

BOARD=`getprop ro.board.platform`
STACK=`getprop ro.qc.bluetooth.stack`
POWER_CLASS=`getprop qcom.bt.dev_power_class`
LE_POWER_CLASS=`getprop qcom.bt.le_dev_pwr_class`
TRANSPORT=`getprop ro.qualcomm.bt.hci_transport`
case $STACK in
    "bluez")
    ;;
    *)
       setprop bluetooth.status off
    ;;
esac


case $POWER_CLASS in
  1) PWR_CLASS="-p 0" ;
  2) PWR_CLASS="-p 1" ;
  3) PWR_CLASS="-p 2" ;
  *) PWR_CLASS="";
esac

case $LE_POWER_CLASS in
  1) LE_PWR_CLASS="-P 0" ;
  2) LE_PWR_CLASS="-P 1" ;
  3) LE_PWR_CLASS="-P 2" ;
  *) LE_PWR_CLASS="-P 1";
esac

eval $(/system/bin/hci_qcomm_init -e $PWR_CLASS $LE_PWR_CLASS && echo "exit_code_hci_qcomm_init=0" || echo "exit_code_hci_qcomm_init=1")

case $exit_code_hci_qcomm_init in
  *) failed "Bluetooth QSoC firmware download failed" $exit_code_hci_qcomm_init;
     case $STACK in
         "bluez")
         ;;
         *)
            setprop bluetooth.status off
        ;;
     esac
     exit $exit_code_hci_qcomm_init;;
esac

trap "kill_hciattach" TERM INT

case $TRANSPORT in
    "smd")
       case $STACK in
           "bluez")
              echo 1 > /sys/module/hci_smd/parameters/hcismd_set
           ;;
           *)
              setprop bluetooth.status on
           ;;
       esac
     ;;
     *)
        logi "start hciattach"
        start_hciattach
        case $STACK in
            "bluez")
            ;;
            *)
               setprop bluetooth.status on
            ;;
        esac

        wait $hciattach_pid
        logi "Bluetooth stopped"
     ;;
esac

exit 0
