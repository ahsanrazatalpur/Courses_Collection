const btnEl = document.getElementById("calculate");
const fstWeight = document.getElementById("fw");
const secWeight = document.getElementById("sw");
const totalSpan = document.getElementById("total");

function calculateTotal() {
    const f1 = fstWeight.value;
    const f2 = secWeight.value;
    const f3 = f1 - f2;
    totalSpan.innerText = f3.toFixed(2);
}

btnEl.addEventListener("click", calculateTotal);