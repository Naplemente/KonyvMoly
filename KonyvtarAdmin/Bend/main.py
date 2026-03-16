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
# LOGIN OLDAL
# =====================

@app.get("/login")
def login_get(request: Request):

    return templates.TemplateResponse(
        "login.html",
        {"request": request}
    )


# =====================
# LOGIN
# =====================

@app.post("/login")
def login_post(request: Request, email: str = Form(...), password: str = Form(...)):

    # SUPERADMIN (nincs DB-ben)
    if email == "superadmin" and password == "superadmin123":

        request.session["user"] = "Superadmin"
        request.session["role"] = "superadmin"

        return RedirectResponse("/", status_code=302)

    with engine.connect() as conn:

        user = conn.execute(
            text("SELECT * FROM felhasznalok WHERE email = :email"),
            {"email": email}
        ).fetchone()

    if user and bcrypt.checkpw(password.encode(), user.jelszo_hash.encode()):

        request.session["user"] = user.nev
        request.session["role"] = user.role

        return RedirectResponse("/", status_code=302)

    return templates.TemplateResponse(
        "login.html",
        {"request": request, "error": True}
    )


# =====================
# LOGOUT
# =====================

@app.get("/logout")
def logout(request: Request):

    request.session.clear()

    return RedirectResponse("/login", status_code=302)


# =====================
# KÖNYVEK LISTÁJA
# =====================

@app.get("/konyvek")
def konyvek_lista():

    with engine.connect() as conn:

        result = conn.execute(text("""
        SELECT id, cim, szerzo_id, kiadas_eve
        FROM konyvek
        """))

        konyvek = []

        for row in result:
            konyvek.append({
                "id": row.id,
                "title": row.cim,
                "author": row.szerzo_id,
                "year": row.kiadas_eve,
                "available": True
            })

    return konyvek


# =====================
# KÖNYV HOZZÁADÁS
# =====================

@app.post("/konyv-hozzaadas")
def konyv_hozzaadas(konyv: dict = Body(...)):

    with engine.connect() as conn:

        conn.execute(text("""
        INSERT INTO konyvek (cim, szerzo_id, kiadas_eve)
        VALUES (:cim, :szerzo, :ev)
        """), {
            "cim": konyv["title"],
            "szerzo": konyv["author"],
            "ev": konyv["year"]
        })

        conn.commit()

    return {"message": "Könyv hozzáadva"}


# =====================
# ADMIN PANEL
# =====================

@app.get("/adminok")
def adminok(request: Request):

    if request.session.get("role") != "superadmin":
        return RedirectResponse("/", status_code=302)

    success = request.query_params.get("success")

    with engine.connect() as conn:

        result = conn.execute(text("""
        SELECT id, nev, role
        FROM felhasznalok
        """))

        adminok = result.fetchall()

    return templates.TemplateResponse(
        "adminok.html",
        {
            "request": request,
            "adminok": adminok,
            "success": "Fiók sikeresen létrehozva!" if success else None
        }
    )


# =====================
# ADMIN LÉTREHOZÁS
# =====================

@app.post("/admin-letrehozas")
def admin_letrehozas(
    request: Request,
    nev: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    role: str = Form(...)
):

    if request.session.get("role") != "superadmin":
        return RedirectResponse("/", status_code=302)

    hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

    with engine.connect() as conn:

        conn.execute(text("""
        INSERT INTO felhasznalok
        (nev,email,jelszo_hash,regisztracio_datuma,role)
        VALUES (:nev,:email,:hash,NOW(),:role)
        """), {
            "nev": nev,
            "email": email,
            "hash": hashed,
            "role": role
        })

        conn.commit()

    return RedirectResponse("/adminok?success=1", status_code=302)


# =====================
# ADMIN TÖRLÉS
# =====================

@app.post("/admin-torles/{user_id}")
def admin_torles(user_id: int, request: Request):

    if request.session.get("role") != "superadmin":
        return RedirectResponse("/", status_code=302)

    with engine.connect() as conn:

        conn.execute(
            text("DELETE FROM felhasznalok WHERE id = :id"),
            {"id": user_id}
        )

        conn.commit()

    return RedirectResponse("/adminok", status_code=302)