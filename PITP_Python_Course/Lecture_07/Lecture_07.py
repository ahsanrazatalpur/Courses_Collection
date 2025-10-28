
# ****                                        List                                         ****
# List are Ordered
# List are Mutable Collection
# List can hold different type of data
# List enclosed in []


# # Empty list
# list_empty = []
# print(list_empty)
# print(type(list_empty))


# # List With integer
# li2 = [1, 2, 3 ,4 ,5]
# print(li2)
# print(type(li2))
# print(li2[0])  # Print specific Data of list

# # List with String 
# li3 = ["Ahsan", "Asad", "Ahmed"]
# print(li3)
# print(type(li3))


# # List with mix Data
# li4 = [23, "Ahsan", True, 3.0]
# print(li4)
# print(type(li4))


# Nested List
# nested_list = [
#     [1, 2 ,3 ,4 ,5],
#     [True, False],
#     [30 , 430.0],
#     ["Ahsan", "Asad"]
# ]

# print(nested_list)
# print(nested_list[2][0])



# ***                                  LIST OPERATION                                     ***

# fruits = ["Apple", "Banana", "Grapes", "WaterMelon"]
# number = list(range(11))

# print(fruits)
# print(number)
# print(type(number)) # List

# print(fruits[0]) # First element
# print(fruits[3])

# print(fruits[-1]) # Last element
# print(fruits[-3])


# ***                           Adding Element                         ***
# There are several function to add in list
# .append(value)   add value in the last
# .insert(index , value)  add value in the indexth position
# .extend(iterable) add / merge two iterable or list

# .append(value)
# my_list = [1, 2, 3, 4, 5]
# print(my_list)
# new_list = my_list.append(6)
# print(my_list)


# insert(index , value)
# li = [1, 2, 4, 5 ,6]
# print(li)
# li.insert(2, 3)
# print(li) # add 3 in 2 index

# li3 = [2, 4, 8, 10]
# print(li3)
# li3.insert(2,6)
# print(li3)


#                           *** Removing element ***
# There are also many function to remove from list
# .remove(value) remove value 
# .pop(index) remove value on that index
# .clear() clear all list

# li = [1, 2, 3, 4, 5, 6]
# li.remove(6)
# print(li)

# li = [2, 4 ,6 ,8, 10, 11]
# li.pop(0) # remove indexth value
# li.pop()  # remove last value
# print(li)

#clear()
# li = [1, 2, 3 ,4 ,5 ,6 ,7, 8 ,9, 10]
# li.clear()
# print(li) # clear all list



# Modifying Element in list
# li = [12, 13, 14, 15]
# li[0] = 11
# print(li)  # modile list


#                              ***Others Common Method***
# .len(list)  return the length of list
# list.count(value)  count the occurence of an item
# list.sort() sort the list in asending order
# .sorted()  function to rturn new list
# list.reverse()  reverse the list


# # .len(list)
# li = [1, 2, 3 ,4 ,5]
# print(len(li))


# #list.count(value)
# li = [1, 2, 3, 1 ,5 ,6, 8 ,1]
# print(li.count(1))


# #.sort()
# li = [3, -1, 100, 65, 8, 0]
# li.sort() # return None sort original list
# print(li)

# li = [2, 90, -1, -11, 9]
# new_li = sorted(li)
# print(new_li) # return new list

# li = [1, 2, 3, 4, 5]
# print(li.reverse()) # None
# print(li)


# li = [3, -1, 100, 65, 8, 0]
# li.sort(reverse=True) # decending sorting
# print(li)

#                         ***Copying List***
# li = [2, 4, 6 ,8]
# Shalow_copy = li.copy()
# print(Shalow_copy)

# # ANother way by slicing
# Shalow_copy2  =li[:]
# print(Shalow_copy2)

# Shalow_copy3  =list(li)
# print(Shalow_copy3)


# List Concatenation (combined 2 list)
# li1 = [1, 3, 5, 7 ,9]
# li2 = [0, 2, 4 , 6, 8]
# combined = li1 + li2
# print(combined)

# Repeat List
# li = [1, 2, 3]
# print(li * 3) # list repeat 3 times



#                                                  ***Slicing***

# Sublist(part of list) of a list
# list = [start : end : stepover]
# li = [2, 4 ,6, 8]
# print(li[1:3])

# li = [1, 2 ,3, 4, 5, 6, 7, 8]
# print(li[2:5])

# print(li[:])  # mean start from 0 end till last
# print(li[:4])  # mean start from 0 end at 4
# print(li[3:])  # mean start from 3 end till last
# print(li[3:])  # mean start from 3 end at last
# print(li[2:5]) # mean start from 2 end at 5

# print(li[2:5:2]) # mean start from 2 end at 5 and skip 1 number
# print(li[2:5:3]) # mean start from 2 end at 5 and skip 2 number
# print(li[::-1]) # mean start last and end at first (reverse the list)
# print(li[1:-2]) # mean start last 2nd and end at 1 
# print(li[-3:]) # mean last 3 


# modigy the list
# my_list = [1, 2, 3, 4, 5, 6]
# my_list [2:5]=[20, 30, 40] # replace
# my_list[2:2] = [23, 45]  # modify
# my_list[2:4] = []  # delete elelmnt 



# Comperhension
# sqr = [x**2 for x in range(11)]
# print(sqr)


# even = [x for x in range(11) if x%2 == 0]
# print(even)

# fruits = ["Banana", "Apple", "Grapes", "Watermelon"]
# frt = [fruit for fruit in fruits if len(fruit) > 5]
# print(frt)


# Tuple
# tuple are ordered
# imutable collabration
# similar to list but cannot change once created 

# empty = ()

# my_tuple = (1, 4.0, True, "Ahsan")
# print(my_tuple)
# print(type(my_tuple))

# single = (24,)
# print(single)
# print(type(single))

# another_tup = 1, 3 , 6
# print(type(another_tup))


# tuple packing and unpacking

# packed = (2, 4, 6 ,7)
# num1 ,num2, num3, num4 = packed
# print(num1)
# print(num2)
# print(num3)
# print(num4)

