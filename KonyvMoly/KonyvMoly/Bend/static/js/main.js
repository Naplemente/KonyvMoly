document.addEventListener("DOMContentLoaded", () => {
  betoltKonyvek();
});

function betoltKonyvek() {
  fetch("http://127.0.0.1:8000/konyvek")
    .then(valasz => valasz.json())
    .then(konyvek => {
      const lista = document.getElementById("konyv-lista");
      lista.innerHTML = "";

     if (k.available) {
    p.textContent = `${k.title} – ${k.author} (Elérhető)`;
    p.classList.add("elerheto");
  } else {
    p.textContent = `${k.title} – ${k.author} (Kikölcsönözve)`;
    p.classList.add("kolcsonozve");
  }

      konyvek.forEach(konyv => {
        const sor = document.createElement("p");

        const allapot = konyv.available
          ? "Elérhető"
          : "Kikölcsönözve";

        sor.textContent =
          `${konyv.title} – ${konyv.author} (${allapot})`;

        lista.appendChild(sor);
      });
    })
    .catch(hiba => {
      console.error("Hiba a fetch során:", hiba);
    });
}