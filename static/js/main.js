document.addEventListener("DOMContentLoaded", () => {
    betoltKonyvek();
    betoltFelhasznalok();
    betoltPeldanyok();
    betoltKolcsonzesek();
    betoltHistory();

    document.getElementById("kereso").addEventListener("input", function () {
        const keresett = this.value.toLowerCase();

        const szurt = osszesKonyv.filter(k =>
            k.title.toLowerCase().includes(keresett) ||
            k.author.toLowerCase().includes(keresett)
        );

        kirajzolKonyvek(szurt);
    });

    document.getElementById("konyv-form").addEventListener("submit", ujKonyvHozzaadas);
    document.getElementById("kolcsonzes-form").addEventListener("submit", kolcsonzes);
});

let osszesKonyv = [];


// =====================
// KÖLCSÖNZÉS
// =====================
function kolcsonzes(e) {
    e.preventDefault();

    const form = new FormData();
    form.append("felhasznalo_id", document.getElementById("user").value);
    form.append("peldany_id", document.getElementById("peldany").value);
    form.append("hatarido", document.getElementById("hatarido").value);

    fetch("/kolcsonzes", {
        method: "POST",
        body: form
    })
        .then(res => res.json())
        .then(data => {
            alert(data.message);
            betoltPeldanyok();
            betoltKolcsonzesek();
        })
        .catch(() => alert("Hiba a kölcsönzésnél!"));
}


// =====================
// FELHASZNÁLÓK
// =====================
function betoltFelhasznalok() {
    fetch("/felhasznalok")
        .then(res => res.json())
        .then(users => {

            // 🔥 FIX: ne legyen fals hiba
            console.log("Felhasználók:", users);

            if (!Array.isArray(users)) {
                console.error("Nem tömb jött:", users);
                return;
            }

            const select = document.getElementById("user");
            select.innerHTML = "";

            users.forEach(u => {
                const option = document.createElement("option");
                option.value = u.id;
                option.textContent = u.name;
                select.appendChild(option);
            });
        })
        .catch(() => console.error("Felhasználók betöltési hiba"));
}


// =====================
// PÉLDÁNYOK
// =====================
function betoltPeldanyok() {
    fetch("/peldanyok")
        .then(res => res.json())
        .then(peldanyok => {
            const select = document.getElementById("peldany");
            select.innerHTML = "";

            peldanyok.forEach(p => {
                const option = document.createElement("option");
                option.value = p.id;
                option.textContent = p.book + " (#" + p.id + ")";
                select.appendChild(option);
            });
        });
}


// =====================
// KÖNYVEK
// =====================
function betoltKonyvek() {
    fetch("/konyvek")
        .then(res => res.json())
        .then(konyvek => {
            osszesKonyv = konyvek;
            kirajzolKonyvek(konyvek);
        });
}


function kirajzolKonyvek(konyvek) {
    const tbody = document.getElementById("konyv-lista");
    tbody.innerHTML = "";

    konyvek.forEach(konyv => {
        const tr = document.createElement("tr");

        tr.innerHTML = `
            <td>${konyv.title}</td>
            <td>${konyv.author}</td>
            <td>${konyv.year}</td>
            <td>${konyv.available} / ${konyv.total}</td>
        `;

        const td = document.createElement("td");

        // ===== TÖRLÉS =====
        const deleteBtn = document.createElement("button");
        deleteBtn.textContent = "Törlés";
        deleteBtn.classList.add("danger");

        deleteBtn.onclick = () => {
            if (!confirm("Biztosan törlöd?")) return;

            fetch(`/konyv-torles/${konyv.id}`, {
                method: "DELETE"
            })
                .then(res => res.json())
                .then(data => {
                    alert(data.message);
                    betoltKonyvek();
                    betoltPeldanyok();
                    betoltKolcsonzesek();
                })
                .catch(() => alert("Hiba történt törlésnél!"));
        };

        // ===== - PÉLDÁNY =====
        const removeBtn = document.createElement("button");
        removeBtn.textContent = "-";
        removeBtn.classList.add("danger");

        if (konyv.available === 0) {
            removeBtn.disabled = true;
        }

        removeBtn.onclick = () => {
            const form = new FormData();
            form.append("konyv_id", konyv.id);

            fetch("/peldany-torol", {
                method: "POST",
                body: form
            })
                .then(res => res.json())
                .then(data => {
                    alert(data.message);

                    // 🔥 EZ HIÁNYZOTT NÁLAD
                    betoltKonyvek();
                    betoltPeldanyok();
                })
                .catch(() => alert("Hiba történt!"));
        };

        // ===== + PÉLDÁNY =====
        const addBtn = document.createElement("button");
        addBtn.textContent = "+";
        addBtn.classList.add("primary");

        addBtn.onclick = () => {
            const form = new FormData();
            form.append("konyv_id", konyv.id);
            form.append("darab", 1);

            fetch("/peldany-tobb", {
                method: "POST",
                body: form
            })
                .then(res => res.json())
                .then(() => {
                    betoltKonyvek();
                    betoltPeldanyok();
                });
        };

        td.appendChild(addBtn);
        td.appendChild(removeBtn);
        td.appendChild(deleteBtn);

        tr.appendChild(td);
        tbody.appendChild(tr);
    });
}


// =====================
// KÖNYV HOZZÁADÁS
// =====================
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
        .then(data => {
            alert(data.message);
            document.getElementById("konyv-form").reset();
            betoltKonyvek();
            betoltPeldanyok();
        })
        .catch(() => alert("Hiba könyv hozzáadásnál!"));
}


// =====================
// KÖLCSÖNZÉSEK
// =====================
function betoltKolcsonzesek() {
    fetch("/kolcsonzesek")
        .then(res => res.json())
        .then(lista => {
            const tbody = document.getElementById("kolcsonzes-lista");
            if (!tbody) return;

            tbody.innerHTML = "";
            const today = new Date();

            lista.forEach(k => {
                const deadline = new Date(k.deadline);
                const diffDays = Math.ceil((deadline - today) / (1000 * 60 * 60 * 24));

                let className = "";
                if (diffDays < 0) className = "lejart";
                else if (diffDays <= 3) className = "kozeli";
                else className = "ok";

                const tr = document.createElement("tr");
                tr.classList.add(className);

                tr.innerHTML = `
                    <td>${k.book}</td>
                    <td>${k.user}</td>
                    <td>${k.start}</td>
                    <td>${k.deadline}</td>
                    <td>
                        <button onclick="visszahoz(${k.id})">Visszahoz</button>
                    </td>
                `;

                tbody.appendChild(tr);
            });
        });
}


// =====================
// VISSZAHOZÁS
// =====================
function visszahoz(id) {
    fetch(`/visszahoz/${id}`, { method: "POST" })
        .then(() => {
            alert("Visszahozva!");
            betoltKolcsonzesek();
            betoltPeldanyok();
            betoltHistory();
        });
}


// =====================
// HISTORY
// =====================
function betoltHistory() {
    fetch("/kolcsonzesek-history")
        .then(res => res.json())
        .then(data => {
            const tbody = document.getElementById("history-lista");
            if (!tbody) return;

            tbody.innerHTML = "";

            data.forEach(k => {
                const tr = document.createElement("tr");

                tr.innerHTML = `
                    <td>${k.book}</td>
                    <td>${k.user}</td>
                    <td>${k.start}</td>
                    <td>${k.deadline}</td>
                    <td>${k.returned}</td>
                `;

                tbody.appendChild(tr);
            });

        });


}