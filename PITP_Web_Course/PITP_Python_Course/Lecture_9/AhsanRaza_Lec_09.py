# Qno  1

name  = input("Enter your name : ")
print(name.upper())


# # Qno  2

fruit = "banana"
print(fruit.count("a"))


# # QNo 3 
number = 1243.5678
print(f"{number:.2f}")


# QNo 4
import re
my_str = "Order number : 12345, Date : 2025-10-12"
print(re.findall(r"\d", my_str))

# Qno 5
print(my_str.replace(" ", "-"))