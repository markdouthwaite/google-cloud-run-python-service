.PHONY: test, install, install-dev

install:
	@pip install -r requirements.txt

install-dev: install
	@pip install -r requirements-dev.txt

develop: install-dev
	@python main.py --reload

test:
	@pytest .
