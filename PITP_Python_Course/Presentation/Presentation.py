
# ***                                   Variables and DataTypes                                   ***


# Variables : Variables like a memory location whereyou store a value 

x = 100
y = "Python"

print(x)
print(y)


# Variables DataType

# There are mainly six type of datatype in python 

# 1. Number     eg : 10
#   . integer  (10) 
#   . float  (3.142)

# 2. String     eg : "Developer"
# 3. List       eg : [2, 4, 6, 8]
# 4. Dictonary  eg : {"Id" : 6}
# 5. Tuples     eg : 
# 6. Set        eg : (12, 2, 6)
# 7. Boolean    eg : True / False


#  type() function to find the type of that variables
a = 100
print(type(a))  # <class 'int'>

b = 3.142
print(type(b)) # <class 'float'>

c = "Python Programming"
print(type(c)) # <class 'str'>

d = True
print(type(d)) # <class 'bool'>

e = None
print(type(e)) # <class 'NoneType'>

f = [1, 2, 3, 4, 5]
print(type(f))  # <class 'list'>

e = { "name" : "Ahsan"}
print(type(e))  # <class 'dict'>

f = (2, 3, 4, 5)
print(type(f)) # <class 'tuple'>



# len() function to get length of string
lang = "English"
print(len(lang)) # 7

