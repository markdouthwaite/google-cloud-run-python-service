def test_index(client):
    response = client.get("/")
    assert response.data == b"hello, world!"


def test_ping(client):
    response = client.get("/ping")
    assert response.data == b"ok"
