
# Qno  1

class Book:
    Title = "Python Advanced Course"
    Author = "Code With Harry"

    def __init__(self, Title, Author):
        self.Title = Title
        self.Author = Author

    def display_info(self):
        print(f"Book name is {self.Title}\nAnd its Author is {self.Author}")

Library = Book("Sigma web Developmeng",  "Haris Ali Khan")
Library.display_info()





# QNo  2

class Circle:
    raduis = 2.0
    def __init__(self, raduis):
        self.raduis = raduis

    def area(self, raduis):
        a = 3.142 * raduis * self.raduis
        return a
    
    def circumference(self, raduis):
        c = 2* 3.142 * raduis
        return c
    
circle  = Circle(8.0)
print(circle.area(8))
print(circle.circumference(9))



class Employee:
    name = "Ahsan Raza"
    salary = 50000

    def __init__(self, name, salary):
        self.name = name
        self.salary = salary

    def display_info(self):
        print(f"Employee name is {self.name} and his salary is {self.salary}")

    def increment(self, per):
        self.per = per
        self.salary += self.salary / per 
        print(f"You is is increse by {self.per}% now you salary is {self.salary} Congratulation")

Promotion = Employee("Ahsan", 1000.0)
Promotion.display_info()
Promotion.increment(10)



class Calculator:
    def __init__(self, num1, num2):
        self.num1 = num1
        self.num2 = num2

    def add(self,  num1, num2):
        return num1 + num2

    def Sub(self, num1, num2):
        return num1 - num2

    def Mul(self, num1, num2):
        return num1 * num2

    def divide(self, num1, num2):
        return num1 / num2
    
    def Mod(self, num1, num2):
        return num1 % num2
    
Calculation = Calculator(3, 4)
print(Calculation.add(10, 90))
print(Calculation.Sub(10, 90))
print(Calculation.Mul(10, 90))
print(Calculation.divide(10, 90))
print(Calculation.Mod(10, 90))



class Student:
    name = "Ahsan Raza"
    marks = 99

    def __init__(self, name, marks):
        self.name = name
        self.marks = marks

    def isPass(self, marks):
        if marks <40:
            print("Fail")
        else:
            print("Pass")
    
    def display_info(self):
        print(f"My name is {self.name} and My marks is {self.marks}")

result = Student("Ahsan", 80)
result.display_info()
result.isPass(90)