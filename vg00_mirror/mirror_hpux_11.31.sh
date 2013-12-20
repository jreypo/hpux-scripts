#!/sbin/sh
#
# vg00 mirror script for HP-UX 11.31 with the new agile view
#
# (C) 2008 - Juan Manuel Rey (juanmanuel.reyportal@gmail.com)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
#

# If the rootvg extends across two disks, both of them must be declared in the
# following variables.

set -x
DISK1=
DISK2=

# Partition table creation for the mirror boot disk

touch /tmp/partitionfile
echo 3 > /tmp/partitionfile
echo "EFI 500MB" >> /tmp/partitionfile
echo HPUX 100% >> /tmp/partitionfile
echo "HPSP 400MB" >> /tmp/partitionfile
echo "EOF" >> /tmp/partitionfile

idisk -wqf /tmp/partitionfile /dev/rdisk/$DISK1
insf -eC disk
mkboot -e -l /dev/rdisk/$DISK1

echo "boot vmunix -lq" > /tmp/AUTO.lq
efi_cp -d /dev/rdisk/"$DISK1"_p1 /tmp/AUTO.lq /EFI/HPUX/AUTO

# Since now if there is only one disk in the rootvg all $DISK2 entries must be commented
# or eliminated

pvcreate -fB /dev/rdisk/"$DISK1"_p2
pvcreate -f /dev/rdisk/"$DISK2"
vgextend rootvg /dev/disk/"$DISK1"_p2 /dev/rdisk/"$DISK2"

for i in $(vgdisplay -v vg00 | grep "LV Name" | awk '{ print $3 };')
do
lvextend -m $i /dev/disk/"$DISK1"_p2 /dev/disk/$DISK2
done

DISCO=/dev/disk/"$DISK1"_p2
echo "l $DISCO" >> /etc/bootconf

lvlnboot -r /dev/rootvg/lvol3 /dev/rootvg
lvlnboot -b /dev/rootvg/lvol1 /dev/rootvg
lvlnboot -s /dev/rootvg/lvol2 /dev/rootvg
lvlnboot -d /dev/rootvg/lvol2 /dev/rootvg

setboot -b on 
setboot -a /dev/rdisk/"$DISK1"
setboot -h /dev/rdisk/"$DISK1"
