# Import required libraries
import csv  # For reading and writing CSV files
import os  # For file path operations
from datetime import datetime, timedelta  # For handling dates

# --- Configuration Constants ---
BASE_DIR = os.getcwd()  # Save CSV files in the current working directory
BOOKS_FILE = os.path.join(BASE_DIR, 'books.csv')  # Absolute path
MEMBERS_FILE = os.path.join(BASE_DIR, 'members.csv')
TRANSACTIONS_FILE = os.path.join(BASE_DIR, 'transactions.csv')
DATE_FORMAT = '%Y-%m-%d'  # Standard date format used in system
BORROW_PERIOD_DAYS = 14  # Number of days a book can be borrowed


class Library:
    def __init__(self):
        self._ensure_csv_files_exist()  # Ensure CSV files exist first
        # Initialize in-memory lists for data
        self.books = []  # List of all books
        self.members = []  # List of all members
        self.transactions = []  # List of all transactions
        self._load_data()  # Load data from CSV files

    # --- Ensure CSV files exist ---
    def _ensure_csv_files_exist(self):
        """Create CSV files with headers if they don't exist."""
        if not os.path.exists(BOOKS_FILE):
            with open(BOOKS_FILE, 'w', newline='', encoding='utf-8') as f:
                writer = csv.writer(f)
                writer.writerow(['book_id', 'title', 'author', 'isbn', 'total_copies', 'available_copies'])

        if not os.path.exists(MEMBERS_FILE):
            with open(MEMBERS_FILE, 'w', newline='', encoding='utf-8') as f:
                writer = csv.writer(f)
                writer.writerow(['member_id', 'name', 'phone', 'email'])

        if not os.path.exists(TRANSACTIONS_FILE):
            with open(TRANSACTIONS_FILE, 'w', newline='', encoding='utf-8') as f:
                writer = csv.writer(f)
                writer.writerow(['transaction_id', 'book_id', 'member_id', 'borrow_date', 'due_date', 'return_date'])

    # --- Utility Methods for Data Persistence (CSV) ---
    def _load_csv(self, filename, fieldnames):
        """Loads data from a CSV file."""
        if not os.path.exists(filename):  # If file doesn't exist
            return []  # Return empty list
        with open(filename, mode='r', newline='', encoding='utf-8') as file:
            reader = csv.DictReader(file, fieldnames=fieldnames)
            next(reader, None)  # Skip header
            return list(reader)

    def _save_csv(self, filename, fieldnames, data):
        """Saves data to a CSV file."""
        with open(filename, mode='w', newline='', encoding='utf-8') as file:
            writer = csv.DictWriter(file, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(data)

    def _load_data(self):
        """Loads all data sets from their respective CSV files."""
        # Load books
        self.books = self._load_csv(
            BOOKS_FILE, ['book_id', 'title', 'author', 'isbn', 'total_copies', 'available_copies']
        )
        # Convert string counts to integers
        for book in self.books:
            try:
                book['total_copies'] = int(book['total_copies'])
                book['available_copies'] = int(book['available_copies'])
            except ValueError:
                print(f"Warning: Failed to convert copies for book ID {book.get('book_id')}")

        # Load members
        self.members = self._load_csv(
            MEMBERS_FILE, ['member_id', 'name', 'phone', 'email']
        )

        # Load transactions
        self.transactions = self._load_csv(
            TRANSACTIONS_FILE, ['transaction_id', 'book_id', 'member_id', 'borrow_date', 'due_date', 'return_date']
        )

        print(f"\nData loaded: {len(self.books)} books, {len(self.members)} members, {len(self.transactions)} transactions.")

    def _save_data(self):
        """Saves all current in-memory data back to CSV files."""
        self._save_csv(
            BOOKS_FILE, ['book_id', 'title', 'author', 'isbn', 'total_copies', 'available_copies'], self.books
        )
        self._save_csv(
            MEMBERS_FILE, ['member_id', 'name', 'phone', 'email'], self.members
        )
        self._save_csv(
            TRANSACTIONS_FILE, ['transaction_id', 'book_id', 'member_id', 'borrow_date', 'due_date', 'return_date'], self.transactions
        )
        print("\n[SUCCESS] All data has been saved.")

    def _generate_id(self, data_list, prefix):
        """Generates a new unique ID (e.g., B001, M005, T010)."""
        key_map = {'B': 'book_id', 'M': 'member_id', 'T': 'transaction_id'}
        key = key_map[prefix]
        if not data_list:
            return f"{prefix}001"
        try:
            last_id = data_list[-1][key]
            last_number = int(last_id[len(prefix):])
            return f"{prefix}{last_number + 1:03d}"
        except Exception:
            return f"{prefix}{len(data_list) + 1:03d}"

    # --- Table Display Utility ---
    def _print_table(self, title, headers, data):
        if not data:
            print(f"\n--- {title} ---")
            print("No records found.")
            return

        widths = {h: len(h) for h in headers}
        for row in data:
            for h in headers:
                widths[h] = max(widths[h], len(str(row.get(h, ''))))

        total_width = sum(widths.values()) + len(headers) * 3 + 1
        print(f"\n{'-' * total_width}")
        print(f"| {title.center(total_width - 4)} |")
        print(f"{'=' * total_width}")
        header_line = "|"
        for h in headers:
            header_line += f" {h.center(widths[h])} |"
        print(header_line)
        print(f"{'-' * total_width}")

        for row in data:
            row_line = "|"
            for h in headers:
                row_line += f" {str(row.get(h, '')).ljust(widths[h])} |"
            print(row_line)
        print(f"{'=' * total_width}")

    # --- Library Operations ---
    def display_all_books(self):
        books_data = [{'book_id': b['book_id'], 'Title': b['title'], 'Author': b['author'],
                       'ISBN': b['isbn'], 'Total': b['total_copies'], 'Available': b['available_copies']}
                      for b in self.books]
        self._print_table("ALL BOOKS IN LIBRARY",
                          ['book_id', 'Title', 'Author', 'ISBN', 'Total', 'Available'], books_data)

    def display_available_books(self):
        available_books = [b for b in self.books if b['available_copies'] > 0]
        books_data = [{'book_id': b['book_id'], 'Title': b['title'], 'Author': b['author'],
                       'ISBN': b['isbn'], 'Available': b['available_copies']}
                      for b in available_books]
        self._print_table("AVAILABLE BOOKS", ['book_id', 'Title', 'Author', 'ISBN', 'Available'], books_data)

    def display_all_members(self):
        members_data = [{'member_id': m['member_id'], 'Name': m['name'], 'Phone': m['phone'], 'Email': m['email']}
                        for m in self.members]
        self._print_table("ALL LIBRARY MEMBERS", ['member_id', 'Name', 'Phone', 'Email'], members_data)

    def search_books(self):
        query = input("Enter search term (Title, Author, or ISBN): ").lower().strip()
        if not query:
            print("[INFO] Search query cannot be empty.")
            return
        results = [b for b in self.books if query in b['title'].lower() or query in b['author'].lower() or query == b['isbn'].lower()]
        books_data = [{'book_id': b['book_id'], 'Title': b['title'], 'Author': b['author'],
                       'ISBN': b['isbn'], 'Available': b['available_copies']}
                      for b in results]
        self._print_table(f"SEARCH RESULTS for '{query}'",
                          ['book_id', 'Title', 'Author', 'ISBN', 'Available'], books_data)

    def borrow_book(self):
        book_id = input("Enter Book ID: ").strip().upper()
        member_id = input("Enter Member ID: ").strip().upper()
        book = next((b for b in self.books if b['book_id'] == book_id), None)
        member = next((m for m in self.members if m['member_id'] == member_id), None)
        if not book:
            print(f"[ERROR] Book '{book_id}' not found.")
            return
        if not member:
            print(f"[ERROR] Member '{member_id}' not found.")
            return
        if book['available_copies'] <= 0:
            print(f"[ERROR] No copies of '{book['title']}' available.")
            return
        active = next((t for t in self.transactions if t['book_id'] == book_id and t['member_id'] == member_id and t['return_date'] == ''), None)
        if active:
            print("[ERROR] Member already borrowed this book.")
            return
        book['available_copies'] -= 1
        transaction_id = self._generate_id(self.transactions, 'T')
        borrow_date = datetime.now().strftime(DATE_FORMAT)
        due_date = (datetime.now() + timedelta(days=BORROW_PERIOD_DAYS)).strftime(DATE_FORMAT)
        self.transactions.append({
            'transaction_id': transaction_id,
            'book_id': book_id,
            'member_id': member_id,
            'borrow_date': borrow_date,
            'due_date': due_date,
            'return_date': ''
        })
        self._save_data()
        print(f"[SUCCESS] '{book['title']}' borrowed by {member['name']} until {due_date}.")

    def return_book(self):
        book_id = input("Enter Book ID: ").strip().upper()
        member_id = input("Enter Member ID: ").strip().upper()
        book = next((b for b in self.books if b['book_id'] == book_id), None)
        if not book:
            print(f"[ERROR] Book '{book_id}' not found.")
            return
        active_txn = next((t for t in self.transactions if t['book_id'] == book_id and t['member_id'] == member_id and t['return_date'] == ''), None)
        if not active_txn:
            print("[ERROR] No active borrow found for that book/member.")
            return
        active_txn['return_date'] = datetime.now().strftime(DATE_FORMAT)
        book['available_copies'] += 1
        self._save_data()
        print(f"[SUCCESS] '{book['title']}' returned successfully.")

    def edit_book_info(self):
        """Edit existing book information."""
        book_id = input("Enter Book ID to update: ").strip().upper()
        book = next((b for b in self.books if b['book_id'] == book_id), None)
        if not book:
            print(f"[ERROR] Book '{book_id}' not found.")
            return
        print("\nCurrent Book Details:")
        print(f"Title: {book['title']}")
        print(f"Author: {book['author']}")
        print(f"ISBN: {book['isbn']}")
        print(f"Total Copies: {book['total_copies']}")
        print(f"Available Copies: {book['available_copies']}")
        print("\nEnter new details (press Enter to keep existing):")
        new_title = input("New Title: ").strip()
        new_author = input("New Author: ").strip()
        new_isbn = input("New ISBN: ").strip()
        new_total_copies = input("New Total Copies: ").strip()
        if new_title:
            book['title'] = new_title
        if new_author:
            book['author'] = new_author
        if new_isbn:
            book['isbn'] = new_isbn
        if new_total_copies:
            try:
                total = int(new_total_copies)
                if total < book['total_copies'] - book['available_copies']:
                    print("[WARNING] Cannot reduce below number currently borrowed.")
                else:
                    diff = total - book['total_copies']
                    book['total_copies'] = total
                    book['available_copies'] += diff
            except ValueError:
                print("[ERROR] Invalid number for total copies.")
        self._save_data()
        print(f"[SUCCESS] Book '{book_id}' updated.")

    def register_new_member(self):
        name = input("Enter Name: ").strip()
        phone = input("Enter Phone: ").strip()
        email = input("Enter Email: ").strip()
        member_id = self._generate_id(self.members, 'M')
        self.members.append({'member_id': member_id, 'name': name, 'phone': phone, 'email': email})
        self._save_data()
        print(f"[SUCCESS] Member '{name}' added successfully.")

    # --- New Features Added ---
    def add_new_book(self):
        """Add a new book to the library."""
        title = input("Enter Title: ").strip()
        author = input("Enter Author: ").strip()
        isbn = input("Enter ISBN: ").strip()
        try:
            total = int(input("Enter total copies: ").strip())
        except ValueError:
            print("[ERROR] Invalid number for total copies.")
            return

        book_id = self._generate_id(self.books, 'B')
        new_book = {
            'book_id': book_id,
            'title': title,
            'author': author,
            'isbn': isbn,
            'total_copies': total,
            'available_copies': total
        }

        self.books.append(new_book)
        self._save_data()
        print(f"[SUCCESS] Book '{title}' added successfully with ID {book_id}.")

    def delete_book(self):
        """Delete a book record from library."""
        book_id = input("Enter Book ID to delete: ").strip().upper()
        book = next((b for b in self.books if b['book_id'] == book_id), None)
        if not book:
            print(f"[ERROR] Book '{book_id}' not found.")
            return
        borrowed = any(t['book_id'] == book_id and not t['return_date'] for t in self.transactions)
        if borrowed:
            print("[ERROR] Cannot delete — book is currently borrowed.")
            return
        self.books.remove(book)
        self._save_data()
        print(f"[SUCCESS] Book '{book_id}' deleted.")

    def delete_member(self):
        """Delete a member from library."""
        member_id = input("Enter Member ID to delete: ").strip().upper()
        member = next((m for m in self.members if m['member_id'] == member_id), None)
        if not member:
            print(f"[ERROR] Member '{member_id}' not found.")
            return
        borrowed = any(t['member_id'] == member_id and not t['return_date'] for t in self.transactions)
        if borrowed:
            print("[ERROR] Cannot delete member — they have active borrows.")
            return
        self.members.remove(member)
        self._save_data()
        print(f"[SUCCESS] Member '{member_id}' deleted.")

    def library_report(self):
        """Display summary of library status."""
        total_books = len(self.books)
        total_members = len(self.members)
        borrowed = sum(1 for t in self.transactions if not t['return_date'])
        returned = sum(1 for t in self.transactions if t['return_date'])
        print("\n===== LIBRARY REPORT =====")
        print(f"📚 Total Books: {total_books}")
        print(f"👤 Total Members: {total_members}")
        print(f"📖 Currently Borrowed: {borrowed}")
        print(f"✅ Returned: {returned}")
        print("===========================")

    def run(self):
        menu = {
            1: self.display_all_books,
            2: self.display_available_books,
            3: self.display_all_members,
            4: self.search_books,
            5: self.borrow_book,
            6: self.return_book,
            7: self.library_report,
            8: self.add_new_book,
            9: self.register_new_member,
            10: self.edit_book_info,
            11: self.delete_book,
            12: self.delete_member
        }
        while True:
            print("\n" + "=" * 50)
            print("LIBRARY MANAGEMENT SYSTEM")
            print("=" * 50)
            print("1. Display All Books")
            print("2. Display Available Books")
            print("3. Display All Members")
            print("4. Search Books")
            print("5. Borrow a Book")
            print("6. Return a Book")
            print("7. Library Report")
            print("8. Add New Book")
            print("9. Register New Member")
            print("10. Edit / Update Book Info")
            print("11. Delete Book")
            print("12. Delete Member")
            print("0. Exit")
            print("=" * 50)
            choice = input("Enter choice (0-12): ").strip()
            if choice == '0':
                self._save_data()
                print("Goodbye!")
                break
            try:
                choice_int = int(choice)
                if choice_int in menu:
                    menu[choice_int]()
                else:
                    print("[ERROR] Invalid choice.")
            except ValueError:
                print("[ERROR] Enter a number.")


# Entry point
if __name__ == "__main__":
    library = Library()
    library.run()
