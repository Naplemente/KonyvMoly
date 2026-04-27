import os
import secrets
import smtplib
from datetime import date, datetime, timedelta
from email.mime.text import MIMEText

from fastapi import Body, FastAPI, Form, Request
from fastapi.responses import RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from passlib.hash import bcrypt
from sqlalchemy import create_engine, text
from starlette.middleware.sessions import SessionMiddleware

app = FastAPI()
app.add_middleware(SessionMiddleware, secret_key="nagyon_titkos_kulcs")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
templates = Jinja2Templates(directory=os.path.join(BASE_DIR, "templates"))
app.mount("/static", StaticFiles(directory="static"), name="static")

engine = create_engine("mysql+pymysql://konyvtar:almafa@localhost/konyvek_adatbazis")


def hash_pw(pw: str) -> str:
    return bcrypt.hash(pw)


def verify_pw(pw: str, hashed: str) -> bool:
    return bcrypt.verify(pw, hashed)


def is_logged_in(request: Request) -> bool:
    return request.session.get("user") is not None


def is_admin(request: Request) -> bool:
    return request.session.get("role") in ["admin", "superadmin"]


# =====================
# EMAIL
# =====================
def kuld_email(cim: str, konyv: str) -> None:
    html = f"""
    <html>
    <body style="margin:0; padding:0; background:#f4f6f8; font-family: Arial, sans-serif;">

        <div style="max-width:600px; margin:30px auto; background:white; border-radius:12px; overflow:hidden; box-shadow:0 4px 20px rgba(0,0,0,0.1);">
            <div style="background:linear-gradient(135deg, #3498db, #2c3e50); padding:20px; color:white;">
                <h2 style="margin:0;">📚 KönyvMoly rendszer</h2>
                <p style="margin:5px 0 0 0; opacity:0.8;">Lejárati értesítés</p>
            </div>

            <div style="padding:25px;">
                <p style="font-size:16px;">Szia 👋</p>

                <div style="background:#ecf5ff; border-left:5px solid #3498db; padding:15px; border-radius:8px; margin:20px 0;">
                    <strong style="font-size:18px;">{konyv}</strong>
                </div>

                <div style="background:#fff3cd; padding:12px; border-radius:8px; margin-bottom:20px;">
                    ⏰ Ne felejtsd el visszahozni vagy hosszabbítani!
                </div>

                <div style="text-align:center; margin:25px 0;">
                    <a href="https://murkoff.org/"
                       style="background:#3498db; color:white; padding:12px 20px; text-decoration:none; border-radius:8px; font-weight:bold;">
                        Megnyitás 📖
                    </a>
                </div>

                <hr>
                <p style="font-size:12px; color:#999;">
                    Ez egy automatikus üzenet a KönyvMoly rendszerétől, így kérlek ne válaszolj rá.
                </p>
            </div>
        </div>

    </body>
    </html>
    """

    msg = MIMEText(html, "html")
    msg["Subject"] = "📚 Könyv lejárati értesítés"
    msg["From"] = "konyvmolyadmin@gmail.com"
    msg["To"] = cim

    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.starttls()
        server.login("konyvmolyadmin@gmail.com", "ggjy rnky dcqh pnos")
        server.send_message(msg)


# =====================
# ÉRTESÍTÉS
# =====================
@app.get("/ertesitesek")
def ertesitesek(request: Request):
    if not is_logged_in(request):
        return RedirectResponse("/login", status_code=302)

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT f.email, k.cim, kol.visszahozas_datum
            FROM kolcsonzesek kol
            JOIN peldanyok p ON kol.peldany_id = p.id
            JOIN konyvek k ON p.konyv_id = k.id
            JOIN felhasznalok f ON kol.felhasznalo_id = f.id
            WHERE kol.visszahozva IS NULL
        """))

        for r in result:
            diff = (r.visszahozas_datum - date.today()).days
            if diff <= 1:
                try:
                    kuld_email(r.email, f"A(z) '{r.cim}' könyved ma/holnap lejár! 📚")
                except Exception as e:
                    print("EMAIL HIBA:", e)

    return {"message": "Értesítések lefutottak"}


# =====================
# FŐOLDAL
# =====================
@app.get("/")
def index(request: Request):
    if not request.session.get("user"):
        return RedirectResponse("/login", status_code=302)

    if request.session.get("role") == "user":
        user = request.session.get("user")

        with engine.connect() as conn:
            result = conn.execute(text("""
                SELECT k.cim, kol.id, kol.kolcsonzes_datum,
                       kol.visszahozas_datum, kol.hosszabbitva
                FROM kolcsonzesek kol
                JOIN peldanyok p ON kol.peldany_id = p.id
                JOIN konyvek k ON p.konyv_id = k.id
                JOIN felhasznalok f ON kol.felhasznalo_id = f.id
                WHERE f.nev = :nev AND kol.visszahozva IS NULL
            """), {"nev": user})

            konyvek = []
            for r in result:
                diff = (r.visszahozas_datum - date.today()).days
                keses = abs(diff) * 100 if diff < 0 else 0
                konyvek.append(
                    {
                        "id": r.id,
                        "book": r.cim,
                        "start": str(r.kolcsonzes_datum),
                        "deadline": str(r.visszahozas_datum),
                        "diff": diff,
                        "hosszabbitva": r.hosszabbitva,
                        "keses": keses,
                    }
                )

        return templates.TemplateResponse(
            "user.html", {"request": request, "nev": user, "konyvek": konyvek}
        )

    return templates.TemplateResponse(
        "index.html",
        {
            "request": request,
            "nev": request.session.get("user"),
            "role": request.session.get("role"),
        },
    )


# =====================
# LOGIN
# =====================
@app.get("/login")
def login_get(request: Request):
    return templates.TemplateResponse("login.html", {"request": request})


@app.post("/login")
def login_post(request: Request, email: str = Form(...), password: str = Form(...)):
    if email == "superadmin" and password == "SuperAdmin321":
        request.session["user"] = "Superadmin"
        request.session["role"] = "superadmin"
        return RedirectResponse("/", status_code=302)

    with engine.connect() as conn:
        user = conn.execute(
            text("SELECT * FROM felhasznalok WHERE email=:email"), {"email": email}
        ).fetchone()

    if user:
        try:
            if verify_pw(password, user.jelszo_hash):
                request.session["user"] = user.nev
                request.session["role"] = user.role
                return RedirectResponse("/", status_code=302)
        except Exception as e:
            print("VERIFY HIBA:", e)

    return templates.TemplateResponse("login.html", {"request": request, "error": True})


@app.get("/logout")
def logout(request: Request):
    request.session.clear()
    return RedirectResponse("/login", status_code=302)


@app.get("/konyvek")
def konyvek_lista(request: Request):
    if not is_logged_in(request):
        return RedirectResponse("/login", status_code=302)

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT k.id,
                   k.cim,
                   s.nev AS szerzo,
                   k.kiadas_eve,
                   COUNT(p.id) AS osszes,
                   SUM(CASE
                        WHEN p.elerheto = TRUE AND p.aktiv = TRUE
                        THEN 1 ELSE 0
                   END) AS elerheto
            FROM konyvek k
            JOIN szerzok s ON k.szerzo_id = s.id
            LEFT JOIN peldanyok p ON p.konyv_id = k.id AND p.aktiv = TRUE
            WHERE k.torolt = FALSE
            GROUP BY k.id
        """))

    return [
        {
            "id": r.id,
            "title": r.cim,
            "author": r.szerzo,
            "year": r.kiadas_eve,
            "total": int(r.osszes or 0),
            "available": int(r.elerheto or 0),
        }
        for r in result
    ]


@app.post("/konyv-hozzaadas")
def konyv_hozzaadas(request: Request, konyv: dict = Body(...)):
    if not is_admin(request):
        return {"error": "Nincs jogosultság"}

    with engine.connect() as conn:
        szerzo = conn.execute(
            text("SELECT id FROM szerzok WHERE nev=:nev"), {"nev": konyv["author"]}
        ).fetchone()

        if not szerzo:
            conn.execute(text("INSERT INTO szerzok (nev) VALUES (:nev)"), {"nev": konyv["author"]})
            conn.commit()
            szerzo = conn.execute(
                text("SELECT id FROM szerzok WHERE nev=:nev"), {"nev": konyv["author"]}
            ).fetchone()

        conn.execute(
            text("""
            INSERT INTO konyvek (cim, szerzo_id, kiadas_eve)
            VALUES (:cim, :szerzo, :ev)
            """),
            {"cim": konyv["title"], "szerzo": szerzo.id, "ev": konyv["year"]},
        )
        conn.commit()

        konyv_id = conn.execute(text("SELECT LAST_INSERT_ID()")).fetchone()[0]
        conn.execute(
            text("""
            INSERT INTO peldanyok (konyv_id, allapot, elerheto, aktiv)
            VALUES (:id, 'uj', TRUE, TRUE)
            """),
            {"id": konyv_id},
        )
        conn.commit()

    return {"message": "Könyv + példány létrehozva"}


@app.get("/peldanyok")
def peldanyok(request: Request):
    if not is_logged_in(request):
        return RedirectResponse("/login", status_code=302)

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT p.id, k.cim
            FROM peldanyok p
            JOIN konyvek k ON p.konyv_id = k.id
            WHERE p.elerheto = TRUE
              AND p.aktiv = TRUE
        """))

    return [{"id": r.id, "book": r.cim} for r in result]


@app.post("/peldany-tobb")
def peldany_tobb(request: Request, konyv_id: int = Form(...), darab: int = Form(...)):
    if not is_admin(request):
        return {"error": "Nincs jogosultság"}

    with engine.connect() as conn:
        for _ in range(darab):
            conn.execute(
                text("""
                INSERT INTO peldanyok (konyv_id, allapot, elerheto, aktiv)
                VALUES (:id, 'uj', TRUE, TRUE)
                """),
                {"id": konyv_id},
            )
        conn.commit()

    return {"message": f"{darab} példány hozzáadva"}


@app.post("/peldany-torol")
def peldany_torol(konyv_id: int = Form(...)):
    with engine.connect() as conn:
        peldany = conn.execute(text("""
            SELECT id
            FROM peldanyok
            WHERE konyv_id = :id
              AND elerheto = TRUE
              AND aktiv = TRUE
            LIMIT 1
        """), {"id": konyv_id}).fetchone()

        if not peldany:
            return {"message": "Nincs törölhető példány!"}

        conn.execute(text("UPDATE peldanyok SET aktiv = FALSE WHERE id = :id"), {"id": peldany[0]})
        conn.commit()

    return {"message": "Példány deaktiválva"}


@app.post("/kolcsonzes")
def kolcsonzes(request: Request, peldany_id: int = Form(...), felhasznalo_id: int = Form(...), hatarido: str = Form(...)):
    if not is_admin(request):
        return {"error": "Nincs jogosultság"}

    with engine.connect() as conn:
        conn.execute(text("""
            INSERT INTO kolcsonzesek (peldany_id, felhasznalo_id, kolcsonzes_datum, visszahozas_datum)
            VALUES (:p, :u, CURDATE(), :h)
        """), {"p": peldany_id, "u": felhasznalo_id, "h": hatarido})
        conn.execute(text("UPDATE peldanyok SET elerheto = FALSE WHERE id = :id"), {"id": peldany_id})
        conn.commit()

    return {"message": "Kölcsönzés rögzítve"}


@app.get("/kolcsonzesek")
def kolcsonzesek(request: Request):
    if not is_logged_in(request):
        return RedirectResponse("/login", status_code=302)

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT kol.id, k.cim, f.nev, kol.kolcsonzes_datum, kol.visszahozas_datum
            FROM kolcsonzesek kol
            JOIN peldanyok p ON kol.peldany_id = p.id
            JOIN konyvek k ON p.konyv_id = k.id
            JOIN felhasznalok f ON kol.felhasznalo_id = f.id
            WHERE kol.visszahozva IS NULL
        """))

    return [
        {
            "id": r.id,
            "book": r.cim,
            "user": r.nev,
            "start": str(r.kolcsonzes_datum),
            "deadline": str(r.visszahozas_datum),
        }
        for r in result
    ]


@app.post("/visszahoz/{kolcsonzes_id}")
def visszahoz(request: Request, kolcsonzes_id: int):
    if not is_admin(request):
        return {"error": "Nincs jogosultság"}

    with engine.connect() as conn:
        peldany = conn.execute(
            text("SELECT peldany_id FROM kolcsonzesek WHERE id = :id"), {"id": kolcsonzes_id}
        ).fetchone()

        if not peldany:
            return {"message": "Nem található kölcsönzés"}

        conn.execute(text("UPDATE peldanyok SET elerheto = TRUE WHERE id = :id"), {"id": peldany.peldany_id})
        conn.execute(text("UPDATE kolcsonzesek SET visszahozva = NOW() WHERE id = :id"), {"id": kolcsonzes_id})
        conn.commit()

    return {"message": "Visszahozva"}


@app.get("/kolcsonzesek-history")
def kolcsonzesek_history(request: Request):
    if not is_logged_in(request):
        return RedirectResponse("/login", status_code=302)

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT k.cim, f.nev, kol.kolcsonzes_datum, kol.visszahozas_datum, kol.visszahozva
            FROM kolcsonzesek kol
            JOIN peldanyok p ON kol.peldany_id = p.id
            JOIN konyvek k ON p.konyv_id = k.id
            JOIN felhasznalok f ON kol.felhasznalo_id = f.id
            ORDER BY kol.kolcsonzes_datum DESC
        """))

    return [
        {
            "book": r.cim,
            "user": r.nev,
            "start": str(r.kolcsonzes_datum),
            "deadline": str(r.visszahozas_datum),
            "returned": str(r.visszahozva) if r.visszahozva else "Még kint",
        }
        for r in result
    ]


@app.get("/felhasznalok")
def felhasznalok(request: Request):
    if not is_admin(request):
        return RedirectResponse("/", status_code=302)

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT id, nev
            FROM felhasznalok
            WHERE role = 'user' AND torolt = FALSE
        """))

    return [{"id": r.id, "name": r.nev} for r in result]


@app.get("/adminok")
def adminok(request: Request):
    if not is_admin(request):
        return RedirectResponse("/", status_code=302)

    with engine.connect() as conn:
        adminok_list = conn.execute(text("""
            SELECT id, nev, role
            FROM felhasznalok
            WHERE torolt = FALSE
        """)).fetchall()

    return templates.TemplateResponse("adminok.html", {"request": request, "adminok": adminok_list})


@app.post("/admin-torles/{user_id}")
def admin_torles(request: Request, user_id: int):
    role = request.session.get("role")
    if role not in ["admin", "superadmin"]:
        return RedirectResponse("/", status_code=302)

    with engine.connect() as conn:
        user = conn.execute(text("SELECT id, role FROM felhasznalok WHERE id = :id"), {"id": user_id}).fetchone()
        if not user:
            return RedirectResponse("/adminok", status_code=302)

        if role == "admin" and user.role != "user":
            return RedirectResponse("/adminok", status_code=302)

        has_kolcsonzes = conn.execute(text("SELECT 1 FROM kolcsonzesek WHERE felhasznalo_id = :id LIMIT 1"), {"id": user_id}).fetchone()

        if has_kolcsonzes:
            conn.execute(text("UPDATE felhasznalok SET torolt = TRUE WHERE id = :id"), {"id": user_id})
        else:
            conn.execute(text("DELETE FROM felhasznalok WHERE id = :id"), {"id": user_id})

        conn.commit()

    return RedirectResponse("/adminok", status_code=302)


@app.post("/admin-letrehozas")
def admin_letrehozas(request: Request, nev: str = Form(...), email: str = Form(...), password: str = Form(...), role: str = Form(...)):
    session_role = request.session.get("role")
    if session_role not in ["admin", "superadmin"]:
        return RedirectResponse("/", status_code=302)

    if session_role == "admin":
        role = "user"

    with engine.connect() as conn:
        existing = conn.execute(text("SELECT id FROM felhasznalok WHERE email = :email"), {"email": email}).fetchone()
        if existing:
            adminok_list = conn.execute(text("SELECT id, nev, role FROM felhasznalok WHERE torolt = FALSE")).fetchall()
            return templates.TemplateResponse(
                "adminok.html",
                {"request": request, "error": "Ez az email már létezik!", "adminok": adminok_list},
            )

        hashed = hash_pw(password)
        conn.execute(text("""
            INSERT INTO felhasznalok (nev, email, jelszo_hash, regisztracio_datuma, role, torolt)
            VALUES (:nev, :email, :hash, NOW(), :role, FALSE)
        """), {"nev": nev, "email": email, "hash": hashed, "role": role})
        conn.commit()

    return RedirectResponse("/adminok?success=1", status_code=302)


@app.post("/hosszabbit/{kolcsonzes_id}")
def hosszabbit(request: Request, kolcsonzes_id: int):
    if not is_logged_in(request):
        return RedirectResponse("/login", status_code=302)

    with engine.connect() as conn:
        kol = conn.execute(text("SELECT visszahozas_datum, hosszabbitva FROM kolcsonzesek WHERE id = :id"), {"id": kolcsonzes_id}).fetchone()

        if not kol:
            return {"message": "Nem található!"}

        diff = (kol.visszahozas_datum - date.today()).days
        if kol.hosszabbitva:
            return {"message": "Már hosszabbítva lett!"}
        if diff < 0:
            return {"message": "Lejárt könyv nem hosszabbítható!"}
        if diff > 2:
            return {"message": "Csak lejárat előtt 2 nappal lehet hosszabbítani!"}

        conn.execute(text("""
            UPDATE kolcsonzesek
            SET visszahozas_datum = DATE_ADD(visszahozas_datum, INTERVAL 7 DAY),
                hosszabbitva = TRUE
            WHERE id = :id
        """), {"id": kolcsonzes_id})
        conn.commit()

    return {"message": "Sikeres hosszabbítás (+7 nap)"}


@app.post("/pont-noveles/{pont}")
def pont_noveles(request: Request, pont: int):
    if not is_logged_in(request):
        return RedirectResponse("/login", status_code=302)

    user = request.session.get("user")
    with engine.connect() as conn:
        conn.execute(text("UPDATE felhasznalok SET score = score + :pont WHERE nev = :nev"), {"pont": pont, "nev": user})
        conn.commit()

    return {"message": "Pont mentve"}


@app.get("/toplista")
def toplista(request: Request):
    if not is_logged_in(request):
        return RedirectResponse("/login", status_code=302)

    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT nev, score
            FROM felhasznalok
            WHERE torolt = FALSE
            ORDER BY score DESC
            LIMIT 10
        """))

    return [{"nev": r.nev, "score": r.score} for r in result]


# =====================
# KÖNYV TÖRLÉS (SOFT DELETE)
# =====================
@app.delete("/konyv-torles/{konyv_id}")
def konyv_torles(request: Request, konyv_id: int):
    if not is_admin(request):
        return {"error": "Nincs jogosultság"}

    try:
        with engine.connect() as conn:
            aktiv = conn.execute(text("""
                SELECT 1
                FROM kolcsonzesek kol
                JOIN peldanyok p ON kol.peldany_id = p.id
                WHERE p.konyv_id = :id
                  AND kol.visszahozva IS NULL
                LIMIT 1
            """), {"id": konyv_id}).fetchone()

            if aktiv:
                return {"message": "Nem törölhető! Van aktív kölcsönzés."}

            conn.execute(text("UPDATE peldanyok SET aktiv = FALSE WHERE konyv_id = :id"), {"id": konyv_id})
            conn.execute(text("UPDATE konyvek SET torolt = TRUE WHERE id = :id"), {"id": konyv_id})
            conn.commit()

        return {"message": "Könyv archiválva"}

    except Exception as e:
        print("HIBA:", e)
        return {"message": "Szerver hiba történt!"}


@app.get("/forgot-password")
def forgot_page(request: Request):
    return templates.TemplateResponse("forgot.html", {"request": request})


@app.post("/forgot-password")
def forgot_password(request: Request, email: str = Form(...)):
    with engine.connect() as conn:
        user = conn.execute(text("""
            SELECT id
            FROM felhasznalok
            WHERE email = :email AND torolt = FALSE
        """), {"email": email}).fetchone()

        if user:
            token = secrets.token_urlsafe(32)
            expiry = datetime.utcnow() + timedelta(hours=1)

            conn.execute(text("""
                UPDATE felhasznalok
                SET reset_token = :token, reset_expiry = :expiry
                WHERE email = :email
            """), {"token": token, "expiry": expiry, "email": email})
            conn.commit()

            link = f"https://murkoff.org/reset-password?token={token}"
            kuld_email(email, link)

    return templates.TemplateResponse(
        "forgot.html",
        {"request": request, "message": "Ha létezik az email, küldtünk linket"},
    )


@app.get("/reset-password")
def reset_form(request: Request, token: str):
    return templates.TemplateResponse("reset.html", {"request": request, "token": token})


@app.post("/reset-password")
def reset_password(request: Request, token: str = Form(...), password: str = Form(...)):
    with engine.connect() as conn:
        user = conn.execute(text("""
            SELECT id
            FROM felhasznalok
            WHERE reset_token = :token
              AND reset_expiry > NOW()
        """), {"token": token}).fetchone()

        if not user:
            return templates.TemplateResponse(
                "reset.html", {"request": request, "error": "Lejárt vagy hibás link"}
            )

        hashed = hash_pw(password)
        conn.execute(text("""
            UPDATE felhasznalok
            SET jelszo_hash = :hash,
                reset_token = NULL,
                reset_expiry = NULL
            WHERE id = :id
        """), {"hash": hashed, "id": user.id})
        conn.commit()

    return RedirectResponse("/login", status_code=302)
