def test_index(client):
    response = client.get("/index/")
    assert response.data == b"hello, world!"
