# Json and CSV

# json stand for javascript object notation

# csv stand for comma seprated values

# Json is a text based data format used to store and exchange data between programs

# it represent data in key, value pairs same as python dictinoories

{
    "name" : "Ahsan Raza",
    "age" :  20,
    "city" : "Karachi"
}

# python have built in json module just import it  as import json

# Serialization (Python to Json)
# use json.dumps() to converting python object(list, dict) into json string
# use json.dump() to write a python object directly to a file as json

# Deserializatio(Json to Python)
# json.loaads() converting json string into python object
# use json.load()  to read a JSON from a file into a python object 



# Serialization 

import json
data = {
    "name" : "Ahsan Raza",
    "age" :  20,
    "city" : "Karachi"
}

# Serialize to json string
json_string = json.dumps(data , indent=4) # indent for readability
print(json_string)

# Serialize to json file
with open('data.json', 'w') as file:
    json.dump(data, file, indent=4)


# Deserialization
# deserialize from json string
json_string =  '{"name" : "Ahsan Raza", "age" :  20, "city" : "Karachi"}'
python_data = json.loads(json_string)
print(python_data)

# deserialize from json file
with open('data.json', 'r') as file:
    python_data = json.load(file)
print(python_data)



# Example Per py json String 