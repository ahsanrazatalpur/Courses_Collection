
# QNo 1 
class Emplyee:
    name = "Ahsan Raza"
    salary = 20000

    def __init__(self, name = "anyname", salary = "anysalary"):
        self.name = name
        self.salary = salary

    def display_info(self):
        print(f"The employe name is {self.name}")
        print(f"The employe name is {self.salary}")

    show_data = ("Ahsan Raza Talpur", 500000)
    show_data.display_info()
