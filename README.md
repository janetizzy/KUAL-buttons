# OVERVIEW

This file system structure supports the Kindle Unified Application Launcher (KUAL, pronounced: cool).

KUAL works on all e-ink Kindle models except for the original model (K1) and some very early firmware Kindle 2's (The latter can be easily updated)

The root of the KUAL menu extensions (extensions) is on that part of the Kindle's file system which is exported as the USB storage area to the user.
It appears at the top level of visible storage as: /extensions
The KUAL menu extensions sub-tree is also accessible internally as part of the Linux file system tree as: /mnt/us/extensions

The root of the additional system's structure (esys) is also on that part of the Kindle's file system which is exported as the USB storage area to the user.
It also appears at the top level of visible storage as: /esys
The additional system's structure is also accessible internally as part of the Linux file system tree as: /mnt/us/esys

The notation used here of: **'\*/'** indicates either the internal path or the external USB storage path.

This file system structure is a simplification of the Linux FHS.

Overview at: http://www.thegeekstuff.com/2010/09/linux-file-system-structure/

Reference at: http://www.pathname.com/fhs/

The simplifications here for the system extensions (\*/esys/\*) are:

/bin, /sbin, /usr/bin, /usr/sbin, /usr/local/bin, /usr/local/sbin are all consolidated as: \*/esys/bin

/lib, /usr/lib, /usr/local/lib are all consolidated as: \*/esys/lib

Over time, the e-ink Kindles have used different Freescale SoC devices.

Our \*/esys/bin and \*/esys/lib reflect these differences.

The \*/esys/bin and \*/esys/lib are the generic directory levels.

The \*/esys/bin/\`uname -m\` and \*/esys/lib/\`uname -m\` are files specific to either the armv6l or armv7l core used by the SoC.

Over time, the e-ink Kindles have used different Linux kernel versions.

This is reflected in the path to the loadable kernel modules as: \*/esys/lib/modules/\`uname -r\`

This file structure plan presumes a "read-only" \*/esys/etc directory used as a system wide, resource directory. 
It has sub-directories specific to the system resources provided.
As use here, "read-only" means only changed by configuration additions or alterations.

For run-time generated files, this file system structure supports three distinctions of \*/esys/var

\*/esys/var/tmp - implemented in tmpfs - does not survive re-boots.

\*/esys/var/run - implemented in tmpfs - does not survive re-boots.

\*/esys/var/log (and other sub-directories of \*/esys/var) are persistent.

Copyrights: Copyright \(c\) is held by the original author unless otherwise stated in the author's contribution.

License: All material here is licensed under the MIT License unless otherwise stated in the author's contribution. See: http://opensource.org/licenses/MIT

Contact the team if you have any ideas for the project
