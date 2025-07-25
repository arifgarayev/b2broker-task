ifdef OS
	PYTHON ?= venv/Scripts/python.exe
	TYPE_CHECK_COMMAND ?= echo Pytype package doesn't support Windows OS
else
	PYTHON ?= venv/bin/python3
	TYPE_CHECK_COMMAND ?= ${PYTHON} -m pytype --config=pytype.cfg src
endif

SETTINGS_FILENAME = pyproject.toml
COMPOSE_FILENAME = docker-compose.yml
MANAGE_PY = src/b2broker/manage.py

enable-pre-commit-hooks:
	${PYTHON} -m pre_commit install

format:
	${PYTHON} -m isort src tests --force-single-line-imports --settings-file ${SETTINGS_FILENAME}
	${PYTHON} -m autoflake --remove-all-unused-imports --recursive --remove-unused-variables --in-place src tests --exclude=__init__.py
	${PYTHON} -m black src tests --config ${SETTINGS_FILENAME}
	${PYTHON} -m isort src tests --settings-file ${SETTINGS_FILENAME}

lint:
	${PYTHON} -m flake8 --toml-config ${SETTINGS_FILENAME} --max-complexity 5 --max-cognitive-complexity=5 src tests
	${PYTHON} -m black src tests --check --diff --config ${SETTINGS_FILENAME}
	${PYTHON} -m isort src tests --check --diff --settings-file ${SETTINGS_FILENAME}

secure:
	${PYTHON} -m bandit -r src tests --config ${SETTINGS_FILENAME}

run-migrations:
	${PYTHON} ${MANAGE_PY} makemigrations
	${PYTHON} ${MANAGE_PY} migrate

run-devserver:
	${PYTHON} ${MANAGE_PY} runserver

run-localgunicorn:
	./entrypoints/start.gunicorn.local.sh

run-prodgunicorn:
	./entrypoints/start.gunicorn.sh

run-build:
	docker-compose -f ${COMPOSE_FILENAME} down
	docker-compose -f ${COMPOSE_FILENAME} build
	docker-compose -f ${COMPOSE_FILENAME} up