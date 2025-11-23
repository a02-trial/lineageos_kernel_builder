### from LineageOS/android/default.xml ###
export lineageos_branch="lineage-21.0"
export aosp_tag="android-14.0.0_r67"
export aosp_tag2="android-14.0.0_r0.76"

### from LineageOS/android/snippets/lineage.xml ###
export clang_version="r416183b"
export clang_branch="lineage-20.0"
export gcc_arm_version="4.9"
export gcc_arm_branch="lineage-19.1"

### We need these to build the Kernel ###
export download_clang="true"
export download_clang_host_linux_x86="true"
export download_gcc_arm="true"
export download_tools_lineage="true"
export download_build_tools="true"
export download_misc="false"
export download_kernel_build_tools="true"

### Configuration options ###
export integrate_kernelsu="true"
export enable_anykernel3_zip="true" # Create a AnyKernel3 zip containing the built Kernel
export is_linux_4_9="true" # Linux 4.9 ONLY!!! Patch security/selinux/hooks.c so that KernelSU modules work
export backport_path_umount="true" # backport path_umount from Linux 5.9 to fs/namespace.c

### Kernel configuration ###
export kernel_dir="BR_kernel_a02"
export kernel_branch="kernelku"
export device_codename="a02"
export device_arch="arm"
export device_defconfig="a02_defconfig"

export kernel_build_out_prefix="out"
export kernel_cross_compile="arm-linux-androidkernel-"
export kernel_clang_triple="arm-linux-gnueabi-"
export kernel_cc="clang"
export kernel_image_name="zImage"
export kernel_image_path="${_workdir}/${kernel_dir}/${kernel_build_out_prefix}/arch/${device_arch}/boot/${kernel_image_name}"
export kernel_config_path="./arch/${device_arch}/configs/a02_defconfig"

download_kernel() {
    if [ "${shallow_clone}" = "true" ]; then
        local extra_git_arguments="--depth 1"
    else
        local extra_git_arguments=""
    fi

    if [ ! -d "${_workdir}/${kernel_dir}" ]; then
        git clone -b "$kernel_branch" \
            ${extra_git_arguments} \
            "https://github.com/a02-trial/${kernel_dir}.git" \
            "${_workdir}/${kernel_dir}"

        [ "${is_linux_4_9}" = "true" ] && patch -Np1 -d "${_workdir}/${kernel_dir}" -i "${_patchdir}/linux_4_9_selinux_hooks.patch"
        [ "${backport_path_umount}" = "true" ] && patch -Np1 -d "${_workdir}/${kernel_dir}" -i "${_patchdir}/backport_path_umount.patch"
    else
        print_info "${_workdir}/${kernel_dir} already exists, skipping..."
    fi
}

# from LineageOS/android_vendor_lineage/build/tasks/kernel.mk
# and from LineageOS/android_vendor_lineage/config/BoardConfigKernel.mk
export path_override="PATH=${_workdir}/prebuilts/clang/kernel/linux-x86/clang-r416183b/bin:${_workdir}/prebuilts/tools-lineage/linux-x86/bin:${_workdir}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin:$PATH \
    LD_LIBRARY_PATH=${_workdir}/prebuilts/clang/kernel/linux-x86/clang-r416183b/lib:$LD_LIBRARY_PATH \
    PERL5LIB=${_workdir}/prebuilts/tools-lineage/common/perl-base \
    BISON_PKGDATADIR=${_workdir}/prebuilts/build-tools/common/bison"
export kernel_make_cmd="${_workdir}/prebuilts/build-tools/linux-x86/bin/make"

### ${enable_anykernel3_zip} needs to be "true" for this to work ###
download_anykernel3() {
    download_and_handle_tarball \
        "AnyKernel3-${device_codename}" \
        "AnyKernel3-${device_codename}.tar.gz" \
        "https://github.com/th1nhhdk/AnyKernel3/archive/refs/heads/${device_codename}.tar.gz" \
        "AnyKernel3-${device_codename}"
}
