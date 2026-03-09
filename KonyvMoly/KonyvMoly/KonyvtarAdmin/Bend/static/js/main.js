document.addEventListener("DOMContentLoaded", () => {
    betoltKonyvek();

    document.getElementById("kereso").addEventListener("input", function() {
        const keresett = this.value.toLowerCase();

        const szurt = osszesKonyv.filter(k =>
            k.title.toLowerCase().includes(keresett) ||
            k.author.toLowerCase().includes(keresett)
        );

        kirajzolKonyvek(szurt);
    });

    document.getElementById("konyv-form")
        .addEventListener("submit", ujKonyvHozzaadas);
});

let osszesKonyv = [];

// =======================
// Könyvek betöltése
// =======================
function betoltKonyvek() {
    fetch("/konyvek")
        .then(res => res.json())
        .then(konyvek => {
            osszesKonyv = konyvek;
            kirajzolKonyvek(konyvek);
        });
}

// =======================
// Könyvek kirajzolása
// =======================
function kirajzolKonyvek(konyvek) {
    const tbody = document.getElementById("konyv-lista");
    tbody.innerHTML = "";

    konyvek.forEach(konyv => {
        const tr = document.createElement("tr");

        tr.innerHTML = `
            <td>${konyv.title}</td>
            <td>${konyv.author}</td>
            <td>-</td>
        `;

        const muveletTd = document.createElement("td");

        const deleteBtn = document.createElement("button");
        deleteBtn.textContent = "Törlés";
        deleteBtn.classList.add("danger");
        deleteBtn.addEventListener("click", () => {
            if (!confirm("Biztosan törölni szeretnéd?")) return;

            fetch(`/konyv-torles/${konyv.id}`, {
                method: "DELETE"
            }).then(() => betoltKonyvek());
        });

        muveletTd.appendChild(deleteBtn);
        tr.appendChild(muveletTd);
        tbody.appendChild(tr);
    });
}

// =======================
// Új könyv hozzáadása
// =======================
function ujKonyvHozzaadas(e) {
    e.preventDefault();

    const ujKonyv = {
        title: document.getElementById("title").value,
        author: document.getElementById("author").value,
        year: parseInt(document.getElementById("year").value)
    };

    fetch("/konyv-hozzaadas", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(ujKonyv)
    })
    .then(res => res.json())
    .then(() => {
        document.getElementById("konyv-form").reset();
        betoltKonyvek();
    });
}