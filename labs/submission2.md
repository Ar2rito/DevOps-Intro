Task 1 — Git Object Model Exploration

1.1 Sample Commits

Создан тестовый файл и добавлен в коммит:
echo "Test content" > test.txt
git add test.txt
git commit -m "Add test file"
Вывод команды git log --oneline -1:
890d8c7 (HEAD -> feature/lab1) Add test file
DevOps-Intro % git cat-file -p HEAD
tree acbcc05204adfff0408be0df674cf6561b336101
parent 2e1ca634fbaa6eb5f3c19800b729091ea71bccfb
author Енотик Мечтатель <3451445@gmail.com> 1770919569 +0300
committer Енотик Мечтатель <3451445@gmail.com> 1770919569 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgNrjeJLLIAEuYzVtvIU802PGn0g
 /YyEBGeodgYebMkpsAAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQNfYw+9JTN6lOGz1V8YfK4LCUhkSa5kcZALmkmhZOClhyq7vOyZa1fHT3fD6EiWqlH
 Euw6c5k3s5665Nje0wrwk=
 -----END SSH SIGNATURE-----
Объяснение:
Commit объект хранит ссылку на tree (состояние файлов в момент коммита), родительский коммит, автора, коммиттера и сообщение коммита
Получаем tree объект из коммита:
git cat-file -p acbcc05204adfff0408be0df674cf6561b336101
100644 blob 6e60bebec0724892a7c82c52183d0a7b467cb6bb	README.md
040000 tree a1061247fd38ef2a568735939f86af7b1000f83c	app
040000 tree de057985c784762ca02f7f30e5b6d8881a50d619	labs
040000 tree d3fb3722b7a867a83efde73c57c49b5ab3e62c63	lectures
100644 blob 2eec599a1130d2ff231309bb776d1989b97c6ab2	test.txt
Объяснение:
Tree объект представляет собой каталог файлов и папок. Он содержит ссылки на blob объекты (файлы) и другие tree объекты (подкаталоги) с правами доступа и SHA-1 хешами.
git cat-file -p 6e60bebec0724892a7c82c52183d0a7b467cb6bb
# 🚀 DevOps Introduction Course: Principles, Practices & Tooling
Welcome to the **DevOps Introduction Course**...
j1@MacBook-Pro-j labs % git cat-file -p 2eec599a1130d2ff231309bb776d1989b97c6ab2
Test content
Объяснение:
Blob объект хранит содержимое файла, без информации о его имени или расположении в дереве. Tree объекты связывают имена файлов с blob объектами.
Анализ хранения данных в Git
	1.	Blob — хранит данные файла.
	2.	Tree — хранит структуру каталогов и связи между файлами и подкаталогами.
	3.	Commit — хранит снимок состояния репозитория (ссылку на tree), метаданные коммита и ссылку на родителя.

Вывод:
Git хранит все данные в виде объектов, каждый объект идентифицируется уникальным SHA-1 хешем. Система объектов позволяет эффективно отслеживать изменения, создавать ветки и восстанавливать историю.
# Task 2 — Reset and Reflog Recovery

## Цель
Изучить работу `git reset` и `git reflog` для навигации по истории и восстановления состояния репозитория.

---

## 2.1 Создание тренировочной ветки

### Выполненные команды

```bash
git switch -c git-reset-practice

echo "First commit" > file.txt
git add file.txt
git commit -m "First commit"

echo "Second commit" >> file.txt
git add file.txt
git commit -m "Second commit"

echo "Third commit" >> file.txt
git add file.txt
git commit -m "Third commit"
git log --oneline
e8c2b55 (HEAD -> git-reset-practice) Third commit
28ba320 Second commit
1fb0069 First commit
Объяснение:
Была создана отдельная ветка для экспериментов с reset и добавлено три коммита для проверки работы различных режимов сброса.

git reset --soft HEAD~1
Что произошло:
	•	HEAD переместился на commit Second commit
	•	Index (staging area) остался без изменений
	•	Working tree остался без изменений
	•	изменения из третьего коммита остались staged
labs % git log --oneline
28ba320 (HEAD -> git-reset-practice) Second commit
1fb0069 First commit
labs % git reset --hard HEAD~1
HEAD is now at 1fb0069 First commit
Что произошло:
	•	HEAD переместился на commit First commit
	•	Index очищен
	•	Working tree возвращён к состоянию первого коммита
	•	изменения второго и третьего коммита исчезли
 labs % git log --oneline
1fb0069 (HEAD -> git-reset-practice) First commit
git reflog
1fb0069 (HEAD -> git-reset-practice) HEAD@{0}: reset: moving to HEAD~1
28ba320 HEAD@{1}: reset: moving to HEAD~1
e8c2b55 HEAD@{2}: commit: Third commit
28ba320 HEAD@{3}: commit: Second commit
1fb0069 (HEAD -> git-reset-practice) HEAD@{4}: commit: First commit
Объяснение:
Reflog сохраняет все перемещения HEAD, даже после hard reset.
labs % git reset --hard e8c2b55
HEAD is now at e8c2b55 Third commit
Что произошло:
	•	HEAD вернулся на Third commit
	•	Working tree восстановлен
	•	Index восстановлен
	•	файл снова содержит все изменения
labs % git log --oneline
e8c2b55 (HEAD -> git-reset-practice) Third commit
28ba320 Second commit
1fb0069 First commit
Вывод:
	•	--soft отменяет коммит, но сохраняет изменения
	•	--hard полностью откатывает состояние
	•	git reflog позволяет восстановить даже удалённые коммиты

## Task 3 — Visualize Commit History

### Выполненные команды

```bash
git switch -c side-branch
echo "Branch commit" >> history.txt
git add history.txt
git commit -m "Side branch commit"
git switch -
j1@MacBook-Pro-j DevOps-Intro % git log --oneline --graph --all
* 80cea12 (side-branch) Side branch commit
* 3715a2f (HEAD -> git-reset-practice) docs: update submission2 task2
* e8c2b55 Third commit
* 28ba320 Second commit
* 1fb0069 First commit
* 890d8c7 (feature/lab1) Add test file
Side branch commit
docs: update submission2 task2
Third commit
Second commit
First commit
Add test file
Git log graph позволяет наглядно увидеть структуру веток и историю изменений.
Он помогает быстро понять, где создавались новые ветки и как перемещается HEAD между коммитами.
## Task 4 — Tagging Commits

### Теги и команды

Объяснение

Lightweight tag — это просто указатель на конкретный коммит.
Он не содержит дополнительной информации (автор, дата, сообщение).
j1@MacBook-Pro-j DevOps-Intro % git tag
v1.0.0
v1.1.0
Теги используются для фиксации важных состояний проекта — чаще всего релизов (например, v1.0.0, v1.1.0).

Они важны по следующим причинам:
	•	Версионирование — позволяют явно обозначить стабильные версии проекта и упрощают навигацию по истории.
	•	CI/CD процессы — многие системы автоматической сборки и деплоя запускаются при создании или публикации нового тега.
	•	Release notes — GitHub и другие платформы формируют страницы релизов на основе тегов.
	•	Воспроизводимость — тег всегда указывает на конкретный коммит, что позволяет точно восстановить состояние проекта в момент релиза.
	•	Стабильность — в отличие от веток, теги не перемещаются и служат постоянной ссылкой на зафиксированную версию кода.

Таким образом, теги являются важным инструментом управления версиями и организации процесса разработки.
## Task 5 — git switch vs git checkout vs git restore

## git switch

DevOps-Intro % git switch -c cmd-compare
Switched to a new branch 'cmd-compare'
j1@MacBook-Pro-j DevOps-Intro % git branch
* cmd-compare
  feature/lab1
  git-reset-practice
  main
  side-branch
j1@MacBook-Pro-j DevOps-Intro % git switch -                                                
Switched to branch 'git-reset-practice'
Your branch is ahead of 'origin/git-reset-practice' by 1 commit.
  (use "git push" to publish your local commits)
j1@MacBook-Pro-j DevOps-Intro % git switch -
Switched to branch 'cmd-compare'
j1@MacBook-Pro-j DevOps-Intro % git switch -
Switched to branch 'git-reset-practice'

Команда git branch показывает, что активная ветка изменилась 

## git checkout
j1@MacBook-Pro-j DevOps-Intro % git checkout -b cmd-compare-2
git branch
Switched to a new branch 'cmd-compare-2'
  cmd-compare
* cmd-compare-2
  feature/lab1
  git-reset-practice
  main
  side-branch
Активная ветка изменилась, аналогично git switch.
## git restore

echo "scratch" >> demo.txt
git status
j1@MacBook-Pro-j DevOps-Intro % git restore demo.txt
git status
On branch cmd-compare-2
Your branch is ahead of 'origin/cmd-compare-2' by 2 commits.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
git switch используется для создания и переключения веток.
git restore применяется для отмены изменений в файлах и работы со staging area.
git checkout является устаревшей универсальной командой, объединяющей обе функции.
## GitHub Community

Я выделил репозиторий курсов и проект simple-container-com/api, чтобы поддержать полезные инструменты с открытым исходным кодом и добавить их в закладки для дальнейшего использования. Репозитории, выделенные в качестве основных, повышают узнаваемость, поощряют разработчиков и свидетельствуют о доверии сообщества.

Я следил за преподавателем, техническим персоналом и однокурсниками, чтобы быть в курсе их работы. Наблюдение за разработчиками улучшает сотрудничество, поддерживает нетворкинг и помогает профессиональному росту.