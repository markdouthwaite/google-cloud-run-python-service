import pytest

from main import app as _app


@pytest.fixture()
def app():
    _app.config.update(
        {
            "TESTING": True,
        }
    )
    yield _app


@pytest.fixture()
def client(app):
    return app.test_client()
