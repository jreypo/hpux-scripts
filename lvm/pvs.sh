#!/sbin/sh
#
# pvs.sh - script to emulate the Linux LVM command pvs in HP-UX 11iv3
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
        echo "PVS for HP-UX ${version}"
        echo
        echo "Usage: pvs [-v vg_name]"
        echo
        exit 1
}
 
if [ ! "$(uname -r)" = "B.11.31" ]
then
        echo "PVS for HP-UX only works on HP-UX 11iv3"
        exit 1
fi
 
if [ "$1" ]
then
        case "$1" in
        -v) shift; [  "$1" = "" ] && usage || vg_name=${1};;
        *)  usage;;
        esac
fi
 
pv_list="vgdisplay -vF | grep disk"
[ ! "${vg_name}" = "" ] && pv_list="vgdisplay -vF ${vg_name} | grep disk"
 
printf "%-20s %-10s %-20s %-6s %-5s\n" PV VG Status PVSize Free
 
eval ${pv_list} | while IFS=":" read pvlist
do
        echo ${pvlist} | cut -d ":" -f 1 | cut -d "=" -f 2 | read pv_name
        pvdisplay -F ${pv_name} | cut -d ":" -f 2 | cut -d "=" -f 2 | cut -d "/" -f 3 | read vg_name
        pvdisplay -F ${pv_name} | cut -d ":" -f 3 | cut -d "=" -f 2 | read status
        pvdisplay -F ${pv_name} | cut -d ":" -f 8 | cut -d "=" -f 2 | read total_pe
        pvdisplay -F ${pv_name} | cut -d ":" -f 7 | cut -d "=" -f 2 | read pe_size
        pvdisplay -F ${pv_name} | cut -d ":" -f 9 | cut -d "=" -f 2 | read free_pe
        pv_size="`/usr/bin/expr $total_pe \* $pe_size / 1024`G"
        pv_free="`/usr/bin/expr $free_pe \* $pe_size / 1024`G"
        printf "%-20s %-10s %-20s %-6s %-5s\n" "${pv_name}" "${vg_name}" "${status}" "${pv_size}" "${pv_free}"
done