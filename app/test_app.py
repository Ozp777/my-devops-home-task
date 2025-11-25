from main import app


def test_hello():
    client = app.test_client()
    resp = client.get("/")
    assert resp.status_code == 200
    assert resp.data.decode() == "Hello, DevOps!"


def test_echo():
    client = app.test_client()
    payload = {"msg": "test"}
    resp = client.post("/echo", json=payload)
    assert resp.status_code == 200
    assert resp.get_json() == payload
