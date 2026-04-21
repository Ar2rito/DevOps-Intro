
# Lab 12 — WebAssembly Containers vs Traditional Containers

## Task 1 — Create the Moscow Time Application

В рамках первого задания я работал непосредственно в директории `labs/lab12`, где уже были предоставлены все необходимые файлы: `main.go`, `Dockerfile`, `Dockerfile.wasm` и `spin.toml`.

Сначала я проверил работу приложения в CLI-режиме. Для этого была выполнена команда:

```bash
cd ~/DevOps-Intro/labs/lab12
MODE=once go run main.go
```

В результате программа вывела JSON-ответ с текущим временем Москвы и Unix timestamp:

```json
{
  "moscow_time": "2026-04-21 22:13:16 MSK",
  "timestamp": 1776798796
}
```

Это подтверждает, что приложение корректно работает в режиме однократного запуска (`MODE=once`), который позже используется для benchmarking как в traditional container, так и в WASM container.

<img src="21_04_1" width="400" >

После этого я проверил работу приложения в режиме HTTP-сервера. Для запуска была использована команда:

```bash
go run main.go
```

После запуска в терминале появилось сообщение:

```bash
2026/04/21 19:13:27 Server starting on :8080
```

Затем в браузере был открыт адрес:

```text
http://localhost:8080
```

Приложение успешно отобразило веб-страницу с текущим временем в Москве.

<img src="21_04_2" width="400" >

Один и тот же файл `main.go` работает в трёх различных контекстах:
- `MODE=once` запускает приложение в CLI-режиме и выводит JSON один раз
- обычный запуск `go run main.go` поднимает стандартный HTTP-сервер на базе `net/http`
- при запуске в среде Spin приложение определяет WAGI-контекст через переменные окружения, например `REQUEST_METHOD`, и обрабатывает запрос в CGI/WAGI-формате

Таким образом, одно и то же исходное приложение используется для traditional Docker container, WASM container и Spin deployment без изменения основной логики программы.

