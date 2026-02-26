### Task 1 
**1.1: Boot Performance Analysis**

```
systemd-analyze
systemd-analyze blame
```
macOS не использует systemd. Производительность загрузки была проанализирована с помощью launchd и system uptime.


**Command**:
```bash
sysctl -n kern.boottime
{ sec = 1771948981, usec = 120239 } Tue Feb 24 19:03:01 2026
```
**Input**:
```
uptime
w
```
**Output**:
```
15:54  up 1 day, 20:52, 2 users, load averages: 1,73 1,87 2,10
15:54  up 1 day, 20:52, 2 users, load averages: 1,73 1,87 2,10
USER       TTY      FROM    LOGIN@  IDLE WHAT
j1         console  -      вт19    1day  -
j1         s004     -      15:46       - w
```
*	Система работает более 1 дня без перезагрузки, что указывает на стабильную работу.
*	Активны две пользовательские сессии.
* Load average находится в умеренных пределах и не указывает на перегрузку системы.
---

**1.2: Process Forensics**

* BSD-версия ps используется в macOS, поэтому GNU-опции (например, --sort) недоступны.

**Input**:
```
ps -axo pid,ppid,command,%mem,%cpu | sort -nrk4 | head -n 6
```
**Output**:
```
 5331     1 /Applications/Ch  3,0   0,0
  840     1 /System/Volumes/  2,4   1,4
 3972     1 /System/Library/  2,3   0,1
 5372     1 /System/Applicat  1,6   1,3
 2321     1 /System/Library/  1,5   6,5
 4119     1 /Applications/Co  1,3   0,2
```
Top memory-consuming process: **Google Chrome**

**Input**:
```
ps -axo pid,ppid,command,%mem,%cpu | sort -nrk5 | head -n 6
```
**Output**:
```
 5331     1 /Applications/Ch  3,1  13,8
  400     1 /System/Library/  1,1  13,6
  633     1 /System/Library/  0,3   8,1
 2321     1 /System/Library/  1,5   6,7
 5472  5374 head -n 6         0,0   0,0
  717     1 /Applications/EV  0,6   4,7
```

* Браузер Google Chrome потребляет наибольшее количество памяти и CPU.
* Системные процессы macOS стабильно распределяют нагрузку.
* Подозрительных процессов не выявлено.

---

**1.3: Service Dependencies:**
**Input**:
```
launchctl list | head -n 10
```
**Output**:
```
PID	Status	Label
-	0	com.apple.SafariHistoryServiceAgent
2439	-9	com.apple.progressd
-	0	com.apple.enhancedloggingd
2626	-9	com.apple.cloudphotod
3897	-9	com.apple.MENotificationService
623	0	com.apple.Finder
739	0	com.apple.homed
1069	0	com.apple.dataaccess.dataaccessd
-	0	com.apple.quicklook
```

*	В macOS управление сервисами осуществляется через launchd, а не systemd.
*	Сервисы представлены в виде launch agents и launch daemons.
*	Концепция targets и явных зависимостей, как в systemd, отсутствует.

---

**1.4: User Sessions:**

**Input**:
```
who -a
last -n 5
```
**Output**:
```
                 system boot  24 февр. 19:03 
j1               console      24 февр. 19:03 
j1               ttys004      26 февр. 15:46 
   .       run-level 3
j1         ttys004                         чт 26 февр. 15:46   still logged in
j1         console                         вт 24 февр. 19:03   still logged in
reboot time                                вт 24 февр. 19:03
shutdown time                              вт 24 февр. 19:02
j1         console                         вс 22 февр. 14:33 - 19:02 (2+04:29)
```

*	В системе присутствуют только локальные пользовательские сессии.
* Все входы принадлежат одному пользователю.

---

**1.5: Memory Analysis:**


**Input**:
```
vm_stat
```
**Output**:
```
Mach Virtual Memory Statistics: (page size of 16384 bytes)
Pages free:                                4696
Pages active:                            109777
Pages inactive:                          108539
Pages speculative:                          641
Pages wired down:                         94410
Pages purgeable:                          17919
Pages stored in compressor:              527910
Pages occupied by compressor:            169729
Pageins:                                4402657
Pageouts:                                226154
Swapins:                                 228927
Swapouts:                                293215
```

*	macOS использует виртуальную память с размером страницы 16 KB.
*	Используется механизм memory compression, что снижает необходимость активного swap.
*	Количество pageouts и swapouts присутствует, но не указывает на критический дефицит памяти.

---

### Task 2
**2.1: Network Path Tracing**
**Input**:
```
traceroute github.com
```
**Output**:
```
traceroute to github.com (140.82.121.3), 64 hops max
 1  * * *
 2  * * *
 3  * * *
 4  * * *
 5  * * *
 6  * * *
 7  * * *
 8  * * *
 9  * * *
10  * * *
```

---

**2.2: Packet Capture**
**Input**:
```
sudo tcpdump -c 5 -i any 'port 53' -nn
```
**Output**:
```
j1@MacBook-Pro-j DevOps-Intro % sudo tcpdump -c 5 -i any 'port 53' -nn
tcpdump: data link type PKTAP
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type PKTAP (Apple DLT_PKTAP), snapshot length 524288 bytes
17:28:37.886566 IP 172.19.0.1.62237 > 172.19.0.2.53: 55666+ Type65? api.github.com. (32)
17:28:37.886777 IP 172.19.0.1.56228 > 172.19.0.2.53: 58896+ A? api.github.com. (32)
17:28:37.886971 IP 172.19.0.1.51720 > 172.19.0.2.53: 25895+ Type65? glb-db52c2cf8be544.github.com. (47)
17:28:37.887078 IP 172.19.0.1.58715 > 172.19.0.2.53: 51731+ A? glb-db52c2cf8be544.github.com. (47)
17:28:38.060719 IP 172.19.0.2.53 > 172.19.0.1.56228: 58896 1/0/0 A 140.82.121.6 (62)
5 packets captured
3610 packets received by filter
0 packets dropped by kernel
```
*	Захвачен DNS-трафик по UDP порту 53.
*	Клиент отправляет запросы к доменам api.github.com и поддоменам GitHub.
*	Тип запроса A используется для получения IPv4-адреса.
*	Запросы Type65 соответствуют DNS-записям HTTPS (SVCB/HTTPS RR), применяемым для современных TLS-соединений.
*	DNS-сервер возвращает IPv4-адрес 140.82.121.6, что подтверждает успешное разрешение имени.
*	Потерь пакетов не зафиксировано (0 packets dropped by kernel).
* `-c 5`: Capture 5 packets
* `-i any`: Listen on all interfaces
* `port 53`: Filter for DNS traffic
* `-nn`: Don't resolve hostnames/ports (faster)

---

**2.3: Reverse DNS**
**Input**:
```
dig -x 8.8.4.4
dig -x 1.1.2.2
```
**Output**:
```
; <<>> DiG 9.10.6 <<>> -x 8.8.4.4
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 11791
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; MBZ: 0x344e, udp: 512
;; QUESTION SECTION:
;4.4.8.8.in-addr.arpa.		IN	PTR

;; ANSWER SECTION:
4.4.8.8.in-addr.arpa.	13390	IN	PTR	dns.google.

;; Query time: 67 msec
;; SERVER: 172.19.0.2#53(172.19.0.2)
;; WHEN: Thu Feb 26 17:31:54 MSK 2026
;; MSG SIZE  rcvd: 93


; <<>> DiG 9.10.6 <<>> -x 1.1.2.2
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 21207
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; MBZ: 0x0708, udp: 512
;; QUESTION SECTION:
;2.2.1.1.in-addr.arpa.		IN	PTR

;; AUTHORITY SECTION:
1.in-addr.arpa.		1800	IN	SOA	ns.apnic.net. read-txt-record-of-zone-first-dns-admin.apnic.net. 23597 7200 1800 604800 3600

;; Query time: 75 msec
;; SERVER: 172.19.0.2#53(172.19.0.2)
;; WHEN: Thu Feb 26 17:31:55 MSK 2026
;; MSG SIZE  rcvd: 160
```
* Для 8.8.4.4 обратная DNS-запись существует и успешно возвращается (dns.google.).
* Для 1.1.2.2 PTR-запись отсутствует (NXDOMAIN), то есть имя для IP не определено.
* Reverse DNS не является обязательным для всех IP-адресов.
* Наличие PTR обычно характерно для публичных DNS/инфраструктурных адресов.
* Отсутствие PTR (как у 1.1.2.2) является нормальной ситуацией и не означает ошибку сети.

**Пример DNS запроса (sanitized):**

Query: `IP 172.19.x.x.56228 > 172.19.x.x.53: 58896+ A? api.github.com. (32)`  
Response: `IP 172.19.x.x.53 > 172.19.x.x.56228: 58896 1/0/0 A 140.82.121.6 (62)`
