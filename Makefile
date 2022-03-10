.PHONY: deploy, test, install, install-dev

install:
	@pip install -r requirements.txt

install-dev: install
	@pip install -r requirements-dev.txt

develop: install-dev
	@python main.py --reload

deploy:
	@gcloud builds submit --substitutions=_REGION=$REGION

test:
	@pytest .
