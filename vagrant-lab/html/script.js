function mostrarMensagem() {
    alert("Bem-vindo à demonstração da plataforma DevOps!");
}

setInterval(() => {

    document.getElementById("deploys").innerText =
        Math.floor(Math.random() * 50) + 20;

    document.getElementById("alerts").innerText =
        Math.floor(Math.random() * 10);

}, 3000);