.PHONY: test, install, install-dev

install:
	@pip install -r requirements/core-requirements.txt

install-dev: install
	@pip install -r requirements/dev-requirements.txt

develop: install-dev
	@python main.py --reload

test:
	@pytest .
