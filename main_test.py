def test_index(client):
    response = client.get("/")
    assert response.data == b"ok"
