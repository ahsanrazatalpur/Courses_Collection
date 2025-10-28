
# Dictinory and Sets

# Dictinories
# Dictinories are unordered
# Mutable Collection of Key value pair



# Empty Dictinory

# dic = {}
# print(dic)
# print(type(dic))



# data = {
#     "Name" : "Ahsan Raza",
#     "Age" : 20,
#     "RollNo" : "2k23/BLCS/06"
# }
# print(data)




# Keys must be hashable (imutable)
# grades = {
#     "Math" : 90,
#     "Science" : 89,
#     "WSN" : 80,
#     "TPL" : 79,
#      "value" : 4
# }
# print(grades)



# Keys must be Hashable (imutable)
# Student = {
#     "Name" : "Ahsan",
#     "Age" : 20,
#     "CGPA" : 4.0,
#     (1, 2, 3) : "values",
#     True : "isStudent"
# }
# print(Student)

# Mutable key are not allowed eg list

# person = {
#     "name" : "Ahsan",
#     "Age" : 20
# }
# # Printing and Sccesing the values of Keys      .get() function to get data
# print(person["name"])
# print(person.get("name"))
# print(person.get("city" , "Unknow")) # Acces City if not present print default value of city = Unknow


# # Modifying Dict
# person["city"] = "Badin"   # assign / update the value of city
# print(person["city"])
# person["Age"] = 30  # update age value

# person["gmail"]  = "abc.gmail.com"
# print(person["gmail"])

# del person["gmail"]    it delete perdon gmail

# age = person.pop("age")  # remove age from person

# person.clear()  # clear the dict

