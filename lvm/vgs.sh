#!/sbin/sh
#
# vgs.sh - script to emulate the Linux LVM command vgs in HP-UX 11iv3
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
        echo "VGS for HP-UX ${version}"
        echo
        echo "Usage: vgs [-v vg_name]"
        echo
        exit 1
}
 
if [ ! "$(uname -r)" = "B.11.31" ]
then
        echo "VGS for HP-UX only works on HP-UX 11iv3"
        exit 1
fi
 
if [ "$1" ]
then
        case "$1" in
        -v) shift; [  "$1" = "" ] && usage || vg_name=${1};;
        *)  usage;;
        esac
fi
 
vg_display="vgdisplay -F"
[ ! "${vg_name}" = "" ] && vg_display="vgdisplay -F ${vg_name}"
 
printf "%-10s %-5s %-5s %-20s %-8s %-6s %-5s\n" VG PVs LVs Status Version VGSize Free
 
eval ${vg_display} | while IFS=":" read vgdisplay
do
        echo ${vgdisplay} | cut -d ":" -f 2 | cut -d "=" -f 2 | read status
        if [ "${status}" = "deactivated" ]
        then
                status=deactivated
                vg_size=""
                vg_free=""
        else
                echo ${vgdisplay} | cut -d ":" -f 3 | cut -d "=" -f 2 | read status
                echo ${vgdisplay} | cut -d ":" -f 13 | cut -d "=" -f 2 | read total_pe
                echo ${vgdisplay} | cut -d ":" -f 12 | cut -d "=" -f 2 | read pe_size
                echo ${vgdisplay} | cut -d ":" -f 15 | cut -d "=" -f 2 | read free_pe
                vg_size="`/usr/bin/expr $total_pe \* $pe_size / 1024`G"
                vg_free="`/usr/bin/expr $free_pe \* $pe_size / 1024`G"
        fi
        echo ${vgdisplay} | cut -d ":" -f 1 | cut -d "=" -f 2 | cut -d "/" -f 3 | read vg_name
        echo ${vgdisplay} | cut -d ":" -f 8 | cut -d "=" -f 2 | read pvs
        echo ${vgdisplay} | cut -d ":" -f 5 | cut -d "=" -f 2 | read lvs
        echo ${vgdisplay} | cut -d ":" -f 19 | cut -d "=" -f 2 | read version
        printf "%-10s %-5s %-5s %-20s %-8s %-6s %-5s\n" "${vg_name}" "${pvs}" "${lvs}" "${status}" "${version}" "${vg_size}" "${vg_free}"
done