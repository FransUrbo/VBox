#!/bin/sh

VBoxManage -nologo list --long vms | \
    grep '^Name: ' | \
    sed 's/^Name:            //' | \
    egrep -vi '^ |share' | \
    sort | \
    while read vm; do
	VBoxManage -nologo showvminfo "$vm" | grep iqn | \
	    while read ctrl; do
		if echo "$ctrl" | grep -q ^SATA; then
		    dev=`echo "$ctrl" | sed 's@.* (\([0-9]\),.*@\1@'`
		    lun=`echo "$ctrl" | sed 's@.*, \([0-9]\)).*@\1@'`
		    echo "$vm: $dev/$lun"
		    VBoxManage setextradata "$vm" "VBoxInternal/Devices/ahci/$dev/LUN#$lun/Config/IgnoreFlush" 0
		fi
	    done
    done
