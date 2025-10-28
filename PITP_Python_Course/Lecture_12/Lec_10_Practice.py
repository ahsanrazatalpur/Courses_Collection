# OOP 
# OOP stand for object oriented programing
# OOP is a way to  make code with classes and object

# Benifits :  Organize better code
# Model-real world entity
# Encourage reusabilty and scalablity


# OOP Key Concept
# Class : Blueprint , Structure, or template for creating object
# Object :  Instance (copy) of class
# Encapsulation :  Building method and data together
# Inheritance : Creating a new class with existing class
# polymorphisam : same interface and different implemention
# Pass : Statement that act as null operation , mean it do nothing


class ClassName:
    # Attribute and methods 
    pass # do nothing(null)

class Student:
    pass


# Creating object 
c1 = ClassName()
s1 = Student()

print(type(s1))



#   __init__ method and self

# init method is constructor it call automaticallay when object is created
# self refer to current object


class Student:
    name = "Ahsan Raza"
    age = 21
    department = "Computer Science"

    def __init__(self, name, age , department): # self mean this object and __init__ is cunstructor call auto 
        self.name = name
        self.age = age
        self.department = department

    def display_info(self): # method to show data
        print(f"My name is {self.name}\nMy age is {self.age}\nMy Department is{self.department}")


obj = Student("Ahsan Raza Talpur", 20, "Computer Science")  # obejct 
obj.display_info()




class Student:
    def __init__(self, name , standard):
        self.name = name
        self.standard = standard

s1 = Student("Ahsan Raza", 10)
s2 = Student("Ali Raza", 12)

print(s1.name, s1.standard)
print(s2.name, s2.standard)




class Employee:
    def __init__(self, employee_name, employee_id): # constructor
        self.employee_name = employee_name
        self.employee_id = employee_id

emp = Employee("Mr Ahsan Raza Talpur", "Emp2npr")# object1
print(emp.employee_name, emp.employee_id)

emp2 = Employee("Ali Raza Talpur", "empoi9d") #object2
print(emp2.employee_name, emp2.employee_id) 



# Attribute like varible in obj they show data about object

class Car:
    def __init__(self, car_brand, car_model):
        self.car_brand = car_brand
        self.car_model = car_model

    def display_info(self):
        print(f"I have {self.car_brand} car \nIt model is {self.car_model} model")

car = Car("Toyota", 2026)
car.display_info()



# Function in class

class Student2:
    def __init__(self, name, grade):
        self.name = name
        self.grade = grade

    def display_info(self):  # method to show info
        print(f"The Student {self.name} got {self.grade}")

show_reportCard = Student2("Talha", "A+")
show_reportCard.display_info()



# real life example-----------------------------------------------------------------------------------

class BankAccount:
    def __init__(self, account_holder, balance):
        self.account_holder = account_holder
        self.balance = balance
    
    def deposit(self, amount):
        self.amount = amount
        self.balance += amount
        print(f"The {self.amount} is depodit to your accunt now balanace is {self.balance}")

    def withdraw(self, amount):
        if amount > self.balance:
            print("Indufficient balance")
        else :
            self.balance -= amount
            print(f"Your {self.amount} is withdraw your current balance is {self.balance}")
    def display_info2(self):
        print(f"Account holder is {self.account_holder} and his balance is {self.balance}")

obj1 = BankAccount("Ahsan Raza", 50000)
obj1.display_info2()
obj1.deposit(3000)
obj1.withdraw(7000)



# Another real life example 

class Staff:
    staff_name = "Ahsan Raza"
    staff_id = "empid03"
    staff_salary = 300000

    def __init__(self, staff_name , staff_id, staff_salary):
        self.staff_name = staff_name
        self.staff_id = staff_id
        self.staff_salary = staff_salary
    
    def display_info(self):
        print(f"staff name is {self.staff_name}")
        print(f"staff Id is {self.staff_id}")
        print(f"staff Salary is {self.staff_salary}")

obj3 = Staff("Ahsan", "empno93", 500000949)
obj3.display_info()