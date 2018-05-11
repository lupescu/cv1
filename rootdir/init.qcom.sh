#!/system/bin/sh
# Copyright (c) 2009-2017, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

target=`getprop ro.board.platform`
if [ -f /sys/devices/soc0/soc_id ]; then
    platformid=`cat /sys/devices/soc0/soc_id`
else
    platformid=`cat /sys/devices/system/soc/soc0/id`
fi

start_battery_monitor()
{
	if ls /sys/bus/spmi/devices/qpnp-bms-*/fcc_data ; then
		chown -h root.system /sys/module/pm8921_bms/parameters/*
		chown -h root.system /sys/module/qpnp_bms/parameters/*
		chown -h root.system /sys/bus/spmi/devices/qpnp-bms-*/fcc_data
		chown -h root.system /sys/bus/spmi/devices/qpnp-bms-*/fcc_temp
		chown -h root.system /sys/bus/spmi/devices/qpnp-bms-*/fcc_chgcyl
		chmod 0660 /sys/module/qpnp_bms/parameters/*
		chmod 0660 /sys/module/pm8921_bms/parameters/*
		mkdir -p /data/bms
		chown -h root.system /data/bms
		chmod 0770 /data/bms
		start battery_monitor
	fi
}

start_charger_monitor()
{
	if ls /sys/module/qpnp_charger/parameters/charger_monitor; then
		chown -h root.system /sys/module/qpnp_charger/parameters/*
		chown -h root.system /sys/class/power_supply/battery/input_current_max
		chown -h root.system /sys/class/power_supply/battery/input_current_trim
		chown -h root.system /sys/class/power_supply/battery/input_current_settled
		chown -h root.system /sys/class/power_supply/battery/voltage_min
		chmod 0664 /sys/class/power_supply/battery/input_current_max
		chmod 0664 /sys/class/power_supply/battery/input_current_trim
		chmod 0664 /sys/class/power_supply/battery/input_current_settled
		chmod 0664 /sys/class/power_supply/battery/voltage_min
		chmod 0664 /sys/module/qpnp_charger/parameters/charger_monitor
		start charger_monitor
	fi
}

start_vm_bms()
{
	if [ -e /dev/vm_bms ]; then
		chown -h root.system /sys/class/power_supply/bms/current_now
		chown -h root.system /sys/class/power_supply/bms/voltage_ocv
		chmod 0664 /sys/class/power_supply/bms/current_now
		chmod 0664 /sys/class/power_supply/bms/voltage_ocv
		start vm_bms
	fi
}

start_msm_irqbalance_8939()
{
	if [ -f /system/bin/msm_irqbalance ]; then
		case "$platformid" in
		    "239" | "293" | "294" | "295" | "304" | "313" | "338")
			start msm_irqbalance;;
		esac
	fi
}

start_msm_irqbalance()
{
	if [ -f /system/bin/msm_irqbalance ]; then
		start msm_irqbalance
	fi
}

start_copying_prebuilt_qcril_db()
{
    if [ -f /system/vendor/qcril.db -a ! -f /data/misc/radio/qcril.db ]; then
        cp /system/vendor/qcril.db /data/misc/radio/qcril.db
        chown -h radio.radio /data/misc/radio/qcril.db
    fi
}

baseband=`getprop ro.baseband`
echo 1 > /proc/sys/net/ipv6/conf/default/accept_ra_defrtr

case "$baseband" in
        "svlte2a")
        start bridgemgrd
        ;;
esac

case "$target" in
    "msm7630_surf" | "msm7630_1x" | "msm7630_fusion")
        if [ -f /sys/devices/soc0/hw_platform ]; then
            value=`cat /sys/devices/soc0/hw_platform`
        else
            value=`cat /sys/devices/system/soc/soc0/hw_platform`
        fi
        case "$value" in
            "Fluid")
             start profiler_daemon;;
        esac
        ;;
    "msm8660" )
        if [ -f /sys/devices/soc0/hw_platform ]; then
            platformvalue=`cat /sys/devices/soc0/hw_platform`
        else
            platformvalue=`cat /sys/devices/system/soc/soc0/hw_platform`
        fi
        case "$platformvalue" in
            "Fluid")
                start profiler_daemon;;
        esac
        ;;
    "msm8960")
        case "$baseband" in
            "msm")
                start_battery_monitor;;
        esac

        if [ -f /sys/devices/soc0/hw_platform ]; then
            platformvalue=`cat /sys/devices/soc0/hw_platform`
        else
            platformvalue=`cat /sys/devices/system/soc/soc0/hw_platform`
        fi
        case "$platformvalue" in
             "Fluid")
                 start profiler_daemon;;
             "Liquid")
                 start profiler_daemon;;
        esac
        ;;
    "msm8974")
        platformvalue=`cat /sys/devices/soc0/hw_platform`
        case "$platformvalue" in
             "Fluid")
                 start profiler_daemon;;
             "Liquid")
                 start profiler_daemon;;
        esac
        case "$baseband" in
            "msm")
                start_battery_monitor
                ;;
        esac
        start_charger_monitor
        ;;
    "apq8084")
        platformvalue=`cat /sys/devices/soc0/hw_platform`
        case "$platformvalue" in
             "Fluid")
                 start profiler_daemon;;
             "Liquid")
                 start profiler_daemon;;
        esac
        ;;
    "msm8226")
        start_charger_monitor
        ;;
    "msm8610")
        start_charger_monitor
        ;;
    "msm8916")
        start_vm_bms
        start_msm_irqbalance_8939
        if [ -f /sys/devices/soc0/soc_id ]; then
            soc_id=`cat /sys/devices/soc0/soc_id`
        else
            soc_id=`cat /sys/devices/system/soc/soc0/id`
        fi

        if [ -f /sys/devices/soc0/platform_subtype_id ]; then
             platform_subtype_id=`cat /sys/devices/soc0/platform_subtype_id`
        fi
        if [ -f /sys/devices/soc0/hw_platform ]; then
             hw_platform=`cat /sys/devices/soc0/hw_platform`
        fi
        case "$soc_id" in
             "239")
                  case "$hw_platform" in
                       "Surf")
                            case "$platform_subtype_id" in
                                 "1")
                                      setprop qemu.hw.mainkeys 0
                                      ;;
                            esac
                            ;;
                       "MTP")
                          case "$platform_subtype_id" in
                               "3")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                          esac
                          ;;
                  esac
                  ;;
        esac
        ;;
    "msm8994" | "msm8992" | "msm8998")
        start_msm_irqbalance
        ;;
    "msm8996")
        if [ -f /sys/devices/soc0/hw_platform ]; then
             hw_platform=`cat /sys/devices/soc0/hw_platform`
        fi
        case "$hw_platform" in
                "MTP" | "CDP")
                #Loop through the sysfs nodes and determine the correct sysfs to change the permission and ownership.
                        for count in 0 1 2 3 4 5 6 7 8 9 10
                        do
                                dir="/sys/devices/soc/75ba000.i2c/i2c-12/12-0020/input/input"$count
                                if [ -d "$dir" ]; then
                                     chmod 0660 $dir/secure_touch_enable
                                     chmod 0440 $dir/secure_touch
                                     chown system.drmrpc $dir/secure_touch_enable
                                     chown system.drmrpc $dir/secure_touch
                                     break
                                fi
                        done
                        ;;
        esac
        ;;
    "msm8909")
        start_vm_bms
        ;;
    "msm8937")
        start_msm_irqbalance_8939
        if [ -f /sys/devices/soc0/soc_id ]; then
            soc_id=`cat /sys/devices/soc0/soc_id`
        else
            soc_id=`cat /sys/devices/system/soc/soc0/id`
        fi

        if [ -f /sys/devices/soc0/hw_platform ]; then
             hw_platform=`cat /sys/devices/soc0/hw_platform`
        else
             hw_platform=`cat /sys/devices/system/soc/soc0/hw_platform`
        fi
        case "$soc_id" in
             "294" | "295" | "303" | "307" | "308" | "309" | "313" | "320")
                  case "$hw_platform" in
                       "Surf")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                       "MTP")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                       "RCM")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                  esac
                  ;;
       esac
        ;;
    "msm8953")
	start_msm_irqbalance_8939
        if [ -f /sys/devices/soc0/soc_id ]; then
            soc_id=`cat /sys/devices/soc0/soc_id`
        else
            soc_id=`cat /sys/devices/system/soc/soc0/id`
        fi

        if [ -f /sys/devices/soc0/hw_platform ]; then
             hw_platform=`cat /sys/devices/soc0/hw_platform`
        else
             hw_platform=`cat /sys/devices/system/soc/soc0/hw_platform`
        fi
        case "$soc_id" in
             "293" | "304" | "338" )
                  case "$hw_platform" in
                       "Surf")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                       "MTP")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                       "RCM")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                  esac
                  ;;
       esac
        ;;
esac

#
# Copy qcril.db if needed for RIL
#
start_copying_prebuilt_qcril_db
echo 1 > /data/misc/radio/db_check_done

#
# Make modem config folder and copy firmware config to that folder for RIL
#
if [ -f /data/misc/radio/ver_info.txt ]; then
    prev_version_info=`cat /data/misc/radio/ver_info.txt`
else
    prev_version_info=""
fi

cur_version_info=`cat /firmware/verinfo/ver_info.txt`

build_product=`getprop ro.build.product`
product_name=`getprop ro.product.name`
target_operator=`getprop ro.build.target_operator`
laop_brand=`getprop ro.lge.laop.brand`
sku_carrier=`getprop ro.lge.sku_carrier`

#
# MCFG GROUP 1 ~ 5
# 1:TMUS / 2:MPCS / 3:TRF-CDMA / 4:TRF-GSM / 5:NAO-AMAZON,CCA / 6:NAO-USC / 7:NAO-LRA / 8:CANADA / 9:CV1/3 VZW

# directory name description
# 1. ro : ROW
# 2. GSM - tm : TMO / tr : TRF / at : ATT / cl : CLARO / cc : CCA / cc_ti : CCA_TING / si : SIMPLE
# 3. CDMA - hv : hVoLTE / us : USC

mcfg_group_1=("gsm/tm" "gsm/ro_tm")
mcfg_group_2=("gsm/tm" "gsm/ro_tm")
mcfg_group_3=("cdma_na/tr_hV" "cdma_na/ro_tr_hv")
mcfg_group_4=("gsm/tr_at" "gsm/tr_cl" "gsm/tr_si" "gsm/tr_tm" "gsm/ro_tr_at")
mcfg_group_5=("gsm/at" "gsm/cc" "gsm/cc_ti" "gsm/tm" "gsm/tr_at" "gsm/tr_si" "gsm/tr_tm" "gsm/ro_at")
mcfg_group_6=("cdma_na/us" "cdma_na/ro_us")
mcfg_group_7=("cdma_na/hv" "cdma_na/ro_us")
mcfg_group_8=("canada/be" "canada/es" "canada/rg" "canada/te" "canada/vt" "canada/wi" "canada/ro_rg")
mcfg_group_9=("cdma_na/hv" "cdma_na/ro_hv")

if [ "$build_product" = "lv517" ]||[ "$build_product" = "sf317" ] || [ "$build_product" = "lv7" ] || [ "$build_product" = "lv9" ] || [ "$build_product" = "mhn" ] || [ "$build_product" = "cv1" ] || [ "$build_product" = "cv3" ]; then
    #no check version
    rm -rf /data/misc/radio/modem_config
    mkdir /data/misc/radio/modem_config
    chmod 770 /data/misc/radio/modem_config
    if [ "$product_name" = "cv1_lao_com" ] || [ "$product_name" = "cv3_lao_com" ]; then
        `setprop persist.radio.sw_mbn_loaded 0`
        #`setprop persist.radio.hw_mbn_loaded 0`

        mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na
        chmod 770 /data/misc/radio/modem_config/mcfg_sw/generic/na

        cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_hw /data/misc/radio/modem_config
        cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/common /data/misc/radio/modem_config/mcfg_sw/generic


        if [ "$target_operator" = "TMO" ]; then
            for value in "${mcfg_group_1[@]}"; do
                if [ ! -d /data/misc/radio/modem_config/mcfg_sw/generic/na/$value ]; then
                    mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na/$value
                fi
                cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/na/"$value"/* /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value"
            done
        elif [ "$target_operator" = "MPCS" ]; then
            for value in "${mcfg_group_2[@]}"; do
                if [ ! -d /data/misc/radio/modem_config/mcfg_sw/generic/na/$value ]; then
                    mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na/$value
                fi
                cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/na/"$value"/* /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value"
            done
        elif [ "$target_operator" = "TRF" ] && [ "$product_name" = "cv1_lao_com" ]; then
            if [ "$sku_carrier" = "TRF_C" ]; then
                for value in "${mcfg_group_3[@]}"; do
                    if [ ! -d /data/misc/radio/modem_config/mcfg_sw/generic/na/$value ]; then
                        mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na/$value
                    fi
                    cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/na/"$value"/* /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value"
                done
            else
                for value in "${mcfg_group_4[@]}"; do
                    if [ ! -d /data/misc/radio/modem_config/mcfg_sw/generic/na/$value ]; then
                        mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na/$value
                    fi
                    cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/na/"$value"/* /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value"
                done
            fi
        elif [ "$target_operator" = "TRF" ] && [ "$product_name" = "cv3_lao_com" ]; then
            for value in "${mcfg_group_3[@]}"; do
                if [ ! -d /data/misc/radio/modem_config/mcfg_sw/generic/na/$value ]; then
                    mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na/$value
                fi
                cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/na/"$value"/* /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value"
            done
            for value in "${mcfg_group_4[@]}"; do
                if [ ! -d /data/misc/radio/modem_config/mcfg_sw/generic/na/$value ]; then
                    mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na/$value
                fi
                cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/na/"$value"/* /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value"
            done
        elif [ "$target_operator" = "NAO" ]; then
            if [ "$sku_carrier" = "ATT" ]; then
                for value in "${mcfg_group_5[@]}"; do
                    if [ ! -d /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value" ]; then
                        mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value"
                    fi
                    cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/na/"$value"/* /data/misc/radio/modem_config/mcfg_sw/generic/na/$value
                done
            elif [ "$sku_carrier" = "USC" ]; then
                for value in "${mcfg_group_6[@]}"; do
                    if [ ! -d /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value" ]; then
                        mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value"
                    fi
                    cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/na/"$value"/* /data/misc/radio/modem_config/mcfg_sw/generic/na/$value
                done
            else
                for value in "${mcfg_group_7[@]}"; do
                    if [ ! -d /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value" ]; then
                        mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value"
                    fi
                    cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/na/"$value"/* /data/misc/radio/modem_config/mcfg_sw/generic/na/$value
                done
            fi
        elif [ "$target_operator" = "OPEN" ]; then
            for value in "${mcfg_group_8[@]}"; do
                if [ ! -d /data/misc/radio/modem_config/mcfg_sw/generic/na/$value ]; then
                    mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na/$value
                fi
                cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/na/$value/* /data/misc/radio/modem_config/mcfg_sw/generic/na/$value
            done
        else
            cp -r /firmware/image/modem_pr/mcfg/configs/* /data/misc/radio/modem_config
        fi
    elif [ "$product_name" = "cv3_vzw" ] || [ "$product_name" = "cv1_vzw" ]; then
        `setprop persist.radio.sw_mbn_loaded 0`
        #`setprop persist.radio.hw_mbn_loaded 0`

        mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na
        chmod 770 /data/misc/radio/modem_config/mcfg_sw/generic/na

        cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_hw /data/misc/radio/modem_config
        cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/common /data/misc/radio/modem_config/mcfg_sw/generic

        if [ "$product_name" = "cv3_vzw" ]; then
            for value in "${mcfg_group_9[@]}"; do
                if [ ! -d /data/misc/radio/modem_config/mcfg_sw/generic/na/$value ]; then
                    mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na/$value
                fi
                cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/na/"$value"/* /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value"
            done
        elif [ "$product_name" = "cv1_vzw" ]; then
            for value in "${mcfg_group_9[@]}"; do
                if [ ! -d /data/misc/radio/modem_config/mcfg_sw/generic/na/$value ]; then
                    mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na/$value
                fi
                cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/na/"$value"/* /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value"
            done
        else
            cp -r /firmware/image/modem_pr/mcfg/configs/* /data/misc/radio/modem_config
        fi
    elif [ "$product_name" = "lv517_trf_us" ]||[ "$product_name" = "sf317_trf_us" ] || [ "$product_name" = "lv7_trf_us" ] || [ "$product_name" = "lv9_nao_us" ] || [ "$product_name" = "mhn_lao_com" ] || [ "$product_name" = "mhn_global_ca" ] || [ "$product_name" = "cv1_mpcs_us" ] || [ "$product_name" = "cv1_tmo_us" ]; then
        `setprop persist.radio.sw_mbn_loaded 0`
        #`setprop persist.radio.hw_mbn_loaded 0`
        cp -r /firmware/image/modem_pr/mcfg/configs/* /data/misc/radio/modem_config
    fi
    chown -hR radio.radio /data/misc/radio/modem_config
    cp /firmware/verinfo/ver_info.txt /data/misc/radio/ver_info.txt
    chown radio.radio /data/misc/radio/ver_info.txt
else
    #check version
    if [ ! -f /firmware/verinfo/ver_info.txt -o "$prev_version_info" != "$cur_version_info" ]; then
        rm -rf /data/misc/radio/modem_config
        mkdir /data/misc/radio/modem_config
        chmod 770 /data/misc/radio/modem_config
        cp -r /firmware/image/modem_pr/mcfg/configs/* /data/misc/radio/modem_config
        chown -hR radio.radio /data/misc/radio/modem_config
        cp /firmware/verinfo/ver_info.txt /data/misc/radio/ver_info.txt
        chown radio.radio /data/misc/radio/ver_info.txt
    fi
    touch /data/misc/radio/modem_config/mcfg_sw/generic/route9
fi

if [ "$build_product" = "sf340n" ] || [ "$build_product" = "lv9" ] || [ "$build_product" = "lv517" ] || [ "$build_product" = "mhn" ] || [ "$build_product" = "cv1" ] || [ "$build_product" = "cv3" ]; then
    chown -h radio.system /data/misc/radio/modem_config
    chmod -R 770 /data/misc/radio/modem_config/mcfg_sw
    chown -hR radio.system /data/misc/radio/modem_config/mcfg_sw
fi

cp /firmware/image/modem_pr/mbn_ota.txt /data/misc/radio/modem_config
chown radio.radio /data/misc/radio/modem_config/mbn_ota.txt
echo 1 > /data/misc/radio/copy_complete

#check build variant for printk logging
#current default minimum boot-time-default
buildvariant=`getprop ro.build.type`
case "$buildvariant" in
    "userdebug" | "eng")
        #set default loglevel to KERN_INFO
        echo "6 6 1 7" > /proc/sys/kernel/printk
        ;;
    *)
        #set default loglevel to KERN_WARNING
        echo "4 4 1 4" > /proc/sys/kernel/printk
        ;;
esac
