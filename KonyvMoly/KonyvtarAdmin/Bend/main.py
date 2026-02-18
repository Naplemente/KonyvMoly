from fastapi import FastAPI, Request, Form
from fastapi.responses import RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.middleware.sessions import SessionMiddleware
from sqlalchemy import create_engine, text
import bcrypt
import os

app = FastAPI()

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
# ADMIN JELSZÓ HASH (1234)
# ===============================
ADMIN_PASSWORD_HASH = bcrypt.hashpw("1234".encode(), bcrypt.gensalt())

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
def login_post(
    request: Request,
    username: str = Form(...),
    password: str = Form(...)
):
    if username == "admin" and bcrypt.checkpw(
        password.encode(),
        ADMIN_PASSWORD_HASH
    ):
        request.session["admin"] = username
        return RedirectResponse("/", status_code=303)

    return templates.TemplateResponse(
        "login.html",
        {"request": request, "error": True}
    )


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
        available = conn.execute(text("SELECT COUNT(*) FROM konyvek WHERE elerheto = 1")).scalar()
        borrowed = conn.execute(text("SELECT COUNT(*) FROM konyvek WHERE elerheto = 0")).scalar()

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