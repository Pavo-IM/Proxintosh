#!/bin/bash
# Add the pve-no-subscription and pvetest to source list
echo "Updating apt Source list."
rm -rf /etc/apt/sources.list
touch /etc/apt/sources.list
cat <<EOF >> /etc/apt/sources.list
deb http://ftp.debian.org/debian buster main contrib
deb http://ftp.debian.org/debian buster-updates main contrib

# PVE pve-no-subscription repository provided by proxmox.com,
# NOT recommended for production use
deb http://download.proxmox.com/debian/pve buster pve-no-subscription
deb http://download.proxmox.com/debian/pve buster pvetest

# security updates
deb http://security.debian.org/debian-security buster/updates main contrib
EOF
sleep 1

echo "Commenting out pve-enterprise source list."
sed -i 's/deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
sleep 1

echo "Updating apt package list."
apt update
sleep 1

echo "Installing kernel building required packages."
apt install build-essential python3-pip dh-make python3-sphinx lintian asciidoc-base bison flex libdw-dev libelf-dev libiberty-dev libnuma-dev libslang2-dev libssl-dev lz4 xmlto zlib1g-dev git -y
sleep 1

echo "Cloning the PVE-Kernel repo."
cd /root
git clone git://git.proxmox.com/git/pve-kernel.git
sleep 1

echo "Creating the noamdflr for X570 patch file."
cd pve-kernel
touch patches/kernel/0007-noamdflr.patch
cat <<EOF >> patches/kernel/0007-noamdflr-x570.patch
diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 308f744393eb..9806bff34b9b 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -4999,6 +4999,9 @@ static void quirk_intel_no_flr(struct pci_dev *dev)
 DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x1502, quirk_intel_no_flr);
 DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x1503, quirk_intel_no_flr);
 
+DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_AMD, 0x149c, quirk_intel_no_flr);
+DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_AMD, 0x1487, quirk_intel_no_flr);
+
 static void quirk_no_ext_tags(struct pci_dev *pdev)
 {
     struct pci_host_bridge *bridge = pci_find_host_bridge(pdev->bus);
-- 
2.24.1
EOF
sleep 1

echo "Creating the noamdflr for TRX40 patch file."
touch patches/kernel/0008-noamdflr.patch
cat <<EOF >> patches/kernel/0008-noamdflr-trx40.patch
diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 308f744393eb..9806bff34b9b 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -4999,6 +4999,9 @@ static void quirk_intel_no_flr(struct pci_dev *dev)
 DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x1502, quirk_intel_no_flr);
 DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x1503, quirk_intel_no_flr);
 
+DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_AMD, 0x148c, quirk_intel_no_flr);
+DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_AMD, 0x1487, quirk_intel_no_flr);
+
 static void quirk_no_ext_tags(struct pci_dev *pdev)
 {
     struct pci_host_bridge *bridge = pci_find_host_bridge(pdev->bus);
-- 
2.24.1
EOF
sleep 1

echo "Compiling the kernel with patches applied."
apt remove pve-headers-5.4.34-1-pve -y
make
sleep 1

echo "Installing compiled patched kernel."
dpkg -i *.deb
sleep 1

echo "Complete please reboot!"