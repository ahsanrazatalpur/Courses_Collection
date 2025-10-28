# Qno1
def squres(num):
    return num*num

# Qno2
def is_even(num):
    if(num%2==0):
        return True
    return False


# Qno3
def greet_person(name,age):
    print(f"Hellow {name} your age is {age}")

# Qno4
total=100
def spend(amount):
    global total
    total = total-amount
    print(total)


# Qno5
def calculator(a,b,ob):
    a=int(a)
    b=int(b)
    if(ob=="+"):
        return a+b
    elif(ob=="-"):
        return a-b
    elif(ob=="*"):
        return a*b
    elif(ob=="/"):
        if(b==0):
            print("a cannot divide by 0")
        else:
            return a/b
    else:
        print("Invalid")

# Qno6
def calc(a,b):
    return a+b,a-b,a*b


# Qno7
def centimeter(inches):
    inches= inches*2.54
    return inches


spend(500)