from fastapi import FastAPI, Request, Form
from fastapi.responses import RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.middleware.sessions import SessionMiddleware
from sqlalchemy import create_engine, text
import bcrypt
import os

app = FastAPI()

# PATRIK HASH KÓDJA: $2b$12$/MeRllpTPYWWhFLoNavdYOTDdE.AGi89cOce6lDMlP6g69Or2UNsq

# ===============================
# SESSION
# ===============================
app.add_middleware(SessionMiddleware, secret_key="nagyon_titkos_kulcs")

# ===============================
# TEMPLATE
# ===============================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
templates = Jinja2Templates(directory=os.path.join(BASE_DIR, "templates"))

# ===============================
# STATIC
# ===============================
app.mount("/static", StaticFiles(directory="static"), name="static")

# ===============================
# ADATBÁZIS
# ===============================
engine = create_engine("mysql+pymysql://root:@localhost/konyvtar")


# ===============================
# SEGÉDFÜGGVÉNY
# ===============================
def is_logged_in(request: Request):
    return request.session.get("admin")


# ===============================
# DASHBOARD
# ===============================
@app.get("/")
def admin_dashboard(request: Request):
    if not is_logged_in(request):
        return RedirectResponse("/login", status_code=303)

    return templates.TemplateResponse(
        "index.html",
        {"request": request}
    )


# ===============================
# LOGIN
# ===============================
@app.get("/login")
def login_get(request: Request):
    return templates.TemplateResponse(
        "login.html",
        {"request": request, "error": False}
    )


@app.post("/login")
def login_post(request: Request,
               username: str = Form(...),
               password: str = Form(...)):
    with engine.connect() as conn:
        result = conn.execute(
            text("SELECT * FROM admin_users WHERE username = :username"),
            {"username": username}
        ).fetchone()

    if result and bcrypt.checkpw(password.encode(), result.password.encode()):
        request.session["admin"] = result.username
        request.session["role"] = result.role
        return RedirectResponse("/", status_code=303)

    return templates.TemplateResponse(
        "login.html",
        {"request": request, "error": True}
    )


def get_current_user(request: Request):
    return request.session.get("admin")


def is_superadmin(request: Request):
    return request.session.get("role") == "superadmin"


# ===============================
# LOGOUT
# ===============================
@app.get("/logout")
def logout(request: Request):
    request.session.clear()
    return RedirectResponse("/login", status_code=303)


# ===============================
# STATISZTIKA
# ===============================
@app.get("/statisztika")
def statisztika(request: Request):
    if not is_logged_in(request):
        return RedirectResponse("/login", status_code=303)

    with engine.connect() as conn:
        total = conn.execute(text("SELECT COUNT(*) FROM konyvek")).scalar()
        available = conn.execute(
            text("SELECT COUNT(*) FROM konyvek WHERE elerheto = 1")
        ).scalar()
        borrowed = conn.execute(
            text("SELECT COUNT(*) FROM konyvek WHERE elerheto = 0")
        ).scalar()

    return {
        "osszes": total,
        "elerheto": available,
        "kolcsonzott": borrowed
    }


# ===============================
# KÖNYVEK LISTA
# ===============================
@app.get("/konyvek")
def konyvek_lista(request: Request):
    if not is_logged_in(request):
        return RedirectResponse("/login", status_code=303)

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

@app.post("/admin-letrehozas")
def admin_letrehozas(request: Request,
                     username: str = Form(...),
                     password: str = Form(...),
                     role: str = Form(...)):

    if request.session.get("role") != "superadmin":
        return RedirectResponse("/", status_code=303)

    with engine.connect() as conn:
        existing = conn.execute(
            text("SELECT id FROM admin_users WHERE username = :username"),
            {"username": username}
        ).fetchone()

        if existing:
            return templates.TemplateResponse(
                "adminok.html",
                {
                    "request": request,
                    "adminok": conn.execute(
                        text("SELECT id, username, role FROM admin_users")
                    ).fetchall(),
                    "error": "Ez a felhasználónév már létezik!"
                }
            )

        hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

        conn.execute(
            text("""
                INSERT INTO admin_users (username, password, role)
                VALUES (:username, :password, :role)
            """),
            {
                "username": username,
                "password": hashed,
                "role": role
            }
        )
        conn.commit()

    return RedirectResponse("/adminok", status_code=303)

@app.get("/adminok")
def admin_kezel(request: Request):
    if request.session.get("role") != "superadmin":
        return RedirectResponse("/", status_code=303)

    with engine.connect() as conn:
        result = conn.execute(
            text("SELECT id, username, role FROM admin_users")
        )
        adminok = result.fetchall()

    return templates.TemplateResponse(
        "adminok.html",
        {"request": request, "adminok": adminok}
    )


# ===============================
# ÚJ KÖNYV
# ===============================
@app.post("/konyv-hozzaadas")
def konyv_hozzaadas(request: Request, konyv: dict):
    if not is_logged_in(request):
        return RedirectResponse("/login", status_code=303)

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

@app.post("/admin-torles/{admin_id}")
def admin_torles(request: Request, admin_id: int):

    if request.session.get("role") != "superadmin":
        return RedirectResponse("/", status_code=303)

    current_user = request.session.get("admin")

    with engine.connect() as conn:
        admin = conn.execute(
            text("SELECT username, role FROM admin_users WHERE id = :id"),
            {"id": admin_id}
        ).fetchone()

        if not admin:
            return RedirectResponse("/adminok", status_code=303)


        if admin.username == current_user:
            return RedirectResponse("/adminok", status_code=303)


        if admin.role == "superadmin":
            return RedirectResponse("/adminok", status_code=303)

        conn.execute(
            text("DELETE FROM admin_users WHERE id = :id"),
            {"id": admin_id}
        )
        conn.commit()

    return RedirectResponse("/adminok", status_code=303)

# ===============================
# KÖLCSÖNZÉS / VISSZAHOZÁS
# ===============================
@app.put("/konyv-kolcsonzes/{konyv_id}")
def konyv_kolcsonzes(request: Request, konyv_id: int):
    if not is_logged_in(request):
        return RedirectResponse("/login", status_code=303)

    with engine.connect() as conn:
        conn.execute(text("""
                          UPDATE konyvek
                          SET elerheto = NOT elerheto
                          WHERE id = :id
                          """), {"id": konyv_id})
        conn.commit()

    return {"uzenet": "Státusz frissítve"}


# ===============================
# TÖRLÉS
# ===============================
@app.delete("/konyv-torles/{konyv_id}")
def konyv_torles(request: Request, konyv_id: int):
    if not is_logged_in(request):
        return RedirectResponse("/login", status_code=303)

    with engine.connect() as conn:
        conn.execute(
            text("DELETE FROM konyvek WHERE id = :id"),
            {"id": konyv_id}
        )
        conn.commit()

    return {"uzenet": "Könyv törölve"}
