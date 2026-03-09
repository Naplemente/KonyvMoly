print("EZ A MAIN FUT")

import os
import bcrypt
from fastapi import FastAPI, Request, Form, Body
from fastapi.responses import RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from sqlalchemy import create_engine, text
from starlette.middleware.sessions import SessionMiddleware

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

# =========================
# DASHBOARD
# =========================
@app.get("/")
def dashboard(request: Request):
    role = request.session.get("role")

    if not request.session.get("user_id"):
        return RedirectResponse("/login", status_code=302)

    if role == "user":
        return RedirectResponse("/kolcsonzo", status_code=302)

    return templates.TemplateResponse("index.html", {
        "request": request,
        "nev": request.session.get("nev"),
        "role": role
    })

# =========================
# LOGIN
# =========================
@app.get("/login")
def login_get(request: Request):
    return templates.TemplateResponse("login.html", {"request": request})

@app.post("/login")
async def login_post(request: Request,
                     email: str = Form(None),
                     password: str = Form(None)):

    if not email or not password:
        return templates.TemplateResponse("login.html", {
            "request": request,
            "error": "Hiányzó adatok"
        })

    with engine.connect() as conn:
        user = conn.execute(
            text("SELECT * FROM felhasznalok WHERE email = :email"),
            {"email": email}
        ).fetchone()

    if user and bcrypt.checkpw(password.encode(), user.jelszo_hash.encode()):
        request.session["user_id"] = user.id
        request.session["role"] = user.role
        request.session["nev"] = user.nev

        if user.role == "user":
            return RedirectResponse("/kolcsonzo", status_code=302)

        return RedirectResponse("/", status_code=302)

    return templates.TemplateResponse("login.html", {
        "request": request,
        "error": "Hibás email vagy jelszó"
    })

# =========================
# LOGOUT
# =========================
@app.get("/logout")
def logout(request: Request):
    request.session.clear()
    return RedirectResponse("/login", status_code=302)

# =========================
# KÖNYVEK LISTÁZÁSA
# =========================
@app.get("/konyvek")
def konyvek_lista():
    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT
                k.id,
                k.cim,
                s.nev AS szerzo,
                k.kiadas_eve
            FROM konyvek k
            JOIN szerzok s ON k.szerzo_id = s.id
        """))

        konyvek = []
        for row in result:
            konyvek.append({
                "id": row.id,
                "title": row.cim,
                "author": row.szerzo,
                "year": row.kiadas_eve
            })

        return konyvek

# =========================
# KÖNYV HOZZÁADÁS
# =========================
@app.post("/konyv-hozzaadas")
def konyv_hozzaadas(konyv: dict = Body(...)):

    with engine.begin() as conn:

        # 1️⃣ Szerző keresése
        szerzo = conn.execute(
            text("SELECT id FROM szerzok WHERE nev = :nev"),
            {"nev": konyv["author"]}
        ).fetchone()

        # 2️⃣ Ha nincs, létrehozzuk
        if not szerzo:
            conn.execute(
                text("INSERT INTO szerzok (nev) VALUES (:nev)"),
                {"nev": konyv["author"]}
            )

            szerzo = conn.execute(
                text("SELECT id FROM szerzok WHERE nev = :nev"),
                {"nev": konyv["author"]}
            ).fetchone()

        # 3️⃣ Könyv beszúrás
        conn.execute(text("""
            INSERT INTO konyvek (cim, szerzo_id, kiadas_eve, letrehozas_datuma)
            VALUES (:cim, :szerzo_id, :ev, NOW())
        """), {
            "cim": konyv["title"],
            "szerzo_id": szerzo.id,
            "ev": konyv["year"]
        })

    return {"uzenet": "Könyv hozzáadva"}

# =========================
# KÖNYV TÖRLÉS
# =========================
@app.delete("/konyv-torles/{konyv_id}")
def konyv_torles(konyv_id: int, request: Request):

    role = request.session.get("role")

    if role not in ["admin", "superadmin"]:
        return {"error": "Nincs jogosultság"}

    with engine.begin() as conn:
        conn.execute(
            text("DELETE FROM konyvek WHERE id = :id"),
            {"id": konyv_id}
        )

    return {"uzenet": "Könyv törölve"}