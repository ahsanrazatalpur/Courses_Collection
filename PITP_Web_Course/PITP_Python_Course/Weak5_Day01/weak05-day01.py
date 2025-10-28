# File input and output

# File input output matter

# 1. Store program data permanantaly
# 2. Process sxisting data files
# 3. Shae data between programs
# 4. Handle large data sets thet do not fit in memory



# Introduction

# 1. I/O allow your python program to interact with file stored on your computer
# 2. input mean reading data from a file
# 3. output mean writing data to a file
# 4. file keep data store  permanantly instead of keepingbit temepory


# r    mean read file
# w    mean write  (overwrite existig file)
# a    append 
# x    exclusive creation faild if file exixts
# +    update read and write 



# Reading text file

# # have methods
# readline()  # read a single line from the file
# readlines() # read all the lines and return them as a list of strings

# Assume we have example txt file with text hello world


file_path = "example.txt" # give file path

try:
    file = open(file_path, 'r')  # open file in read mode
    content = file.read()  # read the content of the file
    print(content)  # print the content
    file.close()  # close the file
except FileNotFoundError:
    print(f"The file at {file_path} was not found.")



# Writing to a text file
file_path = "example.txt"  # give file path
file = open(file_path , 'w' )  # open file in write mode
file.write("This is a new line added to the file.\n")  # write to the file
file.write("Adding another line.\n")  # write another line
file.write("Hello World , This is Ahsan Raza")  # write another line
file.write("\n The End")
file.close()  # close the file

# now read the file again to see the changes
file = open(file_path, 'r')
content = file.read()
print(content)
file.close()


# Now open with context manager
# with open and close file automatically even if an error occurs

try :
    with open(file_path , "r") as file:
     content = file.read()
    print(content)
    # with automatically closes the file
except FileNotFoundError:
    print("File not Found")

# Wrinting filw with w always use w unless you have a reason

file_path = "example.txt"

with open(file_path, "w") as file:
   file.write("This will overwrite the existing content.\n")
   file.write("Another line added.\n")



# Working with CSV (Coma separated values) files store tabular data like excel

# import it with import csv
# Use csv.reader for rows as list
# use csv.DictReader for rows as dictinory

import csv

file_path = "data.csv"
with open(file_path, "r", newline="") as file: # newline for cross platform compatibility
   reader = csv.reader(file)
   for row in reader:
      print(row)  # each row in a list


# Reading CSV as dictionary
file_path = "data.csv"
with open(file_path, "r", newline="") as file:
   reader = csv.DictReader(file)
   for row in reader:
      print(row)  # each row as a dictionary
    

import csv

file_path = "bio.csv"
bio = [
     ["name", "age", "city"],
     ["Ahsan", 20, "Lahore"],
     ["Ali", 22, "Karachi"],
     ["Sara", 19, "Islamabad"]
]
with open(file_path , "w", newline= "") as file:
   writer = csv.writer(file)
   writer.writerows(bio)  # write multiple rows


# writting dictinories

import csv
file_path = "bio_dict.csv"
bio = [
    {"name": "Ahsan", "age": 20, "city": "Lahore"},
    {"name": "Ali", "age": 22, "city": "Karachi"},
    {"name": "Sara", "age": 19, "city": "Islamabad"}
]

with open(file_path , 'w', newline = "") as file:
   fieldnames = ["name", "age", "city"]
   writer = csv.DictWriter(file, fieldnames= fieldnames)
   writer.writeheader()  # write the header
   writer.writerows(bio)  # write multiple rows