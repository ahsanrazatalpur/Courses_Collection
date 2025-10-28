# List

# number_list = [1, 23, 4, 6, 67, 3]
# for i in range len(number_list):

# empty = []
# number_list = [1, 2,  3, 4, 5]
# mixed_list = [True, 1.4, "Hello World , 13"]

# nested_list = [
#     [1, 2, 3, 4],
#     [5, 6, 7, 8]
# ]


# vegetables = ["potattoes", "Brinjal", "Cababgae", "LadyFinger", "Onion"]

# print(vegetables[0])
# print(vegetables[-1])
# print(vegetables[-2])

# for i in nested_list:
#     for j in:
#        if j == 4:
#         print(j, end=" ")
#     print()


# 2. List operation

# append (item)  add at the last any item in the list
# vegetables.append("Chilies")
# print(vegetables)


# insert (item)    add at particular indexx
# vegetables.insert(0, "Ginger")
# print(vegetables)

# extend (Iterable)   # multiple elements
# vegetables.extend(["Banana", "Grapes", "WatreMelon"])
# print(vegetables)

# len()
# len(vegetables)

# remove(item)    to rmeove anyt element

# vegetables.remove("Grapes")
# vegetables.remove(vegetables[0])
# print(vegetables)


# .pop()  remove and return last element
# vegetables.pop()
# print(vegetables)

# vegetables.pop(2) # remove and return index item

# print(vegetables.pop(-2))

# del 
# del vegetables[-3]


# replace

# vegetables[0] = "Meat"  # mera jisam meri marzi
# print(vegetables)

# count()
# vegetables.count("laddyfinger")
# vegetables.count("Meat")


# .index() return the index of item
# vegetables.index("Ladyfinger") 


# acces each element throgh llop
# e_list = []
# count = 0
# fruits= ["mango", "banana", "grapes"]
# for fruit in fruits:
#     if fruit == "grapes":
#         e_list.append(count)
#         count+= 1
# print(e_list)



# num_list = [7, 19, 1, 0 , -8, 100]
# print(num_list)
# # num_list.sort() # ascending order
# num_list.sort(reverse = True)  # descending order
# print(num_list)
# num_list.reverse()
# print(num_list)



# copy
# li = [23, 34, 456, 54]
# li_2 = li.copy()
# li_2 = li[:]
# li_2 = li[:4]
# li_2 = li[1:]
# li_2 = li[0:3]
# li_2 = li
# li_2 = list(li)

# print(li_2)


# veg = ["cabage", "brinjal", "onion"]
# fru = ["banana", "grapes", "melon"]

# comb = veg  + fru
# rep = veg * 3     # repeat 


# slicing
# start , end, stepover

# li = [1 ,2, 3, 4, 4]
# sl = li[0:3]
# print(sl)

# reverse through indesing

# li = [1, 3, 5, 6]
# print(li[::-1])

# print(li[::-2])

# i = [1, 3, 5, 6]
# print(i[::-1]) # last element
# print(i[::-2])  # 2nd last elemet
# last 2 nh chye
# print(i[:-2])  # 2 last elemet



# list cpmperhension

# square = [x**2 for x in range(10)]
# print(square) # square of each element like 0x0 1x1 2x2 3x3......

# sq = [x**2 for x in range(11)]
# print(sq)


# sqr = [x **2-x  for x in range (11)]
# print(sqr)

# even = [x for x in range(10) if x %2 == 0]
# print(even)

# fruits = ["Apples", "Bannana", "Cherry"]

for i in range(5):
    print(i)