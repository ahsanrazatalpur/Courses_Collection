FILE_NAME = 'Task.txt'

# function to add a new task
# open file , write and show msg 

print("Name :  Ahsan Raza Talpur ")

# ADD A task
def add_task(task):
    with open(FILE_NAME, "a") as f:
        f.write(task + "\n")
    print(f"TASK '{task}' Has Been Added")


# another function to view the task  (we use try except in case of our task is empty)

# view All task
def view_task():
    try:
        with open(FILE_NAME, "r") as f:
            tasks = f.readlines()
        if not tasks:
            print("Task not found!")
        else:
            for i, task in enumerate(tasks, start=1):
                print(f"{i} - {task.strip()}")
            # strip to remove useless space (left right space)
    except FileNotFoundError:
        print("File does not exist")


def update_task(task_no, new_task):   
    try:
        with open(FILE_NAME, "r") as f:
            tasks = f.readlines()

        if task_no <= 0 or task_no > len(tasks):
            print("Invalid Task")
            return 
       
        tasks[task_no - 1] = new_task + "\n"
        with open(FILE_NAME, "w") as f:
            f.writelines(tasks)

        print(f"Task {task_no} updated Successfully.. to '{new_task}' ")
    except FileNotFoundError:
        print(f"File with task number {task_no} Does not Exist")


# function to delete task
def delete_task(task_no):
    try:
        with open(FILE_NAME, "r") as f:
            tasks = f.readlines()
        if task_no <= 0 or task_no > len(tasks):
            print("Invalid task number ..")
            return
       
        deleted = tasks.pop(task_no - 1)

        with open(FILE_NAME, "w") as f:
            f.writelines(tasks)

        print(f"Task deleted '{deleted.strip()}'")
    except FileNotFoundError:
        print(f"File having task number {task_no} not found")


# function where all function exist and call 
def main():
    while True:
        print("")
        print(" ***                              TO DO LIST                           ***")
        print("1. VIEW TASKS")
        print("2. ADD TASK")
        print("3. UPDATE TASK ")
        print("4. DELETE TASK")
        print("5. EXIT")

        try:
            choices = int(input("Enter any number 1 to 5:  "))
        except ValueError:
            print("Invalid input! Please enter a number.")
            continue

        if choices == 1:
            view_task()
        elif choices == 2:
            task = input("Enter a task: ")
            add_task(task)
        elif choices == 3:
            view_task()
            try:
                task_no = int(input("Enter a task number : "))
                new_task = input("Enter a new task: ") 
                update_task(task_no, new_task)
            except ValueError:
                print("Invalid input")
        elif choices == 4:
            view_task()
            try:
                task_no = int(input("Enter task number to delete: "))
                delete_task(task_no)
            except ValueError:
                print("Invalid input")
        elif choices == 5:
            print("EXITING FROM LIST APPP...........")
            break
        else:
            print("Please enter any number from 1 to 5")


# if you want to run directly
if __name__ == "__main__":
    main()
