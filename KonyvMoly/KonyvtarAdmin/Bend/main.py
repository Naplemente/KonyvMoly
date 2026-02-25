print("EZ A MAIN FUT")

import os
from fastapi import FastAPI, Request, Form
from fastapi.responses import RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from sqlalchemy import create_engine, text
from starlette.middleware.sessions import SessionMiddleware
import bcrypt

app = FastAPI()

# ====== SESSION ======
app.add_middleware(SessionMiddleware, secret_key="nagyon_titkos_kulcs")

# ====== TEMPLATE ======
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
templates = Jinja2Templates(directory=os.path.join(BASE_DIR, "templates"))

# ====== STATIC ======
app.mount("/static", StaticFiles(directory="static"), name="static")

# ====== ADATBÁZIS ======
engine = create_engine("mysql+pymysql://root:@localhost/konyvek_adatbazis")

# ====== FŐOLDAL ======
@app.get("/")
def index(request: Request):
    if not request.session.get("user"):
        return RedirectResponse("/login", status_code=302)
    return templates.TemplateResponse("index.html", {"request": request})

# ====== LOGIN ======
@app.post("/login")
def login_post(request: Request, username: str = Form(...), password: str = Form(...)):

    with engine.connect() as conn:
        user = conn.execute(
            text("SELECT * FROM admin_users WHERE username = :username"),
            {"username": username}
        ).fetchone()

    if user and bcrypt.checkpw(password.encode(), user.password.encode()):
        request.session["user"] = user.username
        request.session["role"] = user.role
        return RedirectResponse("/", status_code=302)

    return templates.TemplateResponse("login.html", {
        "request": request,
        "error": True
    })

# ====== GET – Könyvek ======
@app.get("/konyvek")
def konyvek_lista():
    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT id, cim, szerzo, kiadas_eve, elerheto FROM konyvek
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

# ====== PUT – Kölcsönzés ======
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
        conn.execute(text("DELETE FROM konyvek WHERE id = :id"),
                     {"id": konyv_id})
        conn.commit()
    return {"uzenet": "Könyv törölve"}

@app.get("/adminok")
def admin_kezel(request: Request):
    if request.session.get("role") != "superadmin":
        return RedirectResponse("/", status_code=303)

    with engine.connect() as conn:
        result = conn.execute(text("SELECT id, username, role FROM admin_users"))
        adminok = result.fetchall()

    return templates.TemplateResponse(
        "adminok.html",
        {"request": request, "adminok": adminok}
    )

@app.post("/admin-letrehozas")
def admin_letrehozas(
    request: Request,
    username: str = Form(...),
    password: str = Form(...),
    role: str = Form(...)
):

    if request.session.get("role") != "superadmin":
        return RedirectResponse("/", status_code=302)

    with engine.connect() as conn:

        existing = conn.execute(
            text("SELECT id FROM admin_users WHERE username = :username"),
            {"username": username}
        ).fetchone()

        if existing:
            return templates.TemplateResponse("adminok.html", {
                "request": request,
                "error": "Ez a felhasználónév már létezik!"
            })

        # 🔐 HASH készítése
        hashed_password = bcrypt.hashpw(
            password.encode(),
            bcrypt.gensalt()
        ).decode()

        conn.execute(text("""
            INSERT INTO admin_users (username, password, role)
            VALUES (:username, :password, :role)
        """), {
            "username": username,
            "password": hashed_password,
            "role": role
        })

        conn.commit()

    return RedirectResponse("/adminok", status_code=302)