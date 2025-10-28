//    words vs keywords

// Ahsan 
// Ahmed
// car          

// These upper all are names


// and The words which do something in JavaScript are called JavaScript keywords(meaningfull reserved words)
// like var , let , const , if , else , for , while , function , return etc


//                                        Variables

// Variables are those where we store data

// in JavaScript we have three types of variables

// var   (not recomended old version)
// eg : var name  = "Ahsan";


// let    use more (in future we want to change the value)
// let marks = 90;


// const  use less (for fixed value we do not want to change in future)
// const pi = 3.14;

// Note : 1. variable names cannot be any JavaScript keywords
//        2. cannot start with numbers
//        3. cannot contain spaces
//        4. are case-sensitive 


// var , let, const - line by line camparison

// s = 12; //(Not recomended Do not use ever)
// var a = 12;  // scope all over program
// var a;
// var a = 12;
// let a = 12;
// const a = 12;


// Declaration and inilization

var a; // just declare do not give value 
var a = 12;  // give value first time


// what happed if we make variables through var

var a = 12;
// Jab bhi hum variables ko var se banate hai to wo  window mn add hota hai
// It is function scope variables
// we can again decalre it with same name and it does not give error
var a = 15;


// But we got error if we declare same vaiables name with let keyword
// Let protect you from error eg : same name declaration again

const discount = 12;  // value constant cannot change

// Hoisting means:
// JavaScript automatically moves all variable and function declarations
//  to the top of their current scope before code execution.


// Pratcice Problems

// Qno 1
// var mean function level scope variables old way to declare a variables (ES5) it store in windows
// and it can reassign value by same name

// let mean in futuere we want to change the value of our variables we cannot reassign value in let 
// with same same 

// const we use which value we do not want to change in future eg  :pi = 3.142


// // Qno  2

// Node, we cannot reassign the value who declare with const keyword because const keyword make value
// constant if we try to change it we will get error


// // Qno 3

// Yes we can use varibales before decalring it like  a  = 10 because of hoisting  but it show undefined 


// // QNo 4
// Hoisting means JavaScript moves variable and function declarations to the top of their scope before execution.

// // QNo 5

// Yes javaScript is case sensitive for keyword and variables name

// // QNo 6

// no variables name cannot start with Number the valid ways to make variables like underscore , dollar
// sign or any reserved kwyword


// // QNo 7
// The naming rules are
// name must be start with letter , underscore and dollar sign
// variables name cannot be reserved keyword 

// // QNo 8

// var x = 5;
// var y = "5";
// console.log(x == y);  // True value same
// console.log(x === y); // False differnet datatype


// // Qno 9

// var have function scope 
// and let has block scope only


// // Qno 10
// variables declaring bad with var becuase it is old way to declare variables , we can reasign value
// with same name , we can use it everywhere in program and it is save in window

// Qno 11

// let n1 = 2234;
// let n2 = 43490;

// n1 = n2 - n1
// n2 = n2 - n1
// n1 = n1 + n2


// console.log("The value of a n1 " + n1);
// console.log("The value of b n2 " + n2);

// // Qn 12
// let num = 20
// const name1 = "Ahsan"
// let isStudent = true;
// let cgpa = 4.0;
// let empty = null
// let arr = [1, 2, 3, 4, 5];

// console.log(typeof(num))
// console.log(typeof(name1))
// console.log(typeof(isStudent))
// console.log(typeof(cgpa))
// console.log(typeof(empty))
// console.log(typeof(arr))


// // QNo 13
// firstname = "Ahsan";
// lastname = "Raza";
// fullname = firstname + " " +lastname;


// //QNo 14
// let a = 10;
// a = a + 5;
// console.log(a); // 15
// const b = 20;
// b = 25; // what happens here? <-- error here becuase b is const we cannot reasign value


// // Qno 15

// age = 18

// if(age >= 18)
//     console.log("You are a adult")
// else
//     console.log("You are a minor")

// // QNo 16

// console.log(x);   // undefined because of hoisting
// var x = 10;


// // QNo 16
// console.log(y); // ReferenceError or error because let can acces below variables
// let y = 10;


// // Qno17
// price = 1000
// quantity  = 3
// totalbill = quantity * price
// console.log(totalbill)

// // Qno 18
// let score = 0;
// score += 10
// score -= 5
// console.log(score)


// // QNo 19

// guest = prompt("Enter your name ? ")
// alert(`Hello  ${guest}`)
