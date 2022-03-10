import os

from flask import Flask

from src import index

app = Flask(__name__)
app.register_blueprint(index)


@app.get("/ping")
def ping():
    return "ok"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=os.getenv("PORT"))
