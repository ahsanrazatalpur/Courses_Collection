
# Inheritance : Taking data from parent class to child

# class ParentClass :
    # Parent class have some methods  and atribiute 

# class ChildClass :  # inheritance
    # Child class use attribute and methods of parent class
    # and can have own methods


# Type of inheritance 
# One child class can inherit from another one parent class


# Parent Class
class Vehicle:
    def __init__(self, brand, model, year):
        self.brand = brand
        self.model = model
        self.year = year
        
    def engine_start(self):
        print(f"The {self.brand} car engine has started! 💨💨")
    
    def engine_off(self):
        print(f"The {self.model} car engine has been off  🚫🚫")

    def display_info(self):
        print(f"My car name is {self.brand} \nand It is {self.model} Model \nand {self.year} Runs")

show_data = Vehicle("Toyota", 2026, 2025)
show_data.display_info()


class Car(Vehicle):
    def __init__(self, brand, model, year,  car_door ): # call constructor
        super().__init__( brand, model, year)  # call parent constructor
        self.car_door  = car_door # new attribue
    
    # now car class have method of vehicle class and its own
    
    def display_info2(self):
        print(f"My car is {self.brand}")
        print(f"My car model is {self.model}'s year")
        print(f"My car have {self.car_door} Doors")
        print(f"I bought this car in {self.year} YAHOO")

data = Car("Honda", 2025, 2026, 4)
data .display_info2()
data.display_info()
data.engine_off()
data.engine_start()



