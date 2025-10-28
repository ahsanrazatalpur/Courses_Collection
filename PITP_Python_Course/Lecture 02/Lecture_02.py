 
#--------------------------------------- Variables----------------------------------------------------

# A variable store data in memory 
# Example : name = "Ahasn", age = 20

#  Rules for variables names : 
# 1. Name must be start from letter or underscore 
# 2. Cannot use keywords
# 3. Case Sensative


Name = 'Ahsan Raza'
Age = 20
Department = 'Computer Science'




# ----------------------------------DataType In Python-------------------------------------------------

#  int - whole number (1,2,3,4,5 ...)
#  float - Decimal number (3.142 , 2.3, 85.6)
#  str - text("Hello")
#  bool - True / False
#  Other Types eg : list, tuple, dist, set





#----------------------------------------Check Datatype--------------------------------------------------

# Use type() function
# Example : 
# var = 30
# print(type(var)) #<class 'int'>

# my_str = "Python"
# print(type(my_str)) #<class 'str'>

# my_bol = True
# print(type(my_bol)) #<class 'bool'>

# my_none = None
# print(type(my_none)) #<class 'NoneType'>

# my_flot = 3.142
# print(type(my_flot)) #<class 'float'>




# ---------------------------------------Type Conversion-------------------------------------------------

# Convert between types using int(), float(), str(), bool()

# Example : 

#  String to integer
# x = '30'
# print(type(int(x))) #<class 'int'>

# integer to float
# y = 100
# print(type(float(y))) # <class 'float'>

# String to Boolean
# z = "True"
# print(type(bool(z))) #<class 'bool'>

# integer to String
# a = 300
# print(type(str(a))) #<class 'str'>




#---------------------------------------Basic Operator----------------------------------------------

# Arithmatic = +, -, *, /, //, **, %
# Assignment =  =, +=, -=, *=, /=, 
# Comparison = ==, <=, >=, <, >, !=



# Arithmatic Operators

#  Addition '+'
# num = 90
# new_num = num + 10
# print(new_num) # 100


# Substraction '-'
# num = 110
# new_num = num - 10
# print(new_num) #100

#  Multiplication
# num = 5
# new_num = num * 10
# print(new_num) #50

# Divsion
# num  = 1000
# new_num = num / 100
# print(new_num) # 10.0

# Modulus
# num = 30
# new_num = num % 3
# print(new_num) # 0

# Floor Divison 
# num = 40
# new_num = 40 // 10
# print(new_num) # 4

# Power 
# num = 2
# new_num = num ** 2
# print(new_num)  # 4



# Assignment Operators

x = 10
x += 5
print(x ) # 15

x  = 20
x -= 10
print(x ) # 10

x = 15
x *= 2
print(x ) # 30

x = 50
x /= 5
print(x ) #10.0

x = 90
x %= 10
print(x ) #0

x = 5
x **= 5
print(x ) #3125

x = 200
x //= 9
print(x) #22

# Camparison

x = 10
y = 15

# print("x > y  :", x > y) # False
# print("x < y  :", x < y) # True
# print("x >= y :", x >= y) # False
# print("x <= y :", x <= y) # True
# print("x != y :", x != y) # True
# print("x ==   :", x == y) # False




# --------------------------------------Input and Output -----------------------------------------

# Output with print
# print("Welcome to Python Course")

# Input with input
# name = input("Enter your name  : ")
# print("Your name is :",name)


# Output Example with print

print("Hello, World!")
# Hello, World!

name = "Ahsan Raza"
# print("Hello,",name)
# Hello, Ahsan Raza

age = 20
# print("My age is :",age)
#My age is : 20

# Using f string
# print(f"My name is {name} and my age is {age}")
# My name is Ahsan Raza and my age is 20



# Input Statement

# String input
# name = input("Enter your name : ")
# print("Your name is ",name)

# integer input
# age = int(input("Enter your age : "))
# print("You age is :",age)
