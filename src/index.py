from flask import Blueprint

index = Blueprint("index", __name__, url_prefix="/index")


@index.get("/", strict_slashes=False)
def hello_world():
    return "hello, world!"
