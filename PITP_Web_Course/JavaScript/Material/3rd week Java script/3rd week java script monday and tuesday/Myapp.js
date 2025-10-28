function myTest() {
    let n1 = document.getElementById("n1 ").value;
    let n2 = document.getElementById("n2 ").value;
    let n3 = document.getElementById("n3 ").value;
    let n4 = document.getElementById("n4 ").value;
    let n5 = document.getElementById("n5 ").value;

    let x1 = Number(n1);
    let x2 = Number(n2);
    let x3 = Number(n3);
    let x4 = Number(n4);
    let x5 = Number(n5);
    let sum = (x1 + x2 + x3 + x4 + x5);
    let sub = (x1 - x2 - x3 - x4 - x5);
    let mul = (x1 * x2 * x3 * x4 * x5);

    let div = (x1 / x2 / x3 / x4 / x5);

    document.write("Addition is " + sum + "<br>");
    document.write("Substraction is " + sub + "<br>");
    document.write("Multiplication is " + mul + "<br>");
    document.write("Division is " + div + "<br>");


}