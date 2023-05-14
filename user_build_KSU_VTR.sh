#!/bin/bash
#设置环境

# Special Clean For Huawei Kernel.
if [ -d include/config ];
then
    echo "Find config,will remove it"
	rm -rf include/config
else
	echo "No Config,good."
fi


echo " "
echo "***Setting environment...***"
# 交叉编译器路径
export PATH=$PATH:/home/coconutat/Downloads/Github/android_kernel_huawei_vtr_emui5.1/aarch64-linux-android-gcc/bin
export CROSS_COMPILE=aarch64-linux-android-

export GCC_COLORS=auto
export ARCH=arm64
if [ ! -d "out" ];
then
	mkdir out
fi

#添加或更新AK3

if [ -f tools/AnyKernel3/README.md ];
then
	cd tools/AnyKernel3
	echo " "
	echo "***Updating AnyKernel3...***"
	echo " "
	git pull upstream master
else
	echo " "
	echo "***Adding AnyKernel3...***"
	echo " "
	git submodule update --init --recursive
	cd tools/AnyKernel3
	git remote add upstream https://github.com/osm0sis/AnyKernel3
	echo "***Updating AnyKernel3...***"
	echo " "
	git pull upstream master
fi
cd ../..
echo " "

#输入盘古内核版本号
printf "Please enter EMUI5.1 Kernel version number: "
read v
echo " "
echo "Setting EXTRAVERSION"
export EV=EXTRAVERSION=_Kirin960_EMUI5.1_V$v

#构建P10内核部分
echo "***Building for P10 version...***"
make ARCH=arm64 O=out $EV P10_hi3660_mod_defconfig
# 定义编译线程数
make ARCH=arm64 O=out $EV -j256

#打包P10版内核

if [ -f out/arch/arm64/boot/Image.gz ];
then
	echo "***Packing P10 version kernel...***"
	cp out/arch/arm64/boot/Image.gz tools/AnyKernel3/Image.gz
	cp out/arch/arm64/boot/Image.gz Image.gz 
	cd tools/AnyKernel3
	zip -r9 EMUI5.1_V"$v"_P10.zip * > /dev/null
	cd ../..
	mv tools/AnyKernel3/EMUI5.1_V"$v"_P10.zip EMUI5.1_V"$v"_P10.zip
	rm -rf tools/AnyKernel3/Image.gz
	echo " "
	echo "***Sucessfully built P10 version kernel...***"
	echo " "
	exit 0
else
	echo " "
	echo "***Failed!***"
	exit 0
fi