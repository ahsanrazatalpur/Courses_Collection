# JSON

# Json mean JavaScript object Notation

# It is dataformal same as csv

# very Famous becuase when we extract any web data using api they give data in json in key value pair as 
# dictinory


# example json data 
{
    "name"  :"Ahsan",
    "Age"  : 22,
    "Department" : "Computer Science",
    "skill": ["Python", "SQL", "HTML, CSS, JS"]
}


# we need to import json to work on json


# serialization and deserialization

# serialization = data in python object we want to make api 
# use json.dumps() to convter a  python
# use json.dump() for write python

# deserialization : again convert json opject to python
# json.loads() to convert to json string to Python obj
# json.load() to read json from a file into python project
#                             Serialization
import json

# python dict
data = {
    "name"  :"Ahsan Raza",
    "Age"  : 22,
    "Department" : "Computer Science",
    "skill": ["Python", "SQL", "HTML, CSS, JS"]
}

#  Serialization to JSON String
json_string = json.dumps(data , index = 4)
print(json_string)


# Serilize to file 
with open.open("data.json", "w") as file:
    json.dump(data, file, index = 4) 



# Deserilaization (Json to Python)

import json

# Desreilization from String

json_string = '{"name" : "Ahsan" , "Age" : 20}'  # Json string

python_data = json.loads(json_string)
print(python_data)


# Deserilization
with open("data.json", "r") as file:
     python_data = json.load(file)
print(python_data)


