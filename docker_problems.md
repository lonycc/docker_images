> WARNING: devicemapper: usage of loopback devices is strongly discouraged for production use.
         Use `--storage-opt dm.thinpooldev` to specify a custom block storage device.

`http://stackoverflow.com/questions/31620825/warning-of-usage-of-loopback-devices-is-strongly-discouraged-for-production-use`

> WARNING: overlay2: the backing xfs filesystem is formatted without d_type support, which leads to incorrect behavior.
         Reformat the filesystem with ftype=1 to enable d_type support.
         Running without d_type support will not be supported in future releases.

`mkfs.xfs -n ftype=1 /path/to/your/device`

`sudo xfs_info /`

> WARNING: bridge-nf-call-iptables is disabled

> WARNING: bridge-nf-call-ip6tables is disabled

`vim /etc/sysctl.conf`

`net.bridge.bridge-nf-call-ip6tables = 1`

`net.bridge.bridge-nf-call-iptables = 1`

`net.bridge.bridge-nf-call-arptables = 1`
