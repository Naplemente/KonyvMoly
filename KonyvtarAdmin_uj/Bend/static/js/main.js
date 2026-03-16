document.addEventListener("DOMContentLoaded", () => {

    betoltKonyvek();
    betoltFelhasznalok();
    betoltPeldanyok();
    betoltKolcsonzesek();

    document.getElementById("kereso")
        .addEventListener("input", function () {

            const keresett = this.value.toLowerCase();

            const szurt = osszesKonyv.filter(k =>
                k.title.toLowerCase().includes(keresett) ||
                k.author.toLowerCase().includes(keresett)
            );

            kirajzolKonyvek(szurt);
        });

    document.getElementById("konyv-form")
        .addEventListener("submit", ujKonyvHozzaadas);

    document.getElementById("kolcsonzes-form")
        .addEventListener("submit", kolcsonzes);

});


let osszesKonyv = [];


function kolcsonzes(e){
    e.preventDefault()

    const form = new FormData()
    form.append("felhasznalo_id", document.getElementById("user").value)
    form.append("peldany_id", document.getElementById("peldany").value)
    form.append("hatarido", document.getElementById("hatarido").value)

    fetch("/kolcsonzes", {
        method: "POST",
        body: form
    })
    .then(res => res.json())
    .then(() => {
        alert("Kölcsönzés rögzítve!")
        betoltPeldanyok()
    })
}


function betoltFelhasznalok() {

    fetch("/felhasznalok")
        .then(res => res.json())
        .then(users => {

            const select = document.getElementById("user");

            select.innerHTML = "";

            users.forEach(u => {

                const option = document.createElement("option");

                option.value = u.id;
                option.textContent = u.name;

                select.appendChild(option);

            });

        });

}


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
        `;

        tbody.appendChild(tr);

    });

}


function ujKonyvHozzaadas(e) {

    e.preventDefault();

    const ujKonyv = {

        title: document.getElementById("title").value,
        author: document.getElementById("author").value,
        year: parseInt(document.getElementById("year").value)

    };

    fetch("/konyv-hozzaadas", {

        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(ujKonyv)

    })
        .then(() => {

            document.getElementById("konyv-form").reset();

            betoltKonyvek();

            function betoltKolcsonzesek() {

                fetch("/kolcsonzesek")

                    .then(res => res.json())

                    .then(data => {

                        const tbody = document.getElementById("kolcsonzes-lista")

                        tbody.innerHTML = ""

                        data.forEach(k => {

                            const tr = document.createElement("tr")

                            tr.innerHTML = `
<td>${k.book}</td>
<td>${k.user}</td>
<td>${k.start}</td>
<td>${k.deadline}</td>
`

                            const btn = document.createElement("button")

                            btn.textContent = "Visszahoz"

                            btn.classList.add("primary")

                            btn.onclick = () => {

                                fetch("/visszahoz/" + k.id, {
                                    method: "POST"
                                }).then(() => {

                                    betoltKolcsonzesek()
                                    betoltPeldanyok()

                                })

                            }

                            const td = document.createElement("td")
                            td.appendChild(btn)

                            tr.appendChild(td)

                            tbody.appendChild(tr)

                        })

                    })

            }
        });

}