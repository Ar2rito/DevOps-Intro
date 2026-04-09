# Lab 10 — Cloud Computing Fundamentals

## Task 1 — Artifact Registries Research

## 1.1 Service Name for Each Cloud Provider

- AWS: `Amazon Elastic Container Registry` (`Amazon ECR` отвечает за Docker/OCI-образы и совместимые OCI-артефакты) как основной registry для контейнерных и OCI-артефактов; при этом для language packages AWS использует отдельный сервис `AWS CodeArtifact`(отвечает за package-репозитории: npm, Maven, PyPI и другие
).
- GCP: `Artifact Registry`
- Azure: `Azure Container Registry (ACR)`

## 1.2 Key Features and Supported Artifact Types

### AWS — Amazon ECR + AWS CodeArtifact

**Amazon ECR**

- Поддерживаемые артефакты: Docker images, OCI images, OCI-compatible artifacts.
- Дополнительно поддерживаются OCI reference artifacts: подписи, SBOM, Helm charts, scan results, attestations.
- Ключевые возможности:
  - vulnerability scanning;
  - интеграция с Amazon Inspector для enhanced scanning;
  - cross-region и cross-account replication;
  - IAM-based access control;
  - удобная работа с ECS, EKS, Lambda и другими AWS сервисами.
- Интеграции:
  - ECS;
  - EKS;
  - Lambda;
  - EventBridge;
  - IAM;
  - Amazon Inspector.
- Модель оплаты:
  - платишь за объём хранения;
  - отдельно учитывается data transfer;
  - для private и public repositories правила немного различаются.
- Частые use cases:
  - хранение production container images;
  - приватные образы для ECS/EKS;
  - хранение OCI signatures и SBOM;
  - безопасная доставка контейнеров внутри AWS.

**AWS CodeArtifact**

- Поддерживаемые форматы: Cargo, generic, Maven, npm, NuGet, PyPI, Ruby, Swift.
- Ключевые возможности:
  - централизованное хранение внутренних пакетов;
  - IAM permissions;
  - удобная публикация через стандартные package manager tools.
- Частые use cases:
  - внутренний npm registry;
  - приватные Python/Java/.NET пакеты;
  - контроль зависимостей внутри AWS.

### GCP — Artifact Registry

- Поддерживаемые артефакты:
  - Docker images;
  - Helm charts in OCI format;
  - Maven;
  - npm;
  - Python;
  - Apt;
  - Yum;
  - Go modules;
  - generic artifacts;
  - Kubeflow pipeline templates.
- Ключевые возможности:
  - единая точка хранения для контейнеров и пакетов;
  - IAM access control;
  - vulnerability scanning через Artifact Analysis;
  - remote repositories как proxy/cache для внешних источников;
  - virtual repositories как единая точка чтения из нескольких upstream;
  - cleanup policies.
- Интеграции:
  - Cloud Build;
  - Cloud Run;
  - GKE;
  - Compute Engine;
  - App Engine;
  - VPC Service Controls.
- Модель оплаты:
  - billing за storage;
  - data transfer;
  - vulnerability scanning, если включено;
  - virtual repositories сами артефакты не хранят, поэтому их модель оплаты отличается.
- Частые use cases:
  - единый registry для контейнеров и пакетов;
  - кэширование Docker Hub, Maven Central, PyPI;
  - защита от dependency confusion;
  - интеграция с Cloud Build и Cloud Run.

### Azure — Azure Container Registry (ACR)

- Поддерживаемые артефакты:
  - Docker images;
  - OCI images;
  - OCI artifacts;
  - Helm charts;
  - другие related artifact formats, совместимые с OCI.
- Ключевые возможности:
  - private registry для enterprise deployment pipelines;
  - ACR Tasks для сборки и автоматизации;
  - geo-replication;
  - authentication/authorization через Microsoft Entra и repository permissions;
  - Artifact Streaming;
  - Artifact Cache;
  - Soft delete policy.
- Интеграции:
  - AKS;
  - Azure App Service;
  - Azure Machine Learning;
  - Azure Batch;
  - Azure DevOps pipelines.
- Модель оплаты:
  - tier-based pricing: Basic / Standard / Premium;
  - в стоимость входят разные лимиты storage;
  - дополнительное storage оплачивается отдельно;
  - geo-replication доступна только в Premium.
- Частые use cases:
  - приватный registry для AKS;
  - глобальная доставка образов через geo-replication;
  - cloud-side image build через ACR Tasks;
  - enterprise CI/CD в Azure.

## 1.3 Comparison Table

| Критерий | AWS | GCP | Azure |
| --- | --- | --- | --- |
| Основной сервис | Amazon ECR, плюс CodeArtifact для packages | Artifact Registry | Azure Container Registry |
| Поддержка container/OCI | Да | Да | Да |
| Поддержка language packages в том же сервисе | Нет, нужен CodeArtifact | Да | Ограниченно, основной акцент на OCI/container artifacts |
| Поддержка npm/Maven/Python | Через CodeArtifact | Да, нативно в Artifact Registry | Не основной сценарий ACR |
| Сканирование уязвимостей | Да, ECR + Amazon Inspector | Да, через Artifact Analysis | Да, через security integrations и platform features |
| Репликация | Cross-region, cross-account | Региональные/мультирегиональные репозитории, remote/virtual modes | Geo-replication |
| Контроль доступа | IAM | IAM | Microsoft Entra + repository permissions |
| Интеграции | ECS, EKS, Lambda, EventBridge | Cloud Build, Cloud Run, GKE | AKS, App Service, Azure ML, ACR Tasks |
| Сильная сторона | Очень сильная интеграция в AWS контейнерный стек | Самый универсальный единый registry по форматам | Сильная geo-replication и enterprise container workflows |
| Ограничение | Нет одного универсального сервиса для всех артефактов | Сильнее всего раскрывается внутри GCP | Основной фокус на контейнерах и OCI, а не на package ecosystem |

## 1.4 Analysis: Which Registry Would I Choose for a Multi-Cloud Strategy and Why?

Если цель именно `multi-cloud strategy`,  выбирать нужно `Google Artifact Registry` как наиболее удобную точку опоры.

Причины:

1. Это самый универсальный сервис из трёх в рамках одного продукта: он хранит и container images, и распространённые package formats.
2. У него есть `remote repositories`, что удобно для кэширования внешних источников зависимостей.
3. У него есть `virtual repositories`, что помогает объединять несколько upstream и уменьшать риск dependency confusion.
4. Для multi-cloud сценария важно минимизировать количество разных registry-сервисов и разных правил доступа. У GCP в этом месте архитектура проще, чем связка `ECR + CodeArtifact` в AWS.

При этом если бы инфраструктура уже была почти полностью в AWS, то практичнее было бы использовать `Amazon ECR` для контейнеров и `AWS CodeArtifact` для пакетов, потому что выигрыш от глубокой интеграции с ECS/EKS/Lambda тогда перевешивает недостаток разделения на два сервиса.

---

## Task 2 — Serverless Computing Platform Research

## 2.1 Service Name(s) for Each Cloud Provider

- AWS: `AWS Lambda`
- GCP: `Cloud Run` как основной serverless compute для HTTP и container-based workloads
- Azure: `Azure Functions`

## 2.2 Key Features, Runtimes, Pricing, and Performance

### AWS — AWS Lambda

- Поддерживаемые managed runtimes:
  - Node.js;
  - Python;
  - Java;
  - .NET;
  - Ruby.
- Дополнительно:
  - custom runtimes;
  - container images;
  - OS-only runtime для Go, Rust и других языков.
- Архитектуры:
  - `x86_64`;
  - `arm64`.
- Execution model:
  - synchronous invocation;
  - asynchronous invocation;
  - event source mappings для queue/stream sources;
  - HTTP обычно через API Gateway или Lambda Function URL.
- Cold start:
  - есть при создании нового execution environment;
  - можно уменьшать через `Provisioned Concurrency`;
  - для latency-sensitive workloads это важная настройка.
- Интеграции:
  - API Gateway;
  - S3;
  - SNS;
  - SQS;
  - EventBridge;
  - DynamoDB Streams;
  - Kinesis;
  - CloudWatch;
  - IAM.
- Pricing model:
  - requests + execution duration;
  - стоимость зависит от памяти;
  - есть free tier: `1 million requests` и `400,000 GB-seconds` в месяц.
- Maximum execution duration:
  - до `900 seconds (15 minutes)`.
- Common use cases:
  - event-driven automation;
  - webhook handlers;
  - API endpoints;
  - ETL fragments;
  - background jobs;
  - integration glue code.

### GCP — Cloud Run

- Поддерживаемые языки:
  - фактически любой язык, если приложение упаковано в контейнер;
  - source-based deploy удобно работает с Go, Node.js, Python, Java, .NET, Ruby.
- Execution model:
  - HTTP service;
  - event-driven service через Eventarc;
  - Pub/Sub push;
  - jobs для run-to-completion workloads.
- Cold start:
  - возможен при scale-to-zero;
  - уменьшается через `minimum instances`;
  - это позволяет снизить startup latency для production APIs.
- Интеграции:
  - Eventarc;
  - Pub/Sub;
  - Cloud Build;
  - Artifact Registry;
  - Cloud SQL;
  - VPC connectors;
  - IAM.
- Pricing model:
  - requests;
  - CPU per vCPU-second;
  - memory per GiB-second;
  - для `min instances` есть отдельная idle billing model;
  - цены зависят от региона.
- Maximum execution duration:
  - timeout по умолчанию `5 minutes`;
  - максимум `60 minutes`.
- Common use cases:
  - REST API backend;
  - containerized web services;
  - internal microservices;
  - event-driven handlers;
  - long-running HTTP workloads, которые уже не так удобны для Lambda.

### Azure — Azure Functions

- Поддерживаемые языки:
  - C#/.NET;
  - Java;
  - JavaScript;
  - TypeScript;
  - Python;
  - PowerShell;
  - custom handlers для Go, Rust и других языков.
- Execution model:
  - HTTP triggers;
  - timer triggers;
  - queue triggers;
  - event-driven execution через bindings и triggers.
- Cold start:
  - в legacy Consumption возможна заметная задержка после простоя;
  - `Flex Consumption` улучшает cold start и поддерживает always-ready instances;
  - `Premium plan` использует prewarmed и always-ready instances, чтобы практически убрать cold starts.
- Интеграции:
  - Azure Storage;
  - Event Grid;
  - Service Bus;
  - Cosmos DB;
  - Timer;
  - HTTP;
  - широкий набор input/output bindings.
- Pricing model:
  - `Consumption/Flex`: per-second resource consumption + executions;
  - `Premium`: billing по core-seconds и memory, без execution charge;
  - минимум один активный инстанс в Premium.
- Maximum execution duration:
  - в Consumption historically ограничено и подходит для коротких функций;
  - в современных `Flex Consumption` и `Premium` лимит зависит от плана и может быть фактически `unbounded`, но с platform constraints;
  - Premium docs отдельно отмечают, что Consumption plan ограничен `10 minutes` на single execution.
- Common use cases:
  - serverless APIs;
  - scheduled jobs;
  - queue processing;
  - Azure-centric event workflows;
  - интеграционные сценарии с bindings.

## 2.3 Comparison Table

| Критерий | AWS Lambda | GCP Cloud Run | Azure Functions |
| --- | --- | --- | --- |
| Основная модель | Function-as-a-Service | Serverless containers/services | Function-as-a-Service |
| Языки | Managed runtimes + custom runtimes + containers | Любой язык в контейнере | .NET, Java, JS/TS, Python, PowerShell, custom handlers |
| HTTP-сценарии | Через API Gateway или Function URL | Нативный HTTP service | HTTP trigger |
| Event-driven сценарии | Очень сильные | Да, через Eventarc/PubSub | Очень сильные через triggers/bindings |
| Cold start | Есть, смягчается Provisioned Concurrency | Есть при scale-to-zero, смягчается min instances | Consumption может быть медленнее; Flex/Premium уменьшают cold start |
| Лимит выполнения | 15 минут | До 60 минут для services | Зависит от плана; Flex/Premium значительно гибче |
| Модель оплаты | Requests + duration + memory | Requests + CPU + memory | Executions + resource consumption; Premium по core/memory |
| Сильная сторона | Богатая event ecosystem внутри AWS | Идеален для containerized HTTP backends | Очень удобные bindings и гибкий Azure integration story |
| Лучшие use cases | Event handlers, async pipelines, glue code | REST API, microservices, container apps | Azure integrations, scheduled and event-driven functions |

## 2.4 Analysis: Which Serverless Platform Would I Choose for a REST API Backend and Why?

Для `REST API backend` выбирать стоит `Cloud Run`.

Причины:

1. Cloud Run естественно работает как обычный HTTP-сервис, а не как набор отдельных функций на каждый endpoint.
2. Он поддерживает любой язык и любой framework через контейнер, поэтому migration из обычного backend-приложения проще.
3. У него более комфортный лимит выполнения для HTTP workload: до `60 minutes`, что заметно больше, чем `15 minutes` у Lambda.
4. При необходимости можно включить `minimum instances`, чтобы уменьшить cold start и сделать latency стабильнее.
5. Такой backend меньше привязан к конкретной FaaS-модели и обычно проще переносится между средами.

Если задача именно event-driven integration внутри AWS, тогда выбирать стоит `AWS Lambda`, потому что у него сильнейшая интеграция с событиями и очередями AWS.

## 2.5 Reflection: Main Advantages and Disadvantages of Serverless Computing

### Advantages

1. Не нужно управлять серверами и патчить ОС.
2. Автомасштабирование работает автоматически.
3. Оплата обычно идёт только за фактическое использование.
4. Очень удобно для событийных и нерегулярных нагрузок.
5. Быстрее запускать MVP, automation и небольшие backend-сервисы.

### Disadvantages

1. Cold starts могут влиять на latency.
2. Есть ограничения по времени выполнения, памяти и модели сети.
3. Сильнее проявляется vendor lock-in, особенно если использовать provider-specific triggers и bindings.
4. Локальная отладка и observability иногда сложнее, чем у обычных сервисов.
5. Для long-running, high-throughput или stateful workloads serverless не всегда оптимален по цене и архитектуре.

---

## Official Sources

### AWS

- [Amazon ECR pricing](https://aws.amazon.com/ecr/pricing/)
- [Amazon ECR private images](https://docs.aws.amazon.com/AmazonECR/latest/userguide/images.html)
- [Amazon ECR image scanning](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html)
- [Amazon ECR replication](https://docs.aws.amazon.com/AmazonECR/latest/userguide/replication.html)
- [AWS CodeArtifact packages overview](https://docs.aws.amazon.com/codeartifact/latest/ug/packages-overview.html)
- [AWS Lambda runtimes](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html)
- [AWS Lambda timeout](https://docs.aws.amazon.com/lambda/latest/dg/configuration-timeout.html)
- [AWS Lambda event-driven architectures](https://docs.aws.amazon.com/lambda/latest/dg/concepts-event-driven-architectures.html)
- [AWS Lambda concurrency and provisioned concurrency](https://docs.aws.amazon.com/lambda/latest/dg/lambda-concurrency.html)
- [AWS Lambda pricing](https://aws.amazon.com/lambda/pricing/)

### GCP

- [Artifact Registry overview](https://cloud.google.com/artifact-registry/docs/overview)
- [Artifact Registry supported formats](https://cloud.google.com/artifact-registry/docs/supported-formats)
- [Artifact Registry remote repositories](https://cloud.google.com/artifact-registry/docs/repositories/remote-repo)
- [Artifact Registry virtual repositories](https://cloud.google.com/artifact-registry/docs/repositories/virtual-overview)
- [Artifact Registry pricing](https://cloud.google.com/artifact-registry/pricing)
- [What is Cloud Run](https://cloud.google.com/run/docs/overview/what-is-cloud-run)
- [Cloud Run container runtime contract](https://cloud.google.com/run/docs/container-contract)
- [Cloud Run request timeout](https://cloud.google.com/run/docs/configuring/request-timeout)
- [Cloud Run minimum instances](https://cloud.google.com/run/docs/configuring/min-instances)
- [Cloud Run event triggers with Eventarc](https://cloud.google.com/run/docs/triggering/trigger-with-events)
- [Cloud Run pricing](https://cloud.google.com/run/pricing)

### Azure

- [Azure Container Registry documentation](https://learn.microsoft.com/en-us/azure/container-registry/)
- [Azure Container Registry pricing](https://azure.microsoft.com/en-us/pricing/details/container-registry/)
- [Azure Container Registry product page](https://azure.microsoft.com/en-us/products/container-registry/)
- [Azure Functions supported languages](https://learn.microsoft.com/en-us/azure/azure-functions/supported-languages)
- [Azure Functions triggers and bindings](https://learn.microsoft.com/en-us/azure/azure-functions/functions-triggers-bindings)
- [Azure Functions hosting options](https://learn.microsoft.com/en-us/azure/azure-functions/functions-scale)
- [Azure Functions Flex Consumption](https://learn.microsoft.com/en-us/azure/azure-functions/flex-consumption-plan)
- [Azure Functions runtime versions and timeout behavior](https://learn.microsoft.com/en-us/azure/azure-functions/functions-versions)
- [Azure Functions Premium plan](https://learn.microsoft.com/en-us/azure/azure-functions/functions-premium-plan)
- [Azure Functions pricing](https://azure.microsoft.com/en-us/pricing/details/functions/)
