# What is object oriented programming(OOP)

# class big class
# object studnets in class

# different stylke of code

# base and depend on object and class

# It organaize code 

#  students.py student related code
#  teachers.py teacher related code



# Class : Blueprint / structure / map
# Object : instance of class 
# encapsulation :..................
# 
# 
# 
# class className:
# # attribute and methods
# pass
# 
# class Student:
# s1 = Student(); 
# s2 = Student();
# 
# print(type(s1))   # class main student

# function inside class

# __init__ Methods and self



# function example

# class Students:
#     def __init__(self):
#         print("Hello! World")
#     def show_data():
#         print("Student : Data")

# st = Students() # object
# print(st)
# print(type(st))   #<class '__main__.Students'>



# class Student:
#     school_name = "Rahim School" # class attribute
#     adderss = "Near Post Office Badin"
#     no_of_students = 9800
#     no_of_staff = 100


#     def __init__ (self, school_name = "A", address = "B", no_of_students = 0, no_of_staff= 0):# constructure (fisrt constructure always self)
#         self.school_name  =school_name   # yaja oper wale attribute aige
#         self.school_name = school_name
#         self.adderss = address
#         self.no_of_staff = no_of_staff
#         self.no_of_students = no_of_students


#     def display_info(self):
#         print(f"SchoolName : {self.school_name}")
#         print(f"School Address : {self.adderss}")
#         print(f"Number of Students : {self.no_of_students}")
#         print(f"Number of staff : {self.no_of_staff}")

# # Usage

# # school_name = "Rahim Public School Badin"
# # sc1 = Student(school_name)
# # sc2 = Student(school_name)

    
# sc3 = Student('City_School', "Karachi", 1000, 100)
# sc3.display_info()








# Class work


class Student_biodata:
    student_name = "Ahsan Raza" 
    Age = 21
    Department = "Computer Science"
    RollNo = "BLCS/2k23/06"


    def __init__ (self, school_name = "Name", age = 0, Department = "Cs", RollNo= 0):# constructure (fisrt constructure always self)
        self.school_name  =school_name   # yaja oper wale attribute aige
        self.school_name = school_name
        self.adderss = age
        self.no_of_staff = RollNo
        self.no_of_students = Department


    def display_info(self):
        print(f"Student_Name : {self.student_name}")
        print(f"School Address : {self.Age}")
        print(f"Number of Students : {self.Department}")
        print(f"Number of staff : {self.RollNo}")

# Usage

# school_name = "Rahim Public School Badin"
# sc1 = Student(school_name)
# sc2 = Student(school_name)

    
sc3 = Student_biodata('Ahsan Raza', 21, "Computer Science", "BLCS/2k23/06")
sc3.display_info()
