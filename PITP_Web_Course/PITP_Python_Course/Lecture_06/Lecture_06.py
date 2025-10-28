
# Lecture_06  

# Exception Handling 

# 0 cannot eb divided by any number
# we do try execpt for code that is corupt(have errors)

# Try-Except Blocks


# number = int(input("Enter any number: "))    we want our on msg rather than  error dont want to show error to user
# print(number)

# Our own massage rather than error

# try :
#       number = int(input("Enter any number"))
# except ValueError :
#       print("Invalid input")




# Handling Specific Exception 
# Python allow tyou to errorr..
# Common Error Types

# 1. Value Error
# 2. 
# 3.


# try :
#       num1 = int(input("Enter 1st number : "))
#       num2 = int(input("Enter 1st number : "))
#       result = (num1 / num2)
#       print("The divison is :",result)
# except ValueError:
#       print("Your value is incorect")
# except ZeroDivisionError:
#       print("The number cannot divide by 0")
      


# raising Exception
# try :
#     age = int(input("Enter any number :"))
#     if age >= 28:
#         raise ValueError("You are too older") 
#     print("You are not eligible")
# except ValueError as v:
#    print(v)



# Final Clasue

# try :
#     age = int(input("Enter your age  :"))
#     if age >= 28:
#         raise ValueError("You are too older") 
#     else:
#         print("You are Eligible")
#     print("You are not eligible")
# except ValueError as v:
#    print(v)
# finally:
#     print("Thank your for try !")


# age = int(input("Enter your age ?")):
# if(age > 28 ):
#     print("You are Older ")
# else:
#     print("You are younger")



# def division():
#     try :
#         num1 = int(input("Enter 1st number : "))
#         num2 = int(input("Enter 1st number : "))
#         result = (num1 / num2)
#         print(result)
#     except ValueError:
#        print("Please entr Valid number")
#     except ZeroDivisionError:
#         print("Can not divide by 0")
#     finally:
#         print("Thank your for try !")


# division()


#  File open in code

# my_file = open("Lecture_06.py","r+")
# print(my_file.read,"File has been open ")

def number(n):
    try:
        if(n < 0):
            raise ValueError("Number cannot be less not zero")
    except ValueError as e:
        print(e)

number(-6)