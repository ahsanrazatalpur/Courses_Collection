# Qno  1

# number = int(input("Enter any number :"))

# if number <= 0:
#     print("Invalid number")
# else:
#    for i in range(1,number):
#        if i%3==0:
#            continue
#        print(i)
#        if i==50:
#            break


# Qno  2
# for i in range(1,11):
#     print(i)



# Qno  3
# for i in range(11):
#     if i % 2 == 0:
#         print(i)


# Qno 4

# number = int(input("Enter any number : "))
# for i in range(1,11):
#     print(i ,"x",number,"=", i*number)

   
# Qno6
# n= int(input("Enter a number: "))
# sum=0
# for i in range(1,n+1):
#    sum+=i
# print(sum)

# Qno7
# num=int(input("Enter a Number: "))
# reverse=0
# while num>0:
#    mode = num%10
#    reverse= reverse * 10 +mode
#    num = num//10
# print(f"Revers: {reverse}")

# Qno8
# n= int(input("Enter a number: "))
# count=0
# while(n>0):
#    mod=n%10
#    print(mod)
#    count+=1
#    n=n//10
# print(count)

# Qno9
# text = input("Enter any text to count: ")
# for i in text:
#    print(i)

# Qno10
# n= int(input("Enter a number: "))
# for i in range(n,1,-1):
#    print(i)

# ***                                                         Intermediate Level                                                     ***
# Qno1
# for i in range(1,101):
#    if i%2==0:
#       print(i)

# Qno2
# sum=0
# for i in range(1,101):
#    if i%2==1:
#       sum+=i
# print(sum)

# Qno3
# n = 10
# a,b=0,1
# for i in  range(n):
#     print(a,end=" ")
#     a,b=b,a+b

# Qno4
# num = 44
# is_prime=True
# if num < 2:
#     is_prime = False
# else:
#     for i in range(2,num):
#         if num % i ==  0:
#             is_prime = False
#             break
# print(num,"is Prime " if is_prime else "is not Prime")

 
# Qno5
# for  i in range(2,101):
#     is_prime= True
#     for j in range(2,i):
#         if i % j == 0:
#             is_prime=False
#             break
#     if is_prime:
#         print(i,end=" ")

# Qno6
# rows=5
# for i in range(1,rows+1):
#    for j in range(1,i+1):
#       print("*",end="")
#    print()

# Qno7
# row= 8
# for i in range(1,row+1):
#     print(" "* (row - i),end=" ")
#     for j in range(1,i+1):
#         print(j,end=" ")
#     print()


# Qno8
# number=8
# pow=8
# result=1
# for _ in range(pow):
#     result *= number
# print(result)

# Qno9
# a= int(input("Enter first number: "))
# b= int(input("Enter second number: "))
# while b!=0:
#     a,b=b,a%b
# print(f"GCD is: {a}")

# Qno10
# a= int(input("Enter first number: "))
# b= int(input("Enter second number: "))
# greater = max(a,b)
# while True:
#     if greater % a == 0 and greater % b == 0:
#         print("LCM is greater: ",greater)
#         break
#     greater += 1
        
   
  



   
   


