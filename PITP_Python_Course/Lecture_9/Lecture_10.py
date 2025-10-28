
# String manipulation and 

name = 'Ahsan'   # Single-quote String
print(type(name))

Department = "Computer Science" # Double-quote String
print(type(Department))

# Multi Line String With 3 double quote
Message  ="""  
Here is my message 
          Here it is
"""

# Multi Line String With 3 single quote
Prompt = '''
Please Create website for my E-Commerse Store'''

print(type(Prompt))
print(type(Message))


print(name)
print(Department)
print(Message)
print(Prompt)



# Escape Sequence

# \n for new line
new_line = "My name is Ahsan Raza  \n My caste is Talpur"
print(new_line)


# \""\ print double quote on String
name = 'My name is \"Ahsan Raza Talpur\"'
print(name)

# \''\  print single quote on String
age = 'My age is \'20\' years old'
print(age)



# r"" for raw String  (print string as it is)
raw_String = r"PS C:\Users\PMYLS\Desktop\Ahsan\PITP_Python_Course\Lecture_10>"
print(raw_String)


#                    ***  Slicing  ***
# String => collrction of character 
language = "Python For Data Science"
print(language[0]) #p   (print first character)
print(language[-1]) #p   (print last character)
print(language[7:10]) # For Substring (Series of chaarcter from 7 to 10)
print(language[10:]) # For Substring (Series of chaarcter from 7 to 10)

print(language[::2]) # Even indexxth of String (Alternative Character)
print(language[1::2]) # Odd indexxth of String


#                             *** Concatinating String ***
concate_String = language + " Here is my favourite Languiage"
print(concate_String)


# Repeting of String
Hasa = "He" * 10
print(Hasa)



# Find substring in String
Selogance = "Marsu Marsu Sindh na Desu"
print("Sindh" in Selogance)  # True   (use in search operation)
print("sindh" in Selogance)  # False 

# Not in if substring is not avaliable in String then return True
print("Sindh" not in Selogance)  # False
print("sindh" not in Selogance)  # True


# len(string) to find the length of String
Str = "My name is Ahsan Raza Talpur and I live in My dreams"
print(len(Str)) #52


# Case conversion methods

Dummy_text = "Hello There , InshAllah I am String Bloging"

print(Dummy_text.upper())  # Make all character Upper Case
print(Dummy_text.lower())  # Make all character Lower Case
print(Dummy_text.capitalize()) # Make all sentance Make first word capital
print(Dummy_text.title())   # Make all character first charactet large
print(Dummy_text.swapcase()) # swap all character if upper then change to  lower and vice versa


# Check the Case
print(Dummy_text.isupper())
print(Dummy_text.islower())   
print(Dummy_text.istitle())   

# Search and Replace
Sigma_Group = "Ahsan, Abu_Hurera, Asad Absoulutly Giga Chad"
print(Sigma_Group.find("Asad"))    
print(Sigma_Group.find("Haroon"))     #-1 return if not found



# .index()   to fuind  if not found through value error
Sigma_Group = "Ahsan, Abu_Hurera, Asad Absoulutly Giga Chad"
print(Sigma_Group.index("Asad"))    
# print(Sigma_Group.index("Haroon"))     #If not found then through Value Error


# .count() to count any string
Sigma_Group = "Ahsan, Abu_Hurera, Asad Absoulutly Giga Chad"
print(Sigma_Group.count("Asad"))    
print(Sigma_Group.count(" "))     




# .replace() to replace
Sigma_Group = "Ahsan, Abu_Hurera, Asad Absoulutly Giga Chad"
print(Sigma_Group.replace("Asad", "Harron"))  # doesnot change on original
print(Sigma_Group.replace(" ", "_")) 
print(Sigma_Group.replace("Sir", "Madam"))   # if not found then no change

# Validation Method

# .isalpha
# .isalnume

Sigma_Group = "Ahsan, Abu_Hurera, Asad Absoulutly Giga Chad 123"
print(Sigma_Group.isalpha)
print(Sigma_Group.isalnum)
print(Sigma_Group.isdecimal)
print(Sigma_Group.isspace)
print(Sigma_Group.isdigit)
print(Sigma_Group.isnumeric)
print(Sigma_Group.isascii)
print(Sigma_Group.isprintable)
print(Sigma_Group.istitle)



# Check file extension
# .startwith("")
# .endwith("")
filename = "document.pdf"
print(filename.startswith("pdf")) # False  
print(filename.endswith("pdf")) # True





# WhiteSpace and Alignment


# String White Space
intro = "     My name is Ahsan      "
print(intro.strip()) # strip remove space from both side
print(intro.lstrip()) # strip remove space from left side
print(intro.rstrip()) # strip remove space from right side


# Remove particular String
intro = "    $$$$ My name is Ahsan    $$$$  "
print(intro.strip("$")) # remove $ from both side

# Remove particular String from left side
intro = "    ######################3My name is Ahsan "
print(intro.lstrip("#")) # remove $ from both side



# Remove particular String from right space
intro = "My name is Ahsan    $$$$$$$$$$$$$$$$$$$$$$$  "
print(intro.rstrip("$")) # remove $ from both side



# Padding and Alignment
# to give padding on right side ijust(anynumber)
demo = "                     Ahsan Raza"
print(demo.ljust(10)) # give 10 space to the right side

# Padding and Alignment
# to give padding on left rjust(anynumber)
print("--------------------------------------------------------------------------")
demo = "Ahsan Raza"
print(demo.rjust(10)) # give 10 space to the left side


# To make text /String center and give any sign/space or any char to both side
# Note things to remeber  imagine my name is Ahsan and i give name.center(10, '*')
# so see my name length is 5 char so it add * more sterik to complete it to 10 len on both side
# eg ahsan = 5 + 5 sterik '*'       **Ahsan***   if one more remaining it give it to right side
heading = "Heading"
print(heading.center(15, '*'))


# Spliting and Joining
 
 # .split return a list

split_text = "MynameisAhsanRaza"
print(split_text.split(" "))   

split_text = "MynameisAhsanRaza"
print(split_text.split("' ',2")) # give first 2 string space--------------------------------------


# z.fill (same as center but it give 0s only to left side)
name = "Ahsan"
print(name.zfill(10))   # 00000Ahsan     it give all 0 to the left side and make len equal to number you give
# REMAINING PART@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# .split


Message  ="""  
Here is my message 
          Here it is
"""
print(Message.splitlines())


# .join() to joun two string or make list to string

list_items = ["abc", "123", "hah"]
print(" ".join(list_items))

dot_str = "Hi.There.How.Are.You.Sir"# return tuple
print(dot_str.partition("."))

text = "Ahsan Raza Talpur"
print(text.partition(" ")) # ('Ahsan', " ", "Raza Talpur")


# Padding and alignment
name = "Alice"
print(f"'{name:>10}'")  # give space to left and make content right to complete 10 len
print(f"'{name:<10}'")  # give space to right and make content lrft to complete 10 len
print(f"'{name:^10}'")  # give space to both side  and make content center to complete 10 len

# f-String

#-----------------

price = 19.99
number = 12345.678
percentage = 0.834


print(f"Price : pkr {price:.2f}") # 2 decimal points
print(f"Price : pkr {price:.2}") # then add 6 zero '0'
print(f"Price : pkr {price:.1%}") # one 0 after decimal
print(f"Price : pkr {price:.2%}") # two 0 after decimal




# Binary conversion

price = 234
print(f"Binary of {price} :  {price:b}") # Binary conversion
print(f"Hexadecimal of {price} :  {price:x}") # Hexadecimal conversion
print(f"Octal of {price} :  {price:o}") # octal conversion


#str . format()              Method

name = "Alice"
age = 20
print("My name is {} and my caste is {}".format(name, age) )
print("My name is {1} and my caste is {0}".format(name, age) ) # we can use index


# Regular Expression (Re)
# Re  use to search , match and manipulate text using pattern

# \d # i need digit
# \w # i need word (letter , digit, or underscore)
# \s # i whitespace
# * # 0 or  more , ...
# \b word boundary


#                                     *** regex ***
import re
print(re.findall(r"a", "Hellow World"))
print(re.findall(r"[aeiou]", "Hellow World"))
print(re.findall(r"[a-z]", "Hellow World"))  # a to z lowercase


print(re.findall(r"o", "Hellow World 123"))
print(re.findall(r"\d", "Hellow World 123"))
print(re.findall(r"\D", "Hellow World 123"))  # non digit
print(re.findall(r"\w", "Hellow World 123"))
print(re.findall(r"\W", "Hellow World 123"))
print(re.findall(r"\s", "Hellow World 123"))



# Common regex Pattern

# $ mean end

email_pattern = r"^[\W\.-] + @ [\w \.-] + \. \w+$"
print(re.match(email_pattern, "abc122@gmail.com" ))

# rematch only match at the begining

