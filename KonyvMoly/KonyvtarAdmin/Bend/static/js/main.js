document.addEventListener("DOMContentLoaded", () => {
    betoltKonyvek();

    document.getElementById("kereso")
  .addEventListener("input", function() {

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

function betoltKonyvek() {
    fetch("/konyvek")
        .then(res => res.json())
        .then(konyvek => {

            osszesKonyv = konyvek;
            kirajzolKonyvek(konyvek);

            const tbody = document.getElementById("konyv-lista");
            tbody.innerHTML = "";

            konyvek.forEach(konyv => {

                const tr = document.createElement("tr");

                tr.innerHTML = `
          <td>${konyv.title}</td>
          <td>${konyv.author}</td>
          <td class="${konyv.available ? 'elerheto' : 'kolcsonozve'}">
            ${konyv.available ? "Elérhető" : "Kikölcsönözve"}
          </td>
        `;

                const muveletTd = document.createElement("td");

                // ===== UPDATE =====
                const updateBtn = document.createElement("button");
                updateBtn.textContent = konyv.available ? "Kölcsönzés" : "Visszahozás";
                updateBtn.classList.add("primary");

                updateBtn.addEventListener("click", () => {
                    fetch(`/konyv-kolcsonzes/${konyv.id}`, {
                        method: "PUT"
                    })
                        .then(() => betoltKonyvek());
                });

                // ===== DELETE =====
                const deleteBtn = document.createElement("button");
                deleteBtn.textContent = "Törlés";
                deleteBtn.classList.add("danger");
                deleteBtn.style.marginLeft = "10px";

                deleteBtn.addEventListener("click", () => {
                    if (!confirm("Biztosan törölni szeretnéd?")) return;

                    fetch(`/konyv-torles/${konyv.id}`, {
                        method: "DELETE"
                    })
                        .then(() => betoltKonyvek());
                });

                muveletTd.appendChild(updateBtn);
                muveletTd.appendChild(deleteBtn);

                tr.appendChild(muveletTd);

                tbody.appendChild(tr);
            });
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
      <td class="${konyv.available ? 'elerheto' : 'kolcsonozve'}">
        ${konyv.available ? "Elérhető" : "Kikölcsönözve"}
      </td>
    `;

    const muveletTd = document.createElement("td");

    const updateBtn = document.createElement("button");
    updateBtn.textContent = konyv.available ? "Kölcsönzés" : "Visszahozás";
    updateBtn.classList.add("primary");

    updateBtn.addEventListener("click", () => {
      fetch(`/konyv-kolcsonzes/${konyv.id}`, { method: "PUT" })
        .then(() => betoltKonyvek());
    });

    const deleteBtn = document.createElement("button");
    deleteBtn.textContent = "Törlés";
    deleteBtn.classList.add("danger");
    deleteBtn.style.marginLeft = "10px";

    deleteBtn.addEventListener("click", () => {
      if (!confirm("Biztosan törölni szeretnéd?")) return;

      fetch(`/konyv-torles/${konyv.id}`, { method: "DELETE" })
        .then(() => betoltKonyvek());
    });

    muveletTd.appendChild(updateBtn);
    muveletTd.appendChild(deleteBtn);
    tr.appendChild(muveletTd);

    tbody.appendChild(tr);
  });
}

function ujKonyvHozzaadas(e) {
    e.preventDefault();

    const ujKonyv = {
        title: document.getElementById("title").value,
        author: document.getElementById("author").value,
        year: parseInt(document.getElementById("year").value),
        available: true
    };

    fetch("/konyv-hozzaadas", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(ujKonyv)
    })
        .then(() => {
            document.getElementById("konyv-form").reset();
            betoltKonyvek();
        });

    async function loadStats() {
    const res = await fetch("/statisztika");
    const data = await res.json();

    document.getElementById("stats").innerHTML = `
        <div class="card">📚 Összes könyv: <strong>${data.osszes}</strong></div>
        <div class="card">✅ Elérhető: <strong>${data.elerheto}</strong></div>
        <div class="card">📕 Kölcsönzött: <strong>${data.kolcsonzott}</strong></div>
    `;
}

loadStats();
}