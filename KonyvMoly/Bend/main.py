from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

app = FastAPI()


@app.get("/konyvek")
def konyvek():
    return [
        {"title": "Egri csillagok", "author": "Gárdonyi Géza", "available": True},
        {"title": "Pál utcai fiúk", "author": "Molnár Ferenc", "available": False},
    ]


app.mount("/", StaticFiles(directory="static", html=True), name="static")