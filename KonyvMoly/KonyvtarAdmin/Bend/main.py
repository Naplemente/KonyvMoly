from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from sqlalchemy import create_engine, text
from fastapi import FastAPI, Request, Form
from fastapi.responses import RedirectResponse
from starlette.middleware.sessions import SessionMiddleware
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from sqlalchemy import create_engine, text
from fastapi import Request, Form
from fastapi.responses import RedirectResponse
from fastapi.templating import Jinja2Templates
import os
from fastapi.templating import Jinja2Templates
from starlette.middleware.sessions import SessionMiddleware
app = FastAPI()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

templates = Jinja2Templates(
    directory=os.path.join(BASE_DIR, "templates")
)


@app.get("/login")
def login_get(request: Request):
    return templates.TemplateResponse("login.html", {"request": request})


@app.post("/login")
def login_post(request: Request, username: str = Form(...), password: str = Form(...)):

    if username == "admin" and password == "1234":
        request.session["user"] = username
        return RedirectResponse("/", status_code=302)

    return templates.TemplateResponse("login.html", {
        "request": request,
        "error": True
    })

templates = Jinja2Templates(directory="templates")
# ====== TITKOSÍTÁS ======
app.add_middleware(SessionMiddleware, secret_key="nagyon_titkos_kulcs")

# ====== ADATBÁZIS KAPCSOLAT ======
engine = create_engine(
    "mysql+pymysql://root:@localhost/konyvtar"
)

# ====== GET – Könyvek lekérdezése ======
@app.get("/konyvek")
def konyvek_lista():
    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT id, cim, szerzo, kiadas_eve, elerheto
            FROM konyvek
        """))

        konyvek = []
        for row in result:
            konyvek.append({
                "id": row.id,
                "title": row.cim,
                "author": row.szerzo,
                "year": row.kiadas_eve,
                "available": row.elerheto
            })

    return konyvek


# ====== POST – Új könyv ======
@app.post("/konyv-hozzaadas")
def konyv_hozzaadas(konyv: dict):
    with engine.connect() as conn:
        conn.execute(text("""
            INSERT INTO konyvek (cim, szerzo, kiadas_eve, elerheto)
            VALUES (:cim, :szerzo, :ev, :elerheto)
        """), {
            "cim": konyv["title"],
            "szerzo": konyv["author"],
            "ev": konyv["year"],
            "elerheto": konyv["available"]
        })

        conn.commit()

    return {"uzenet": "Könyv hozzáadva"}


# ====== PUT – Kölcsönzés / Visszahozás ======
@app.put("/konyv-kolcsonzes/{konyv_id}")
def konyv_kolcsonzes(konyv_id: int):
    with engine.connect() as conn:
        conn.execute(text("""
            UPDATE konyvek
            SET elerheto = NOT elerheto
            WHERE id = :id
        """), {"id": konyv_id})

        conn.commit()

    return {"uzenet": "Státusz frissítve"}


# ====== DELETE – Törlés ======
@app.delete("/konyv-torles/{konyv_id}")
def konyv_torles(konyv_id: int):
    with engine.connect() as conn:
        conn.execute(
            text("DELETE FROM konyvek WHERE id = :id"),
            {"id": konyv_id}
        )
        conn.commit()

    return {"uzenet": "Könyv törölve"}


# ====== STATIC FILES ======
app.mount("/", StaticFiles(directory="static", html=True), name="static")