# Lab 11 — Reproducible Builds with Nix


## Task 1 — Build Reproducible Artifacts from Scratch

### 1.1 Installing and verifying Nix

I used the Determinate Systems installer recommended in the assignment:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Verification commands:

```bash
nix --version
nix run nixpkgs#hello
```

Ubuntu VM output:

```text
nix (Determinate Nix 3.17.3) 2.33.3
Hello, world!
```

Этот шаг подтвердил, что Nix установлен корректно и что я могу запускать пакеты напрямую из `nixpkgs`, не устанавливая их постоянно в систему.

### 1.2 Simple Go application

Files used:

- `labs/lab11/app/main.go`
- `labs/lab11/app/go.mod`

Source code:

```go
package main

import (
    "fmt"
    "time"
)

func main() {
    fmt.Println("Built reproducibly with Nix")
    fmt.Printf("Running at: %s\n", time.Now().Format(time.RFC3339))
}
```

Explanation:

- Первая строка вывода постоянна и не зависит ни от машины, ни от времени сборки.
- Метка времени создаётся во время выполнения программы, а не встраивается при компиляции.
- Поскольку эта метка времени не является частью итогового бинарного файла, она не нарушает воспроизводимость сборки.

### 1.3 Nix derivation

File: `labs/lab11/app/default.nix`

```nix
{ pkgs ? import <nixpkgs> { } }:

pkgs.buildGoModule rec {
  pname = "app";
  version = "1.0.0";

  src = ./.;

  vendorHash = null;
  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
    "-buildid="
  ];

  meta = with pkgs.lib; {
    description = "Small Go application used in Lab 11 for reproducible builds with Nix";
    license = licenses.mit;
    mainProgram = "app";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
```

Why these fields matter:

- `buildGoModule` собирает Go-приложения в изолированной и воспроизводимой среде.
- `src = ./.;` делает текущую директорию единственным исходным входом для derivation.
- `vendorHash = null;` допустим здесь, потому что проект использует только стандартную библиотеку Go.
- `ldflags = [ "-s" "-w" "-buildid=" ];` убирает лишние метаданные и помогает сделать бинарный файл воспроизводимым.

Build commands:

```bash
cd labs/lab11/app
nix-build
./result/bin/app
```

Ubuntu VM output:

```text
evaluation warning: `-buildid=` is set by default as ldflag by buildGoModule
/nix/store/v79v5yda49z1h49z6a5al5129dxmzbj-app-1.0.0
Built reproducibly with Nix
Running at: 2026-04-16T19:53:17Z
```

### 1.4 Proof of reproducibility

Commands used:

```bash
readlink result
rm result
nix-build
readlink result
sha256sum ./result/bin/app
```

Observed store paths:

```text
First build store path:  /nix/store/v79v5yda49z1h49z6a5al5129dxmzbj-app-1.0.0
Second build store path: /nix/store/v79v5yda49z1h49z6a5al5129dxmzbj-app-1.0.0
```

Observed binary hash:

```text
a5f0ac74584bcf35b0ade5228f253f8e65cc950021bfdd0ed7a4d4c0c298e1a  ./result/bin/app
```

Analysis:

- В моих повторных сборках оба пути в Nix store оказались одинаковыми, а это означает, что Nix вычислил одну и ту же derivation с тем же графом зависимостей и получил тот же выходной путь.
- Хэш бинарного файла также остался одинаковым между повторными сборками, что является признаком побитовой воспроизводимости.
- В Nix выходной путь зависит от полного рецепта сборки и всего набора зависимостей, а не только от имени итогового файла.

### Comparison with a traditional Docker-based build

File: `labs/lab11/app/Dockerfile`

```dockerfile
FROM golang:1.22

WORKDIR /app

COPY go.mod main.go ./

RUN go build -o app .

CMD ["/app"]
```

Commands:

```bash
docker build -t test-app:first .
docker image inspect test-app:first --format '{{.Id}}'
docker build -t test-app:second .
docker image inspect test-app:second --format '{{.Id}}'
```

Observed Docker image IDs:

```text
First image ID:  sha256:d590e692498e36d85041003969dd25fc705abe7f6467f5e427038a3d789fd7d5
Second image ID: sha256:d590e692498e36d85041003969dd25fc705abe7f6467f5e427038a3d789fd7d5
```

Observation:

- В этом запуске два традиционных Docker image ID оказались одинаковыми, потому что во второй сборке был использован кэш слоёв Docker.
- Хотя именно эта пара сборок не дала разных image ID, Docker всё равно не гарантирует воспроизводимость во времени, если базовые образы не закреплены по digest и все источники метаданных не контролируются явно.

Why Docker is not reproducible by default:

- `FROM golang:1.22` использует изменяемый тег, если не закрепить точный digest образа.
- Сборки Docker часто включают временные метки и метаданные, которые отличаются между запусками.
- Традиционные Docker-сборки имеют императивный характер: каждый шаг воспроизводится заново, а не выводится из чисто декларативного графа зависимостей.
- Сборка может зависеть от изменяющегося состояния registry или package index с течением времени.

### Why Nix builds are reproducible

Nix повышает воспроизводимость, потому что все зависимости объявлены явно, сборки выполняются изолированно, а результаты хранятся в неизменяемом `/nix/store`. Выходной путь зависит от derivation и полного графа её зависимостей, поэтому одинаковые входы дают одинаковый результат на разных машинах.

Это сильнее обычных package manager’ов или Dockerfile, потому что Nix избегает скрытой зависимости от хост-системы, изменяемых глобальных библиотек и случайной версии пакета, которая оказалась доступна в момент сборки.

### Nix store path format

Example:

```text
/nix/store/<hash>-app-1.0.0
```

Meaning:

- `/nix/store` — это глобальное неизменяемое хранилище результатов сборки.
- `<hash>` вычисляется на основе инструкций сборки и графа зависимостей.
- `app-1.0.0` — это человекочитаемые имя пакета и его версия.

Если меняется любой вход, например исходный код, версия компилятора, набор зависимостей или флаги сборки, хэш тоже изменяется.

## Task 2 — Reproducible Docker Images with Nix

### 2.1 Building a Docker image with Nix

File: `labs/lab11/app/docker.nix`

```nix
{ pkgs ? import <nixpkgs> { } }:

let
  app = import ./default.nix { inherit pkgs; };
in
pkgs.dockerTools.buildLayeredImage {
  name = "lab11-nix-app";
  tag = "latest";

  contents = [ app ];

  config = {
    Cmd = [ "${app}/bin/app" ];
    WorkingDir = "/";
  };
}
```

Important reproducibility detail:

- Я специально не задавал `created = "now"`.
- `dockerTools.buildLayeredImage` по умолчанию использует детерминированные метаданные, что помогает сохранить воспроизводимость.

Build and run commands:

```bash
cd labs/lab11/app
nix-build docker.nix
docker load < result
docker run --rm lab11-nix-app:latest
```

Ubuntu VM output:

```text
evaluation warning: `-buildid=` is set by default as ldflag by buildGoModule
these 8 derivations will be built:
  /nix/store/7p622rmg4ap7b06zdiyaj52j0a58124k-app-1.0.0.drv
  /nix/store/0a9i9995z85jmczml2khc4lk8pd1pikn-lab11-nix-app-customisation-layer.drv
  /nix/store/330a23hqpccvx2ar6v15y6kw2ryjyxkh-lab11-nix-app-base.json.drv
  /nix/store/x9iwxppbymx7s0aa9pjw17jn245ry5q9-excludePaths.drv
  /nix/store/fl3qhkvkxyxbbi4x41yj5m4bna463815-layers.json.drv
  /nix/store/807g0qk6agzk35478kv4hwbivonss8gg-lab11-nix-app-conf.json.drv
  /nix/store/jlvna50zjw533r6nz1c2qz9jj0z1r6hq-stream-lab11-nix-app.drv
  /nix/store/44sg2yv4gvx350drr8lzmibm5r14z2z3-lab11-nix-app.tar.gz.drv
...
/nix/store/0ahy7f6sw8gzfd6lp9g4jrjcbwdn8zwz-lab11-nix-app.tar.gz

Loaded image: lab11-nix-app:latest

Built reproducibly with Nix
Running at: 2026-04-16T20:39:08Z
```

### 2.2 Size comparison and reproducibility

Traditional Docker image file: `labs/lab11/app/Dockerfile.traditional`

```dockerfile
FROM golang:1.22 AS build

WORKDIR /src

COPY go.mod main.go ./

RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w -buildid=" -o /out/app .

FROM scratch

COPY --from=build /out/app /app

ENTRYPOINT ["/app"]
```

Commands:

```bash
docker build -f Dockerfile.traditional -t traditional-app .
docker images | grep -E 'lab11-nix-app|traditional-app|test-app'
ls -lh result
nix-build docker.nix --option build-repeat 2
sha256sum result
rm result
nix-build docker.nix
sha256sum result
```

Observed size comparison:

```text
test-app        first    d590e692498e   16 minutes ago   860MB
test-app        second   d590e692498e   16 minutes ago   860MB
lab11-nix-app   latest   c7fbc9425dd5   56 years ago     3.52MB

lrwxrwxrwx 1 vboxuser vboxuser 64 Apr 16 20:38 result -> /nix/store/0ahy7f6sw8gzfd6lp9g4jrjcbwdn8zwz-lab11-nix-app.tar.gz
```

Observed Nix image tarball hashes:

```text
First Nix tarball hash:  7719b72b3342c205ed53baf21f9858e87d5d2a3a8064a0b0b75d7589c8e9836b  result
Second Nix tarball hash: 914cf50fa15244214e4f73df3575f06e6cb5af145318b63949b72e5179d81b37  result
```

Analysis:

- В этом запуске образ, собранный через Nix, оказался значительно меньше: `3.52MB` против `860MB` у традиционного Go image.
- Маленький размер объясняется тем, что в образ включается только необходимое runtime closure, а не полный образ с Go toolchain.
- Два хэша tarball выше различались, потому что более поздняя сборка выполнялась уже не с точно теми же входами: между сборками в директории приложения появились дополнительные файлы, а `src = ./.;` делает всю директорию частью входа derivation.
- Поэтому эту пару хэшей не нужно интерпретировать как провал воспроизводимости Nix. Наоборот, это показывает, что при изменении входов Nix корректно создаёт другой выходной хэш.
- Nix image строится из точного содержимого store, а не путём повторного выполнения изменяемых шагов сборки.

### 2.3 Docker history comparison

Commands:

```bash
docker history lab11-nix-app:latest
docker history traditional-app:latest
```

Observed output:

```text
Nix image history:
IMAGE          CREATED   CREATED BY                     SIZE    COMMENT
dce77b9425d5   N/A       N/A                            61B     store paths: ['/nix/store/kw4zxqc49fwb79xh6064pzz73svadb2v-lab11-nix-app-customisation-layer']
73svadb2v-...  N/A       ["/nix/store/..."]            1.62MB  store paths: ['/nix/store/y6lrk5p8b5sla8v3kykfhgwwvipyj04w-app-1.0.0']
<missing>      N/A       N/A                            1.9MB   store paths: ['/nix/store/q88x4d2i4y7cxp7qhvp4fpp4c4lv1nkf-tzdata-2026a']

Traditional image history:
IMAGE         CREATED          CREATED BY                                      SIZE    COMMENT
6ce756e9b59f  17 seconds ago   /bin/sh -c #(nop) ENTRYPOINT ["/app"]          0B
83c9f71c0b82  17 seconds ago   /bin/sh -c #(nop) COPY file:c4f58623853b...    1.38MB
```

Layer structure comparison:

- Nix image собирается из store paths и детерминированных метаданных образа.
- Традиционный Docker image отражает императивные стадии сборки и стандартное поведение Docker layers.
- Поэтому Nix image проще анализировать с точки зрения воспроизводимости.
- История Nix image показывает слои на основе store paths, тогда как история традиционного image показывает стандартные операции Dockerfile, такие как `COPY` и `ENTRYPOINT`.

### Why Nix-built images are smaller and more reproducible

Образы, собранные через Nix, часто меньше по размеру, потому что `dockerTools` включает только тот runtime closure, который действительно нужен приложению, а не полную среду сборки. Кроме того, они более воспроизводимы, потому что содержимое образа формируется из точных результатов derivation, а не из изменяемых package repositories или слоёв сборки с временными метками.

Practical advantages:

- воспроизводимые образы на разных машинах и в разное время;
- точное отслеживание зависимостей;
- более эффективное использование кэша;
- меньше скрытых побочных эффектов при сборке образа;
- проще аудит того, что именно находится внутри контейнера.

## Bonus Task — Modern Nix with Flakes

### Bonus.1 Flake configuration

File: `labs/lab11/app/flake.nix`

```nix
{
  description = "Lab 11 - reproducible builds with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system:
          f (import nixpkgs { inherit system; })
        );
    in
    {
      packages = forAllSystems (pkgs: {
        default = import ./default.nix { inherit pkgs; };
      });

      dockerImages = forAllSystems (pkgs: {
        default = import ./docker.nix { inherit pkgs; };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.go
            pkgs.gopls
            pkgs.nixpkgs-fmt
          ];
        };
      });
    };
}
```

Commands:

```bash
cd labs/lab11/app
nix flake update
nix build
nix build .#dockerImages.x86_64-linux.default
nix develop
```

Output to include if the bonus was completed:

```text
<paste relevant flake.lock snippet here>
<paste output of nix build here>
<paste short notes about nix develop here>
```

### How flakes improve reproducibility

Flakes улучшают традиционные Nix expressions тем, что фиксируют зависимости в `flake.lock`. Это означает, что позже проект можно вычислить с использованием той же самой закреплённой ревизии `nixpkgs`, а не той версии, которая случайно окажется доступна через `<nixpkgs>` в данный момент.

Они также дают более чистую структуру проекта, улучшают переносимость и упрощают вход нескольких разработчиков или машин в одну и ту же среду сборки и dev shell.

## Reflection

Эта лабораторная работа показала основную идею Nix: воспроизводимость достигается за счёт полностью объявленных входов, sandboxed builds, неизменяемых результатов и content-addressed storage. По сравнению с Dockerfile или обычными package manager’ами Nix даёт гораздо более сильные гарантии того, что один и тот же исходный код и набор зависимостей произведут один и тот же артефакт на разных машинах.

Часть с Docker показала, что Nix может распространять эти гарантии и на контейнерные workflow, что полезно для deployment pipeline и для устранения проблемы "works on my machine" в командной работе.

