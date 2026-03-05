## Task 1 — VirtualBox Installation

Host operating system: macOS Tahoe 26.3  
VirtualBox version: 7.2.6  
Installation Issues: не было проблем


## Task 2 — Ubuntu VM and System Analysis

### VM Configuration
RAM: 4GB  
Storage: 25GB  
CPU Cores: 2  

---

## CPU Information

Tool: lscpu, /proc/cpuinfo, nproc  
Command:
lscpu  
grep -m1 'model name' /proc/cpuinfo  
nproc  

Output:
```
Architecture:                 aarch64
CPU op-mode(s):               64-bit
Byte Order:                   Little Endian
CPU(s):                       2
On-line CPU(s) list:          0,1
Vendor ID:                    Apple
Model name:                   -
Model:                        0
Thread(s) per core:           1
Core(s) per cluster:          2
Socket(s):                    -
Cluster(s):                   1
Stepping:                     0x0
BogoMIPS:                     48.00
Flags:                        fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm jscvt fcma lrcpc dcpop sha3 asimddp sha512 asimdfhm dit uscat ilrcpc flagm ssbs sb paca pacg dcpodp flagm2 frint bf16
NUMA node(s):                 1
NUMA node0 CPU(s):            0,1
Gather data sampling:         Not affected
Ghostwrite:                   Not affected
Itlb multihit:                Not affected
L1tf:                         Not affected
Mds:                          Not affected
Meltdown:                     Not affected
Mmio stale data:              Not affected
Old microcode:                Not affected
Reg file data sampling:       Not affected
Retbleed:                     Not affected
Spec rstack overflow:         Not affected
Spec store bypass:            Mitigation; Speculative Store Bypass disabled via prctl
Spectre v1:                   Mitigation; __user pointer sanitization
Spectre v2:                   Mitigation; CSV2, but not BHB
Srbds:                        Not affected
Tsx async abort:              Not affected

grep -m1 'model name' /proc/cpuinfo
(no output)

nproc
2
```

---

## Memory Information

Tool: `free -h, /proc/meminfo`

Command:

`free -h`

`grep -E 'MemTotal|MemAvailable' /proc/meminfo`

Output:

```
               total        used        free      shared  buff/cache   available
Mem:           3.3Gi       1.7Gi        87Mi        80Mi       1.8Gi       1.6Gi
Swap:            0B          0B          0B

MemTotal:       3462372 kB
MemAvailable:   1726000 kB
```


---

## Network Information


Tool: `ip`

Command:

`ip -br a`
`ip route`

Output:

```
lo               UNKNOWN        127.0.0.1/8 ::1/128
enp0s8           UP             10.0.2.15/24 fd17:625c:f037:2:a00:27ff:feb0:dcf0/64 fe80::a00:27ff:feb0:dcf0/64

default via 10.0.2.2 dev enp0s8 proto dhcp src 10.0.2.15 metric 100
10.0.2.0/24 dev enp0s8 proto kernel scope link src 10.0.2.15 metric 100
```

---

## Storage Information


Tool: `df, lsblk`

Command:

`df -hT`
`lsblk -f`


Output:

```
df -hT
(команда в сессии была введена как df -ht и вернула ошибку)

df: option requires an argument -- 't'
Try 'df --help' for more information.

lsblk -f
NAME   FSTYPE   FSVER LABEL                         UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
loop0  squashfs 4.0                                                                          0   100% /snap/bare/5
loop1  squashfs 4.0                                                                          0   100% /snap/core22/2134
loop2  squashfs 4.0                                                                          0   100% /snap/firefox/6961
loop3  squashfs 4.0                                                                          0   100% /snap/desktop-security-center/60
loop4  squashfs 4.0                                                                          0   100% /snap/gtk-common-themes/1535
loop5  squashfs 4.0                                                                          0   100% /snap/prompting-client/105
loop6  squashfs 4.0                                                                          0   100% /snap/gnome-42-2204/228
loop7  squashfs 4.0                                                                          0   100% /snap/snap-store/1301
loop8  squashfs 4.0                                                                          0   100% /snap/snapd-desktop-integration/316
loop9  squashfs 4.0                                                                          0   100% /snap/snapd/25205
sda
├─sda1 vfat     FAT32                                357C-7AD4                               1G    1% /boot/efi
└─sda2 ext4     1.0                                  6f725f31-4777-44d0-854b-033102d275cb  16.1G   26% /
sr0    iso9660  Joliet Extension Ubuntu 25.10 arm64 2026-03-05-20-20-03-77                  0   100% /media/vboxuser/Ubuntu 25.10 arm64
```


---

## Operating System Information


Tool: `/etc/os-release, uname`

Command:

`cat /etc/os-release`
`uname -a`



Output:

```
PRETTY_NAME="Ubuntu 25.10"
NAME="Ubuntu"
VERSION_ID="25.10"
VERSION="25.10 (Questing Quokka)"
VERSION_CODENAME=questing
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=questing
LOGO=ubuntu-logo

Linux laba5 6.17.0-14-generic #14-Ubuntu SMP PREEMPT_DYNAMIC Fri Jan 9 16:29:17 UTC 2026 aarch64 GNU/Linux
```

---


## Virtualization Detection

Tool: systemd-detect-virt, hostnamectl
Command:
systemd-detect-virt
hostnamectl




Output:

```
none

 Static hostname: laba5
       Icon name: computer
      Machine ID: 4793bc6817304b2eb81657150578b550
         Boot ID: fb12f44884f5412da41231a792f6dc8c
  Operating System: Ubuntu 25.10
            Kernel: Linux 6.17.0-14-generic
      Architecture: arm64

```

---

## Вывод

The most useful tools were lscpu and hostnamectl because they provided structured and easy-to-read system information.
The ip command was useful for identifying network interfaces and IP addresses
