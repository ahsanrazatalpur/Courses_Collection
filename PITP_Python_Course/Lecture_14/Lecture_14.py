# Inheritance  : mean to take property from Super class or parent class

# The class Who give/share his Property called Parent class or Super Class

# import Lecture_13 as lec


# class Instructure(Teacher):
#     pass

# print(type(Instructure))



# Type of inheritance

# Single inheritance : Single parent and single child 

# Child clas and usage 



#Parent class

class Vehicle:
    def __init__(self, name = "Toyota", model = 2025):
        self.name  = name 
        self.model = model

    def display_info(self):
        print(f"The {self.name} is {self.model} ")

show_car_data = Vehicle("Toyota", 2026)
show_car_data.display_info()
        



class Teacher:
    def __init__(self, name, emp_no, cnic, phone, department, cource):
        self.name = name
        self.emp_no = emp_no
        self.cnic = cnic
        self.phone = phone
        self.department = department
        self.course = cource

    def dispaly_info(self):
        print(f"My name is {self.name}")
        print(f"My Employee Number  is {self.emp_no}")
        print(f"My CNIC is {self.cnic}")
        print(f"My Phone is {self.phone}")
        print(f"My Department is {self.department}")
        print(f"My Course is {self.course}")
        
# class method take only variable that are declare below the clas
   
       
show_data = Teacher("Ahsan Raza", "emp2n", "41101987654", "031131293", "Computer Science", "Pythone Development")
show_data.dispaly_info()


# Class MEthod
class Teacher_Info:
 name =  "Ahsan Raza tapur"
 emp_no = "2no"
 cnic = "8234349032"
 phone = "2938993824"
 department = "Computer Science"
 course = "Python For Data Scince"

 def __init__(self, name = "Ahsan Raza", emp_no = "emp5nys", cnic = "41101329382", phone = "0311233434", department = "Bacholor Of Science", course = "Web Development"):
     self.name = name
     self.emp_no = emp_no
     self.cnic = cnic
     self.phone = phone
     self.department = department
     self.course = course

 @classmethod
 def display_info2(cls):
        print(f"My name is {cls.name}")
        print(f"My Employee Number  is {cls.emp_no}")
        print(f"My CNIC is {cls.cnic}")
        print(f"My Phone is {cls.phone}")
        print(f"My Department is {cls.department}")
        print(f"My Course is {cls.course}")
        
show_newdata = Teacher_Info()
show_newdata.display_info2()

        

        

# Object banega to constructor autommatically call hojaega 

# Super keyeword class cunstructor of other class

# A class inherit from multilple parent clas called multiple  Inheritance

# class method use to call class variable (they are global)


# Multiple inheritanc : 2 parent 1 child


# Polymorphisam  = (many forms , shapes) it allow ob of differnt class to be treated as obj of 
# common super class


# Method overriding : 1 method run  time  (polymorphisam)



class shape:
    def area(self):
        print("Any Area")

class rectangle:
    def __init__(self, width, length):
        self.width = width
        self.length = length

    def area(self):
        print(f"The area of rectangle is {self.width * self.length}")

    
class Triangle:
    def __init__(self, width, length):
        self.width  = width
        self.length = length

   
    def area(self):
        print(f"The area of Triangle is {1/2 * self.width * self.length}")
    


show_area = rectangle(55, 9)
show_area.area()

show_rec_area = Triangle(3, 4)
show_rec_area.area()

    
# Duck typing : ager duck ki treh chalrahi to ap bologe duck jarhi




# class cat:
#     def sound(self):
#         return "Meow🐈"
    

# class Dog:
#     def sound(self):
#         return "Bark🐕"
    
# class Animal:
    