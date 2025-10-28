# # x = 0 
# # while x < 5:
# #  x += 1
# # print(x)



# from math import sqrt

# # print(math.sqrt(3))
# # print(sqrt.math(3))
# # print(sqrt(3))



# List and Tuple

# introduction to tuple
# tuple are ordered , imutable collection
# Tuple are using parenthesis

# empty_tuple = ()
# print(type(empty_tuple))

# packed = ("Apple", 10, True)
# print(type(packed))

# tup = 23, True , "Ahsan"  # Tuple can be created by Without braket
# print(type(tup))


# Mutable  = changable
# Imutable = not changable

# Unpacking
# List = for list that may change
# Tuple = for fix data like coordinate 

# Dictinories

# your_data = {}
# print(your_data)
# print(type(your_data))


# data = {
#     "name" : "Ahsan Raza",
#     "Cnic" : "4119183473",
#     "age" : 22,
#     "RollNo" : "2k23/BLCS/06",
    #    True    :  isStudent,
#      1 : "This is number one"

# }

# print(data)


# for key, value in data.items():
#     print(key , value)


# grades = {
#     "sub" : 30,
#     "sub2" : 60,
#     "sub3" : 80,
#     "sub4" : 50,
#     "sub5" : 60,
# }

# for key,value in grades.items():
#     print(key, value)


coursec = {
    "course" : ["DBMS", "CA", "TPL", "EnternShip"],
    "Teacher" : ["S.Dileep", "S.Chetan", "S.Inayat", "Company"],
    "CGPA"  : 3.5,
  #  (1, 3, 6) : "lst" #  not Valid list cannot be key

}

# print(coursec.keys())
# print(coursec.keys())
# print(coursec.values())


# print(coursec["CGPA"])  # acces one value
# print(coursec["Teacher"])

# print(coursec.get("Teacher")) # print by .get function

# print(coursec["CGPA"] == [""])  # acces one value

# coursec["CGPA"] == ["RAm"]
# print(coursec["CGPA"])  # acces one value

# .clear()  to clear all the dic

# for key in coursec.keys():
#     print(key)

# for value in coursec.values():
#     print(value)

# for key,value in coursec.item():
#     print(key , value)


# print(coursec.get("city"))
# print(coursec) # got None because i donot have any value like city



# coursec.update({"gmail" : "saj@gmail", "gender" : "male"})
# print(coursec)



# coursec.update('AnyOtherDic') # combile 2 dictinory


# .pop() # to pop itwm

# my_list = [0, 1, 2]
# my_dist   = dict.fromkeys(my_list, 10) # all key will be assign this 10 value



# print(coursec.keys)
# print(coursec.values)
# print(coursec.items)




#  Set

# Unorder mutable collection of unique elemenet

# empty_Set = set()
# print(type(empty_Set))

# fruits = {"Banna" , "Apple"} # list can be cretaed by also this
# print(fruits)
# print(type(fruits))

# num = set([12, 34, 45, 56])
# print(num)


# fruits = {"Banana", "grapes"}
# print(type(fruits))

# setA = {23, 45, 56}
# setB = {23, 56, 77}
# print(setA.union(setB))

# setA = {23, 45, 56}
# setB = {23, 56, 77}
# print(setA.intersection(setB))

# print(setA | setB)
# print(setA & setB)
# print(setA - setB)  # Difference
# print(setA ^ setB)  # power set
# print(setA <= setB)  # is set b is subet of a
# print(setA >= setB)  # is set a is subet of b

# print(2 in setA) # to find any value in set
# print(2 in setB)

# li = [12, 34, 45, 45, 34, 78, 46]
# print(set(li)) # convert list to set to remove duplicate value


# valid_user = {"Ahsan", "Abu_Hurera", "Manzoor", "Asad"}
# name = input("Enter your name ? ")

# if name in valid_user:
#     print("Acces Granted")
# else:
#     print("Acces Denied")




# -------------------------EXAMPLE-----------------------
# empty_list = []
# print(empty_list)


# li = [12, 34, 45, 56]
# names = ["Ahsan", "asad", "Abu Hurera", "Ali"]
# isStuduent = [True, False]
# mix_data = [132, "Ahsan", False, 50.0]

# print(li)
# print(names)
# print(isStuduent)
# print(type(empty_list))

# print(type(isStuduent))

# # fruit = ["Banan", "Grapes", "Banana"]
# # for fruit  in fruit:
# #     print(fruit)

# # for name in names:
#     print(name ,end= " ")

# number = [1, 2, 3, ]
# for fruit in fruit:
#     for number in numbers:
#         print(name , fruit)


