# Inherit framework first
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from cv1 device
$(call inherit-product, device/lge/cv1/device.mk)

# Inherit some common LineageOS stuff.
$(call inherit-product, vendor/cm/config/common_full_phone.mk)

# Set those variables here to overwrite the inherited values.
BOARD_VENDOR := lge
PRODUCT_DEVICE := cv1
PRODUCT_NAME := rr_cv1
PRODUCT_BRAND := lge
PRODUCT_MODEL := LM-X210(G)
PRODUCT_MANUFACTURER := LGE

# Overlays (inherit after vendor/cm to ensure we override it)
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

PRODUCT_GMS_CLIENTID_BASE := android-lge

PRODUCT_BUILD_PROP_OVERRIDES += \
    BUILD_FINGERPRINT="lge/cv1_lao_com/cv1:7.1.2/N2G47H/180391525b535:user/release-keys" \
    PRIVATE_BUILD_DESC="lge/cv1_lao_com/cv1:7.1.2/N2G47H/173411504b0cf:user/release-keys"
