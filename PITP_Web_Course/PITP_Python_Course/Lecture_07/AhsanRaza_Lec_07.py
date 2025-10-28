# QNo  1

numbers = [1, 2, 3, 4, 5]
new_list =numbers[1:4]
print(new_list)
square = [x ** 2 for x in new_list]
print(square)


# Qno 2
data = "Ahsan", 20 , "Badin"
name , age , city = data
print(name)
print(age)
print(city)


# Qno  3
num = 1, 2, 3, 4, 5
# num[0] = 6
# print(num) # TypeError: 'tuple' object does not support item assignment
tup = (
    [1, 2, 3, 4],
    ["Ahsan", "Ali", "Ahmed"]
)
print(type(tup))
tup[0][0] = 6
print(tup)




#                                    *** Exercise # 02 ***

# 1
favourite_movies = ["Iron_man_03", "Bholbhoolay_2", "Spider_Man", "Justice_League", "Welcome_To_Karachi"]

# 2
favourite_movies[2] = "Rock_Star"
print(favourite_movies)

# 3
sub_movies = favourite_movies[:2]
print(sub_movies)

# 4
sqr = [x ** 2 for x in range(11)]
print(sqr)

#5
student = ("Ahsan" , 20, "A+")

#6

name, age, grade = student

print(name)
print(age)
print(grade)