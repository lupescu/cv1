$(call inherit-product, device/lge/cv1/full_cv1.mk)

# Inherit some common Resurrection Remix stuff.
$(call inherit-product, vendor/rr/config/common_full_phone.mk)

PRODUCT_NAME := rr_cv1

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_DEVICE="cv1" \
    PRODUCT_NAME="cv1_mpcs_us" \
    BUILD_FINGERPRINT="lge/cv1_rr/cv1:8.1/LMX210MA.81RRC/:8100518user/release-keys" \
    PRIVATE_BUILD_DESC="cv1_rr-user 8.1 LMX210MA.81RRC 8100518 release-key