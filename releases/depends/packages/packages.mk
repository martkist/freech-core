packages:=boost openssl zlib bdb

$(host_arch)_$(host_os)_native_packages += native_b2

darwin_native_packages = native_ds_store native_mac_alias

ifneq ($(build_os),darwin)
darwin_native_packages += native_cctools native_clang native_libtapi native_libdmg-hfsplus
endif