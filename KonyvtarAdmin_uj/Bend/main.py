import os
import bcrypt

from fastapi import FastAPI, Request, Form, Body
from fastapi.responses import RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from sqlalchemy import create_engine, text
from starlette.middleware.sessions import SessionMiddleware

app = FastAPI()

app.add_middleware(SessionMiddleware, secret_key="nagyon_titkos_kulcs")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

templates = Jinja2Templates(directory=os.path.join(BASE_DIR, "templates"))

app.mount("/static", StaticFiles(directory="static"), name="static")

engine = create_engine("mysql+pymysql://root:@localhost/konyvek_adatbazis")


# =====================
# FŐOLDAL
# =====================

@app.get("/")
def index(request: Request):
    if not request.session.get("user"):
        return RedirectResponse("/login", status_code=302)

    return templates.TemplateResponse(
        "index.html",
        {
            "request": request,
            "nev": request.session.get("user"),
            "role": request.session.get("role")
        }
    )


# =====================
# LOGIN
# =====================

@app.get("/login")
def login_get(request: Request):
    return templates.TemplateResponse("login.html", {"request": request})


@app.post("/login")
def login_post(request: Request, email: str = Form(...), password: str = Form(...)):

    if email == "superadmin" and password == "superadmin123":
        request.session["user"] = "Superadmin"
        request.session["role"] = "superadmin"
        return RedirectResponse("/", status_code=302)

    with engine.connect() as conn:
        user = conn.execute(
            text("SELECT * FROM felhasznalok WHERE email=:email"),
            {"email": email}
        ).fetchone()

    if user and bcrypt.checkpw(password.encode(), user.jelszo_hash.encode()):
        request.session["user"] = user.nev
        request.session["role"] = user.role
        return RedirectResponse("/", status_code=302)

    return templates.TemplateResponse("login.html", {"request": request, "error": True})


# =====================
# LOGOUT
# =====================

@app.get("/logout")
def logout(request: Request):
    request.session.clear()
    return RedirectResponse("/login", status_code=302)


# =====================
# KÖNYVEK LISTA
# =====================

@app.get("/konyvek")
def konyvek_lista():

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT k.id, k.cim, s.nev AS szerzo, k.kiadas_eve
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


# =====================
# KÖNYV HOZZÁADÁS
# =====================

@app.post("/konyv-hozzaadas")
def konyv_hozzaadas(konyv: dict = Body(...)):

    with engine.connect() as conn:

        szerzo = conn.execute(
            text("SELECT id FROM szerzok WHERE nev=:nev"),
            {"nev": konyv["author"]}
        ).fetchone()

        if not szerzo:
            conn.execute(
                text("INSERT INTO szerzok (nev) VALUES (:nev)"),
                {"nev": konyv["author"]}
            )
            conn.commit()

            szerzo = conn.execute(
                text("SELECT id FROM szerzok WHERE nev=:nev"),
                {"nev": konyv["author"]}
            ).fetchone()

        conn.execute(text("""
            INSERT INTO konyvek (cim, szerzo_id, kiadas_eve)
            VALUES (:cim, :szerzo, :ev)
        """), {
            "cim": konyv["title"],
            "szerzo": szerzo.id,
            "ev": konyv["year"]
        })

        conn.commit()

    return {"message": "Könyv hozzáadva"}


# =====================
# PÉLDÁNYOK
# =====================

@app.get("/peldanyok")
def peldanyok():

    with engine.connect() as conn:

        result = conn.execute(text("""
            SELECT p.id, k.cim
            FROM peldanyok p
            JOIN konyvek k ON p.konyv_id = k.id
            WHERE p.elerheto = TRUE
        """))

        data = []

        for row in result:
            data.append({
                "id": row.id,
                "book": row.cim
            })

    return data


# =====================
# FELHASZNÁLÓK
# =====================

@app.get("/felhasznalok")
def felhasznalok():

    with engine.connect() as conn:

        result = conn.execute(text("""
            SELECT id, nev
            FROM felhasznalok
            WHERE role='user'
        """))

        users = []

        for row in result:
            users.append({
                "id": row.id,
                "name": row.nev
            })

    return users


# =====================
# KÖLCSÖNZÉS
# =====================

@app.post("/kolcsonzes")
def kolcsonzes(
    peldany_id: int = Form(...),
    felhasznalo_id: int = Form(...),
    hatarido: str = Form(...)
):

    with engine.connect() as conn:

        conn.execute(text("""
            INSERT INTO kolcsonzesek
            (peldany_id, felhasznalo_id, kolcsonzes_datum, visszahozas_datum)
            VALUES (:p, :u, CURDATE(), :h)
        """), {
            "p": peldany_id,
            "u": felhasznalo_id,
            "h": hatarido
        })

        conn.execute(text("""
            UPDATE peldanyok
            SET elerheto = FALSE
            WHERE id = :id
        """), {"id": peldany_id})

        conn.commit()

    return {"message": "Kölcsönzés rögzítve"}


# =====================
# AKTÍV KÖLCSÖNZÉSEK
# =====================

@app.get("/kolcsonzesek")
def kolcsonzesek():

    with engine.connect() as conn:

        result = conn.execute(text("""
            SELECT
                kol.id,
                k.cim,
                f.nev,
                kol.kolcsonzes_datum,
                kol.visszahozas_datum
            FROM kolcsonzesek kol
            JOIN peldanyok p ON kol.peldany_id = p.id
            JOIN konyvek k ON p.konyv_id = k.id
            JOIN felhasznalok f ON kol.felhasznalo_id = f.id
        """))

        lista = []

        for row in result:
            lista.append({
                "id": row.id,
                "book": row.cim,
                "user": row.nev,
                "start": str(row.kolcsonzes_datum),
                "deadline": str(row.visszahozas_datum)
            })

    return lista


# =====================
# VISSZAHOZÁS
# =====================

@app.post("/visszahoz/{kolcsonzes_id}")
def visszahoz(kolcsonzes_id: int):

    with engine.connect() as conn:

        peldany = conn.execute(text("""
            SELECT peldany_id
            FROM kolcsonzesek
            WHERE id = :id
        """), {"id": kolcsonzes_id}).fetchone()

        conn.execute(text("""
            UPDATE peldanyok
            SET elerheto = TRUE
            WHERE id = :id
        """), {"id": peldany.peldany_id})

        conn.commit()

    return {"message": "Visszahozva"}