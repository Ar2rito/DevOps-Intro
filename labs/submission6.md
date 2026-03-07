# Lab 6 — Container Fundamentals with Docker


---

## Task 1 — Container Lifecycle & Image Management

### 1.1 Basic Container Operations

#### 1) List Existing Containers
```bash
docker ps -a
```
```text
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

#### 2) Pull Ubuntu Image
```bash
docker pull ubuntu:latest
docker images ubuntu
```
```text
latest: Pulling from library/ubuntu
66a4bbbfab88: Pull complete
Digest: sha256:d1e2e92c075e5ca139d51a140fff46f84315c0fdce203eab2807c7e495eff4f9
Status: Downloaded newer image for ubuntu:latest
docker.io/library/ubuntu:latest

REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
ubuntu       latest    350d40843c24   3 weeks ago   101MB
```

#### 3) Run Interactive Container
```bash
docker run -it --name ubuntu_container ubuntu:latest
```

Inside container:
```bash
cat /etc/os-release
ps aux
exit
```
```text
PRETTY_NAME="Ubuntu 24.04.4 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.4 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo

USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.1   4308  3548 pts/0    Ss   23:24   0:00 /bi
root           9  0.0  0.1   7640  3660 pts/0    R+   23:25   0:00 ps
```

---

### 1.2 Image Export and Dependency Analysis

#### 4) Export the Image
```bash
docker save -o ubuntu_image.tar ubuntu:latest
ls -lh ubuntu_image.tar
```
```text
-rw------- 1 vboxuser vboxuser 99M Mar  5 23:27 ubuntu_image.tar
```

#### 5) Attempt Image Removal
```bash
docker rmi ubuntu:latest
```
```text
Error response from daemon: conflict: unable to remove repository reference "ubuntu:latest" (must force) - container 35ce6161f689 is using its referenced image 350d40843c24
```

#### 6) Remove Container and Retry
```bash
docker rm ubuntu_container
docker rmi ubuntu:latest
```
```text
ubuntu_container

Untagged: ubuntu:latest
Untagged: ubuntu@sha256:d1e2e92c075e5ca139d51a140fff46f84315c0fdce203eab2807c7e495eff4f9
Deleted: sha256:350d40843c2436d6203ee1e35e9264fb08194c3455ec7462236e01adf542c00b
Deleted: sha256:e5dae71ade4390c09123a86ada6c9bc64ac469d0495acae5b2216a627395050c
```

---

## Required Summary Data

### Image size and layer count
- Image: `ubuntu:latest`
- Image size: `101MB`
- Layer count: `1`
  
Узнал количество слоев через команду `docker inspect ubuntu:latest --format '{{len .RootFS.Layers}}'`

### Tar file size vs image size
- `ubuntu_image.tar` size: `99M`
- Docker image size: `101MB`
- Сравнение: значения размера близки; tar-файл включает слои образа и метаданные в переносимом формате для `docker load`.

### Почему удаление образа не удаётся при существующем контейнере
Удаление образа завершается ошибкой, потому что контейнер (`ubuntu_container`) использует `ubuntu:latest` как базовый образ. Docker не позволяет удалять образы, на которые ссылаются существующие контейнеры, чтобы сохранить целостность состояния.

### Что входит в экспортированный tar-файл
Архив `docker save` содержит слои файловой системы образа, manifest, ссылки на теги и метаданные конфигурации образа. Это позволяет перенести и загрузить образ на другом хосте.

## Вывод
Это задание показало модель зависимости `container -> image`: жизненный цикл контейнера напрямую влияет на возможность удаления образа. Также стало ясно, что `docker save` формирует переносимый пакет образа, включающий и слои данных, и метаданные.

---

## Task 2 — Custom Image Creation & Analysis

### 2.1 Deploy and Customize Nginx

#### 1) Deploy Nginx Container
```bash
docker run -d -p 80:80 --name nginx_container nginx
curl http://localhost
```
```text
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
3b66ab8c894c: Pull complete
4a89256e588a: Pull complete
c813174c999b: Pull complete
901e94f777d1: Pull complete
e88d7844c33d: Pull complete
2668e3434976: Pull complete
f2c05cdfb149: Pull complete
Digest: sha256:0236ee02dcbce00b9bd83e0f5fbc51069e7e1161bd59d99885b3ae1734f3392e
Status: Downloaded newer image for nginx:latest
b62e6c4e9dd3374896e785580be151f4127151c6ebc89d06847cef24944df326

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

#### 2) Create and Copy Custom HTML

`index.html` content:
```html
<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>
```

Commands:
```bash
docker cp index.html nginx_container:/usr/share/nginx/html/
curl http://localhost
```
Output:
```text
Successfully copied 2.05kB to nginx_container:/usr/share/nginx/html/

<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>
```

### 2.2 Create and Test Custom Image

#### 3) Commit Container to Image
```bash
docker commit nginx_container my_website:latest
docker images my_website
```
```text
sha256:4c164210830122c887d9f7dc037c9a15f32300f2b2375a546268ff0e0aa6e7be

REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
my_website   latest    4c1642108301   19 seconds ago   181MB
```

#### 4) Remove Original and Deploy from Custom Image
```bash
docker rm -f nginx_container
docker run -d -p 80:80 --name my_website_container my_website:latest
curl http://localhost
```
```text
nginx_container
6ef305022bb85fa9fdf7bd19dfb2772b8d90410d8941d25b4abecd0c12da0462

<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>
```

#### 5) Analyze Filesystem Changes
```bash
docker diff my_website_container
```
```text
C /etc
C /etc/nginx
C /etc/nginx/conf.d
C /etc/nginx/conf.d/default.conf
C /run
C /run/nginx.pid
```

### Анализ docker diff
- `A` (Added): добавленные файлы/каталоги.
- `C` (Changed): измененные файлы/каталоги.
- `D` (Deleted): удаленные файлы/каталоги.
- В моем выводе есть только `C`, то есть контейнер в рантайме изменил системные файлы конфигурации и runtime-файлы (`/run/nginx.pid`), а явных добавлений/удалений не зафиксировано.

### Выводы: docker commit vs Dockerfile
- Преимущества `docker commit`: быстро сохранить текущее состояние контейнера; удобно для экспериментов и прототипирования.
- Недостатки `docker commit`: слабая воспроизводимость, нет прозрачной истории шагов сборки, сложнее поддерживать в команде.
- Преимущества `Dockerfile`: декларативность, повторяемость сборки, контроль версий, удобство CI/CD.
- Недостатки `Dockerfile`: требует чуть больше времени на начальную настройку.

Итог: для учебных и быстрых проверок подходит `docker commit`, для production и командной разработки предпочтителен `Dockerfile`.

---


## Task 3 — Container Networking & Service Discovery

### 3.1 Create Custom Network

#### 1) Create Bridge Network
```bash
docker network create lab_network
docker network ls
```
```text
f05cea842456e9ba8c42de4a398ff5424f1a018442a0f146a2973322562d1e69

NETWORK ID     NAME          DRIVER    SCOPE
b436a58b362c   bridge        bridge    local
70480701e7c4   host          host      local
f05cea842456   lab_network   bridge    local
786719a56672   none          null      local
```

#### 2) Deploy Connected Containers
```bash
docker run -dit --network lab_network --name container1 alpine ash
docker run -dit --network lab_network --name container2 alpine ash
```
```text
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
d8ad8cd72600: Pull complete
Digest: sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659
Status: Downloaded newer image for alpine:latest
480c987d58e08aa85c55142b62f688b4fc81d2ce3996e61fcdb7263f72bb2415

ebb2e9cc97ad7b1cf8a081087800500694d144571105db1325109f2d631eac26
```

### 3.2 Test Connectivity and DNS

#### 3) Test Container-to-Container Communication
```bash
docker exec container1 ping -c 3 container2
```
```text
PING container2 (172.18.0.3): 56 data bytes
64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.863 ms
64 bytes from 172.18.0.3: seq=1 ttl=64 time=0.363 ms
64 bytes from 172.18.0.3: seq=2 ttl=64 time=0.436 ms

--- container2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.363/0.554/0.863 ms
```

#### 4) Inspect Network Details
```bash
docker network inspect lab_network
```
```text
{
  "Name": "lab_network",
  "Driver": "bridge",
  "IPAM": {
    "Config": [
      {
        "Subnet": "172.18.0.0/16",
        "Gateway": "172.18.0.1"
      }
    ]
  },
  "Containers": {
    "480c987d58e08aa85c55142b62f688b4fc81d2ce3996e61fcdb7263f72bb2415": {
      "Name": "container1",
      "IPv4Address": "172.18.0.2/16"
    },
    "ebb2e9cc97ad7b1cf8a081087800500694d144571105db1325109f2d631eac26": {
      "Name": "container2",
      "IPv4Address": "172.18.0.3/16"
    }
  }
}
```

#### 5) Check DNS Resolution
```bash
docker exec container1 nslookup container2
```
```text
Server:         127.0.0.11
Address:        127.0.0.11:53

Non-authoritative answer:
Name:   container2
Address: 172.18.0.3
```

### Анализ: Docker internal DNS
Во внутренней сети Docker (`lab_network`) каждый контейнер автоматически регистрируется во встроенном DNS-сервере Docker (`127.0.0.11`).  
Поэтому `container1` может обращаться к `container2` по имени, а DNS разрешает имя `container2` в его IP-адрес `172.18.0.3`.

### Сравнение: user-defined bridge vs default bridge
- User-defined bridge поддерживает автоматическое DNS-резолвинг имен контейнеров.
- Улучшенная изоляция: контейнеры взаимодействуют в пределах конкретной сети.
- Гибкость: удобное явное подключение/отключение контейнеров к сети.
- Лучше для микросервисов и сервис-дискавери, чем default bridge, где имена контейнеров обычно не резолвятся автоматически.

---


## Task 4 — Data Persistence with Volumes 

### 4.1 Create and Use Volume

#### 1) Create Named Volume
```bash
docker volume create app_data
docker volume ls
```
```text
app_data

DRIVER    VOLUME NAME
local     app_data
```

#### 2) Deploy Container with Volume
```bash
docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web nginx
```
```text
eeb8cc9ae6bc4b604c0fb815a9ac85adcb4909b3af63a3118f209aa13050684a
```

Custom `index.html`:
```html
<html><body><h1>Persistent Data</h1></body></html>
```

Copy content and verify:
```bash
docker cp index.html web:/usr/share/nginx/html/index.html
curl http://localhost
```
```text
Successfully copied 2.05kB to web:/usr/share/nginx/html/index.html

<html><body><h1>Persistent Data</h1></body></html>
```

### 4.2 Verify Persistence

#### 3) Destroy and Recreate Container
```bash
docker stop web && docker rm web
docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web_new nginx
curl http://localhost
```
```text
web
web
0fe7fdaf27ee410aa9522e4ac477030e7ae3f2b2468a15a74811b69a3864c1e0

<html><body><h1>Persistent Data</h1></body></html>
```

#### 4) Inspect Volume
```bash
docker volume inspect app_data
```
```text
[
    {
        "CreatedAt": "2026-03-06T00:41:54Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/app_data/_data",
        "Name": "app_data",
        "Options": null,
        "Scope": "local"
    }
]
```

### Анализ: Why persistence matters
Сохраненность важна, потому что контейнеры по своей природе непостоянны: при удалении контейнера его внутреннее хранилище теряется.  
Volumes позволяют сохранять критичные данные (контент, логи, загрузки) независимо от жизненного цикла контейнера.

### Сравнение: volumes vs bind mounts vs container storage
- `Volumes`: управляются Docker, удобны для production, изолированы от структуры хоста, легко бэкапить и переносить между контейнерами.
- `Bind mounts`: монтируют конкретную директорию хоста; удобны для разработки , но сильнее зависят от путей и прав на хосте.
- `Container storage` : временное хранилище; исчезает при удалении контейнера, для постоянных данных не подходит.

Когда использовать:
- `Volumes`: данные приложения в production.
- `Bind mounts`: локальная разработка и быстрый доступ к файлам хоста.
- `Container storage`: временные runtime-данные внутри одного запуска контейнера.
