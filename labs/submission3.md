# Lab 3 — GitHub Actions

## Link to the successful run

Ссылка на успешный запуск:  
https://github.com/Ar2rito/DevOps-Intro/actions/runs/22114094666/job/63917538172
<img width="1403" height="638" alt="Снимок экрана 2026-02-17 в 23 24 52" src="https://github.com/user-attachments/assets/32cc225b-cfa5-4527-9c35-ca87b3d484f3" />

---

## Key Concepts Learned (jobs, steps, runners, triggers)

**Triggers** - определяют событие, при котором запускается workflow. В данной работе использовался триггер push.

**Jobs** -логические блоки внутри workflow. В данном случае использовался один job — Explore-GitHub-Actions. Каждый job выполняется отдельно на виртуальной машине.

**Runners** -виртуальные машины, предоставляемые GitHub для выполнения заданий. Указано:

**runs-on: ubuntu-latest**

Это означает, что выполнение происходило на временной виртуальной машине с Ubuntu.

**Steps**— последовательные действия внутри job.

Шаги могут:
	•	выполнять команды (run)
	•	использовать готовые действия (uses)
  
Например- **uses: actions/checkout@v5**

---

## What Triggered the Workflow

Workflow был запущен событием **push**.

После того как я закоммитил файл github-actions-demo.yml в репозиторий, GitHub зафиксировал событие отправки изменений в ветку и автоматически запустил workflow, так как в конфигурации указано:

**on: [push]**

---

## Analysis of Workflow Execution Process

После коммита workflow GitHub обнаружил событие push и инициировал выполнение процесса.

Была создан runner с Ubuntu. Затем запустился job Explore-GitHub-Actions, внутри которого шаги выполнялись последовательно:
	1.	Вывод информации о событии запуска
	2.	Определение среды выполнения
	3.	Клонирование репозитория
	4.	Отображение списка файлов
	5.	Завершение выполнения с фиксацией статуса

Все шаги успешно выполнились, что подтверждается логами во вкладке Actions. Workflow завершился со статусом Success.
