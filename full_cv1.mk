$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

PRODUCT_NAME := full_cv1
PRODUCT_DEVICE := cv1
PRODUCT_BRAND := lge
PRODUCT_MODEL := cv1
PRODUCT_MANUFACTURER := lge

$(call inherit-product, device/lge/cv1/device.mk)
$(call inherit-product, vendor/rr/config/common_full_phone.mk)

PRODUCT_NAME := full_cv1

PRODUCT_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

PRODUCT_GMS_CLIENTID_BASE := android-lge
