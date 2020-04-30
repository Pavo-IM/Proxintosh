# Proxintosh
MacOS Catalina `10.15.5 beta 3` on Proxmox VE 6.1 on AMD 3950X system with on-board USB Controllers, Radeon VII, 2x NVMe drives passed through to MacOS.

> [!IMPORTANT]  
> This README is a work in progress and is not finalized. Please do not use these instructions until this warning has been removed.

# System Specs
[CPU] `AMD Ryzen 9 3950X 3.5 GHz 16-Core Processor`  
[CPU Cooler] `Thermaltake Floe Riing RGB 360 TT Premium Edition 42.34 CFM Liquid CPU Cooler`  
[Motherboard] `MSI MPG X570 GAMING EDGE WIFI ATX AM4 Motherboard`  
[Memory] `Corsair Vengeance RGB Pro 64 GB (4 x 16 GB) DDR4-3200 Memory`  
[Storage] `Samsung 960 Pro 1 TB M.2-2280 NVME Solid State Drive`  
[Storage] `Samsung PM951 1 TB M.2-2280 NVME Solid State Drive`  
[Storage] `Corsair MP600 Force Series Gen4 1 TB M.2-2280 NVME Solid State Drive`   
[Video Card] `Sapphire Radeon VII 16 GB Video Card`  
[Case] `Thermaltake View 71 TG RGB ATX Full Tower Case`  
[Power Supply] `EVGA SuperNOVA Classified 1500 W 80+ Gold Certified Fully Modular ATX Power Supply`  
[Monitor] `Dell D2719HGF 27.0" 1920x1080 144 Hz Monitor`  
[Monitor] `Dell D2719HGF 27.0" 1920x1080 144 Hz Monitor`  


> [!Disclaimer]  
Results may vary on your system. The results you see in this repo are based of above system specs. It mayb be different with different system specs.

# Instructions
- Download [Proxmox VE 6.1 ISO](https://www.proxmox.com/en/downloads?task=callelement&format=raw&item_id=499&element=f85c494b-2b32-4109-b8c1-083cca2b7db6&method=download&args[0]=2ceb9af3734861c9c28a59daa85d86e3) and make a bootable USB drive.
- Install Proxmox 6.1 on a separate small drive.
- Boot the UEFI version of Proxmox VE from the drive you just installed it on. There will be the UEFI version and the normal proxmox version, make sure you set your first bootable drive in your BIOS settings to be the UEFI version of Proxmox.
- Once you have booted and see the login screen, login as `root` and use the password you created during install.
## Do the following commands in order to download this git repo and copy the pre-setup files needed:
    apt-get update
    apt-get install git vim -y
    git clone https://github.com/Pavo-IM/Proxintosh
    cp Proxintosh/etc/modprobe.d/*.conf /etc/modprobe.d/
    cp Proxintosh/etc/modules /etc/modules
    cp Proxintosh/etc/default/grub /etc/default/
    cd Proxintosh/patches
    dpkg -i *.deb
