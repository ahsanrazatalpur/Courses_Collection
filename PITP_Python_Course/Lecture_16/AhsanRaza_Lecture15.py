
# QNo  1

import json
StudentData = { # Python dictinory
    "Name" : "Ahsan Raza Talpur",
    "Age"  :20,
    "Department" : "Computer Science",
    "Skills"  :["Python", "HTML", "CSS", "MongoDb"] ,
    "TeamMembers" : {"Html" : "Abu Hurera", "CSS" : "Asad Qazmi" , "JavaScript"  :"Asad Abasi"} 
}
#json.dump() to convert to Json String

StudentData = json.dumps(StudentData , index = 4)
print(StudentData) # Json String

# serilize file
with open("student.json", "w") as file:
    json.dump(StudentData, index = 4)


# Reading file
filepath  = "student.json"

file.open(filepath , 'r')
data_show  = file.read() 

print(data_show)
file.close()









# Qno2

import csv

filepath = 'product.csv'

data = {
    "id" : "ID001",
    "name"  : "Ahsan",
    "price"  : 100000

}

with open(filepath, 'w', newline="") as file:
    writer = csv.writer(file)
    writer.writerows(data)