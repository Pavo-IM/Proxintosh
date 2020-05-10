# 🖥 Proxintosh
MacOS Catalina `10.15.5 beta 3` on Proxmox VE 6.1 on AMD 3950X system with on-board USB Controllers, Radeon VII, 2x NVMe drives passed through to MacOS.

## System Specs
[**CPU**] AMD Ryzen 9 3950X 3.5 GHz 16-Core Processor  
[**CPU Cooler**] Thermaltake Floe Riing RGB 360 TT Premium Edition 42.34 CFM Liquid CPU Cooler  
[**Motherboard**] MSI MPG X570 GAMING EDGE WIFI ATX AM4 Motherboard  
[**Memory**] Corsair Vengeance RGB Pro 64 GB (4 x 16 GB) DDR4-3200 Memory  
[**Storage**] Samsung 960 Pro 1 TB M.2-2280 NVME Solid State Drive  
[**Storage**] Samsung PM951 1 TB M.2-2280 NVME Solid State Drive  
[**Storage**] Corsair MP600 Force Series Gen4 1 TB M.2-2280 NVME Solid State Drive   
[**Video Card**] Sapphire Radeon VII 16 GB Video Card  
[**Case**] Thermaltake View 71 TG RGB ATX Full Tower Case  
[**Power Supply**] EVGA SuperNOVA Classified 1500 W 80+ Gold Certified Fully Modular ATX Power Supply  
[**Monitor**] Dell D2719HGF 27.0" 1920x1080 144 Hz Monitor  
[**Monitor**] Dell D2719HGF 27.0" 1920x1080 144 Hz Monitor  

## What Works....
- NVMe PCIe passthrough
- Single GPU passthrough
- Host CPU passthrough with minimum MacOS kernel patching
- PCIe USB card passthrough
- Major increase in graphic performance vs bare metal install
- Wifi/BT PCIe passthrough
- PCIe Ethernet NIC card passthrough

## What does not work (Works with patched kernel in [patches](patches) folder)
- On-board Realtek Audio passthrough (Works with the patched kernel)
- On-board USB Controllers passthrough (Works with the patched kernel)

**Disclaimer**  
Results may vary on your system. The results you see in this repo are based of above system specs. It may be different with different system specs.  
The patches in this repo are only needed if you are trying to passthrough the on-board USB Controller or on-board Realtek audio device.

## Instructions
1. Download [Proxmox VE 6.1 ISO](https://www.proxmox.com/en/downloads?task=callelement&format=raw&item_id=499&element=f85c494b-2b32-4109-b8c1-083cca2b7db6&method=download&args[0]=2ceb9af3734861c9c28a59daa85d86e3) and make a bootable USB drive.
1. Install Proxmox 6.1 on a separate small drive.
1. Boot the UEFI version of Proxmox VE from the drive you just installed it on. There will be the UEFI version and the normal proxmox version, make sure you set your first bootable drive in your BIOS settings to be the UEFI version of Proxmox.
1. Once you have booted and see the login screen, login as `root` and use the password you created during install.
1. Do the following commands in order to download this git repo and copy the pre-setup files needed:

```
apt-get update
apt-get install git vim -y
git clone https://github.com/Pavo-IM/Proxintosh
cp Proxintosh/etc/modprobe.d/*.conf /etc/modprobe.d/
cp Proxintosh/etc/modules /etc/modules
cp Proxintosh/etc/default/grub /etc/default/
cp Proxintosh/etc/pve/qemu-server/vm.conf /etc/pve/qemu-server/100.conf
cd Proxintosh/patches
dpkg -i *.deb
```

Now we need to start looking for information to edit [vfio.conf](etc/modprobe.d/vfio.conf) to match your system and IOMMU groups.
```
lspci
```
You should see an output like below:
```
00:00.0 Host bridge: Advanced Micro Devices, Inc. [AMD] Starship/Matisse Root Complex
00:14.0 SMBus: Advanced Micro Devices, Inc. [AMD] FCH SMBus Controller (rev 61)
00:14.3 ISA bridge: Advanced Micro Devices, Inc. [AMD] FCH LPC Bridge (rev 51)
01:00.0 Non-Volatile memory controller: Phison Electronics Corporation Device 5016 (rev 01)
22:00.0 Non-Volatile memory controller: Samsung Electronics Co Ltd NVMe SSD Controller SM961/PM961
23:00.0 Non-Volatile memory controller: Samsung Electronics Co Ltd NVMe SSD Controller (rev 01)
25:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 06)
26:00.0 SATA controller: ASMedia Technology Inc. ASM1062 Serial ATA Controller (rev 02)
27:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 15)
29:00.0 Network controller: Broadcom Limited BCM4352 802.11ac Wireless Network Adapter (rev 03)
2a:00.0 Non-Essential Instrumentation [1300]: Advanced Micro Devices, Inc. [AMD] Starship/Matisse Reserved SPP
2a:00.1 USB controller: Advanced Micro Devices, Inc. [AMD] Matisse USB 3.0 Host Controller
2a:00.3 USB controller: Advanced Micro Devices, Inc. [AMD] Matisse USB 3.0 Host Controller
2b:00.0 SATA controller: Advanced Micro Devices, Inc. [AMD] FCH SATA Controller [AHCI mode] (rev 51)
2c:00.0 SATA controller: Advanced Micro Devices, Inc. [AMD] FCH SATA Controller [AHCI mode] (rev 51)
2d:00.0 PCI bridge: Advanced Micro Devices, Inc. [AMD/ATI] Device 14a0 (rev c1)
2e:00.0 PCI bridge: Advanced Micro Devices, Inc. [AMD/ATI] Device 14a1
2f:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Vega 20 [Radeon VII] (rev c1)
2f:00.1 Audio device: Advanced Micro Devices, Inc. [AMD/ATI] Vega 20 HDMI Audio [Radeon VII]
31:00.3 USB controller: Advanced Micro Devices, Inc. [AMD] Matisse USB 3.0 Host Controller
31:00.4 Audio device: Advanced Micro Devices, Inc. [AMD] Starship/Matisse HD Audio Controller
...
```
This is just an example I have cut out some of the output to save the length of this README. Highlight and copy what devices you want to passthrough from the host OS to the guest OS and save that in a textfile for later use.

For example I am passing through my:
```
31:00.3 USB controller: Advanced Micro Devices, Inc. [AMD] Matisse USB 3.0 Host Controller
2f:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Vega 20 [Radeon VII] (rev c1)
```
...and a few other devices, but this should give you a general idea of how to go about passing through all the devices you have selected.  

Next you need to get the device-id of those devices by using the `lspci -n -s xx:xx.x` command. The `xx:xx.x` is from the device address that gets assigned by the kernel. From the example above the USB Controller is `31:00.0`, so the command would be `lspci -n -s 31:00.0`. Example output of that command looks like...

```
31:00.3 0c03: 1022:149c
```
Make note of each device-id that you are wanting to passthrough to the guest OS. Once you have all the device-ids you want to passthrough to the guest OS, you use your favorite editor application, Vim is mine and edit the [vfio.conf](etc/modprobe.d/vfio.conf) located in `/etc/modprobe.d/vfio.conf`.

After you have edited the [vfio.conf](etc/modprobe.d/vfio.conf) file, you need to do the following commands...

```
update-initramfs -u -k all
update-grub
pve-efiboot-tool refresh
reboot
```
After the system reboots and you are back into the system, you need to open your web browers and go to the IP address that you setup during the install process of Proxmox VE. Login and on the left handside expand the `pve` tree. 

Locate the 100 VM that is already created for you, by copying the [vm.conf](etc/pve/qemu-server/vm.conf) earlier.

Delete the `EFI Disk` and recreate a new one, this is needed because your fresh setup didn't have a local disk made for the EFI disk.

Now click on each `hostpci` device and change them to the devices your have selected earlier.

Now you should be able to boot the VM without issues.

### Credits
Thanks to [Fabiosun](https://github.com/fabiosun) for his guidance on the starting of my adventures into the virtualization of MacOS using Proxmox VE using the guide he made at [macOS86.it](https://www.macos86.it/topic/2509-guide-trx40-osx-bare-metal-proxmox-setup61-3/)