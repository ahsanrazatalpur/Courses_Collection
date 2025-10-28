import csv
import os
from datetime import date, timedelta

class Library:
    def __init__(self):
        self.books_file = "books.csv"
        self.members_file = "members.csv"
        self.transactions_file = "transactions.csv"

        self.books = []
        self.members = []
        self.transactions = []

        self.next_book_id = 104
        self.next_member_id = 3
        self.due_period_days = 7

        self.load_data()

        if not self.books:
            self.books = [
                {'id': 101, 'title': 'Python Programming', 'author': 'Guido van Rossum', 'category': 'Technology', 'total_copies': 5, 'available_copies': 5},
                {'id': 102, 'title': 'The Great Gatsby', 'author': 'F. Scott Fitzgerald', 'category': 'Fiction', 'total_copies': 3, 'available_copies': 2},
                {'id': 103, 'title': 'Data Structures in C++', 'author': 'Various', 'category': 'Computer Science', 'total_copies': 2, 'available_copies': 0},
            ]
            self.members = [
                {'id': 1, 'name': 'Alice Johnson'},
                {'id': 2, 'name': 'Bob Smith'},
            ]
            self.transactions = []
            self.save_data()

    # ================= CSV SAVE/LOAD =================
    def save_data(self):
        if self.books:
            with open(self.books_file, "w", newline="", encoding="utf-8") as f:
                writer = csv.DictWriter(f, fieldnames=self.books[0].keys())
                writer.writeheader()
                writer.writerows(self.books)

        if self.members:
            with open(self.members_file, "w", newline="", encoding="utf-8") as f:
                writer = csv.DictWriter(f, fieldnames=self.members[0].keys())
                writer.writeheader()
                writer.writerows(self.members)

        with open(self.transactions_file, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=["member_id", "book_id", "borrow_date", "due_date"])
            writer.writeheader()
            for t in self.transactions:
                writer.writerow({
                    "member_id": t["member_id"],
                    "book_id": t["book_id"],
                    "borrow_date": t["borrow_date"].isoformat(),
                    "due_date": t["due_date"].isoformat()
                })

    def load_data(self):
        if os.path.exists(self.books_file) and os.path.getsize(self.books_file) > 0:
            with open(self.books_file, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                self.books = [
                    {'id': int(r['id']), 'title': r['title'], 'author': r['author'],
                     'category': r['category'], 'total_copies': int(r['total_copies']),
                     'available_copies': int(r['available_copies'])} for r in reader
                ]

        if os.path.exists(self.members_file) and os.path.getsize(self.members_file) > 0:
            with open(self.members_file, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                self.members = [{'id': int(r['id']), 'name': r['name']} for r in reader]

        if os.path.exists(self.transactions_file) and os.path.getsize(self.transactions_file) > 0:
            with open(self.transactions_file, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                self.transactions = [
                    {'member_id': int(r['member_id']), 'book_id': int(r['book_id']),
                     'borrow_date': date.fromisoformat(r['borrow_date']),
                     'due_date': date.fromisoformat(r['due_date'])} for r in reader
                ]

    # ================= DISPLAY CLEANUP =================
    def display_all_books(self):
        self.load_data()
        print("\n📚 ──────── ALL LIBRARY BOOKS ──────── 📚")
        if not self.books:
            print("❌ No books available.")
            return
        print(f"{'ID':<5} {'TITLE':<30} {'AUTHOR':<25} {'CATEGORY':<20} {'AVAILABLE/TOTAL'}")
        print("─" * 95)
        for b in self.books:
            print(f"{b['id']:<5} {b['title']:<30} {b['author']:<25} {b['category']:<20} {b['available_copies']}/{b['total_copies']}")
        print("─" * 95)
        print(f"✅ TOTAL BOOKS: {len(self.books)}\n")

    def display_members(self):
        print("\n👥 ──────── ALL MEMBERS ──────── 👥")
        if not self.members:
            print("❌ No members found.")
            return
        print(f"{'ID':<5} {'NAME':<30}")
        print("─" * 40)
        for m in self.members:
            print(f"{m['id']:<5} {m['name']:<30}")
        print("─" * 40)
        print(f"✅ TOTAL MEMBERS: {len(self.members)}\n")

    def search_book(self):
        query = input("\n🔍 Enter book title or author: ").strip().lower()
        results = [b for b in self.books if query in b['title'].lower() or query in b['author'].lower()]
        print("\n📖 ──────── SEARCH RESULTS ──────── 📖")
        if not results:
            print("❌ No matching books found.")
            return
        print(f"{'ID':<5} {'TITLE':<30} {'AUTHOR':<25} {'AVAILABLE/TOTAL'}")
        print("─" * 75)
        for b in results:
            print(f"{b['id']:<5} {b['title']:<30} {b['author']:<25} {b['available_copies']}/{b['total_copies']}")
        print("─" * 75)
        print(f"✅ MATCHES FOUND: {len(results)}\n")

    def view_borrowed_books(self):
        print("\n📕 ──────── BORROWED BOOKS ──────── 📕")
        if not self.transactions:
            print("✅ No borrowed books currently.")
            return
        print(f"{'BOOK TITLE':<30} {'MEMBER NAME':<25} {'DUE DATE':<15}")
        print("─" * 70)
        for t in self.transactions:
            member = next(m for m in self.members if m['id'] == t['member_id'])
            book = next(b for b in self.books if b['id'] == t['book_id'])
            print(f"{book['title']:<30} {member['name']:<25} {t['due_date']}")
        print("─" * 70)
        print(f"📚 TOTAL BORROWED: {len(self.transactions)}\n")

    def member_borrow_history(self):
        member_id = int(input("\nEnter Member ID: "))
        member = next((m for m in self.members if m['id'] == member_id), None)
        if not member:
            print("❌ Member not found.")
            return
        print(f"\n📘 ──────── BORROW HISTORY FOR {member['name']} ──────── 📘")
        history = [t for t in self.transactions if t['member_id'] == member_id]
        if not history:
            print("No active or past borrowings.\n")
            return
        print(f"{'BOOK TITLE':<35} {'DUE DATE'}")
        print("─" * 50)
        for t in history:
            book = next(b for b in self.books if b['id'] == t['book_id'])
            print(f"{book['title']:<35} {t['due_date']}")
        print("─" * 50)
        print(f"📚 TOTAL BORROWED BY MEMBER: {len(history)}\n")

    # (other functions remain same — add_book, reports, etc.)

# ================= MENU =================
def display_menu():
    print("\n" + "="*65)
    print("        📘 LIBRARY MANAGEMENT SYSTEM BY AHSAN RAZA 📘")
    print("="*65)
    print("1️⃣  Display All Books")
    print("2️⃣  Display All Members")
    print("3️⃣  Search Book (by Name/Author)")
    print("4️⃣  View Borrowed Books")
    print("5️⃣  Member Borrow History")
    print("0️⃣  Exit")
    print("="*65)

def main():
    library = Library()
    while True:
        display_menu()
        choice = input("Enter your choice: ")

        if choice == '1': library.display_all_books()
        elif choice == '2': library.display_members()
        elif choice == '3': library.search_book()
        elif choice == '4': library.view_borrowed_books()
        elif choice == '5': library.member_borrow_history()
        elif choice == '0':
            print("💾 Saving data and exiting... ✅")
            library.save_data()
            break
        else:
            print("❌ Invalid choice, try again.")

if __name__ == "__main__":
    main()
