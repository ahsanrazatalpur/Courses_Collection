

# Control Structure and basic logic

# Condtional Strcuture (if else , if elif else )

# Loop (for , while)

# Break and Continue Statement


# What are control structure 
#  Mechanism to control the flow of program
#  Enable decision making (conditions) and repetation loops 

# Types 
# Conditional statement  : Decision making (if, elif,  else)
# Control flow Tools : Break , continue 


# Conditional statemenet - If elif else 
# Purpose : Execute code block base on true / false
# If statement : Execute code if condition is true 
# elif statement : Check additional condition if previous one are false 
# Else statement : run if both statement are false 


# if(condition):
   # code block intended 
# elif statemenet : Checks additional condition 
   # another block 
# else statement :
   # default conditions 

# Condition evaluate to True / False 
# Indentation (4 space) is critical 
# elif and else are optional 
# Use comparison Operator : <, >, <=, >=, ==, !=


# age = int(input("Enter your age : "))
# if age >= 18:
#     print("You are a Adult")
# elif age >= 13:
#     print("you are a Teen")
# else :
#     print("You are a Child")

# Condition in Depth 
# Condition Types : <, >, <=, >=, ==, !=
# Membership : item in list (eg : 'a' in apple)
# Nested If

# score = 50
# if score >= 90:
#     if score >= 60:
#         print("A+")
#     else:
#         print("Pass")
# else:
#     print("Fail") 


# ternary Operator
# short-form : result = "Adult" if age >= 18 else "Minor"
# Readable Alternative to single  if-else

# Baisc If statement
# Execute code only if condition is true

# Synatx :
# if condition:
            #  Code to execute if condition is True

# Example :
# age = 18
# if age > 18:
        # print("adult")
              

# if else statement
# Provide alternative execute path
# Syntax :
# if condition is True :
#      code if condition is true
# else:
#      code if condition is false

# temp = 50
# if(temp > 40):
#     print("Its too hot")
# else:
#     print("Its not hot")


# If elif else Conditions
# Handle multiple conditions
#  Syntax
# if condition1:
    # code for condition 1
#elif condition2:
    # condition2 for elif
#else condition3:
    # condition if all become false

# number = 9
# if(number > 0):
#     print("Number is Positive")
# elif(number < 0):
#     print("Number is Negative")
# else:
#     print("Number is zero")


# Nested Condition 
# Condition inside another condition

# num = 7
# if num >= 0:
#     print("Number is positive and ")
#     if num %2 == 0:
#         print("Number is positive ")
#     else:
#         print("Number is Odd")
# else:
#     print("Number is negative ")


# Loops in Python 
# Execute the block of code repetadly
# Iterate over a sequence (eg: list, range, string)
# Two types of Loops 1. For loop and 2. while loop

# Why use Loops:
# Avoid code repetation
# Process collection of data 
# implement repetative algoritham


# for loop
# iterate over a sequence (list, tuples, string etc)

#Syntax
# for item in sequence:
# code block

# fruits  = ["Apple", "Banana", "Grapes", "watermelon"]
# for fruit in fruits:
#     print(fruit, end=" ")

# Range Function

# Generate a sequence of number
# often used with for loo[
# Syntax : range (start, end, stepover)


# for i in range(1,6):
#     print(i, end=" ")

# for i in range(0,21,2):
#     print(i, end=" ")

# for i in range(1,21,2):
#     print(i, end=" ")


# While Loop
# Execute code as long as condition is true
# Syntax:
# while condition:
#        code block


# number = 1
# while(number <= 10):
#     print(number)
#     number += 1



# Break Statement
# for i in range(1,21):
#     if i == 5:
#         break
#     print(i)

# Continue Statement
# skip the current iteration and continuew with the next

# for i in range(1,11):
#     if i == 7 or i == 4:
#         continue
#     print(i)




# Nested Loop (Loop inside another loop)
# for i in range(3):
#     for j in range(2):
#         print(f"i= {i}, j = {j}")


# password = input("Enter the password : ")
# while len(password) < 8:
#     print("Password is too short")
#     password = input("Enter the passowrd : ")
# print("Password Succesfull")

