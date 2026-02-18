from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from sqlalchemy import create_engine, text

app = FastAPI()

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