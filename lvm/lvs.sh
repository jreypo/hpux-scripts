#!/sbin/sh
#
# lvs.sh - script to emulate the Linux LVM command lvs in HP-UX 11iv3
#
# (C) 2010 - Juan Manuel Rey (juanmanuel.reyportal@gmail.com)
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
 
version="v0.1 2010/02/15"
 
function usage
{
        echo
        echo "LVS for HP-UX ${version}"
        echo
        echo "Usage: lvs [-v vg_name]"
        echo
                exit 1
}
 
if [ ! "$(uname -r)" = "B.11.31" ]
then
        echo "LVS for HP-UX only works on HP-UX 11iv3"
        exit 1
fi
 
if [ "$1" ]
then
        case "$1" in
        -v) shift; [  "$1" = "" ] && usage || vg_name=${1};;
        *)  usage;;
        esac
fi
 
lv_list="vgdisplay -vF | grep lv_name"
[ ! "${vg_name}" = "" ] && lv_list="vgdisplay -vF ${vg_name} | grep lv_name"
 
printf "%-30s %-12s %-17s %-6s %-10s %-7s %-8s %-8s %-7s\n" LV VG Status LVSize Permissions Mirrors Stripes Allocation
 
eval ${lv_list} | while IFS=":" read lvlist
do
        echo ${lvlist} | cut -d ":" -f 1 | cut -d "/" -f 4 | read lv_name
        echo ${lvlist} | cut -d ":" -f 1 | cut -d "=" -f 2 | read lv_long_name
        lvdisplay -F ${lv_long_name} | cut -d ":" -f 2 | cut -d "/" -f 3 | read vg_name
        lvdisplay -F ${lv_long_name} | cut -d ":" -f 4 | cut -d "=" -f 2 | read lv_status
        lvdisplay -F ${lv_long_name} | cut -d ":" -f 3 | cut -d "=" -f 2 | read lv_perm
        lvdisplay -F ${lv_long_name} | cut -d ":" -f 5 | cut -d "=" -f 2 | read lv_mirrors
        lvdisplay -F ${lv_long_name} | cut -d ":" -f 11 | cut -d "=" -f 2 | read lv_stripes
        lvdisplay -F ${lv_long_name} | cut -d ":" -f 14 | cut -d "=" -f 2 | read lv_allocation
        lvdisplay -F ${lv_long_name} | cut -d ":" -f 8 | cut -d "=" -f 2 | read size_megs
        lv_size="`/usr/bin/expr $size_megs / 1024`G"
 
        printf "%-30s %-12s %-17s %-6s %-17s %-7s %-2s %-5s\n" "${lv_name}" "${vg_name}" "${lv_status}" "${lv_size}" "${lv_perm}" "${lv_mirrors}" "${lv_stripes}" "${lv_allocation}"
done