import socket
import os

def print_menu():
    os.system('clear') 
    print('Customer Management Menu\n')
    print("1. Find Customer")
    print("2. Add Customer")
    print("3. Delete Customer")
    print("4. Update Customer Age")
    print("5. Update Customer Address")
    print("6. Update Customer Phone")
    print("7. Print Report")
    print("8. Exit")

def check_name(name):
    if name == "":
        print("\nName cannot be an empty string")
        return False
    if not name.isalpha():
        print("\nName must consist only of alphabetic characters")
        return False
    return True

def check_age(age):
    if age == "":
        return True
    if not(age.isnumeric() and int(age) <= 120 and int(age) >= 1):
        print("\nAge should be a number between 1 and 120")
        return False
    return True

def check_address(adr):
    if adr == "":
        return True
    if not adr.replace(' ', '').replace('.', '').replace('-', '').isalnum():
        print("\nAdress can only contain alphanumeric characters, spaces, periods (‘.’), or dashes (‘-‘)")
        return False
    return True

def check_phone(phone):
    if phone == "" :
        return True
    if not(len(phone) == 8 or len(phone) == 12) or phone[-5] != '-':
        print("\nPhone number has either 7 or 10 numbers and there should be a dash before the final 4 digits")
        return False
    if len(phone) == 12 and phone[3] != " ":
        print("\n10 digit phone numbers should have a space between the 3rd and 4th numbers")
        return False
    if (len(phone)==8 and not(phone[:3]+phone[4:]).isnumeric()) or (len(phone)==12 and not(phone[:3]+phone[4:7]+phone[8:]).isnumeric()):
        print("\nPhone number contains non-numeric characters in the wrong places")
        return False
    return True       



HOST, PORT = "localhost", 9999

while(True):
    print_menu()
    data = input("Select: ")

    if not data.isnumeric() or int(data) < 1 or int(data) > 8:
        continue

    if data == "8":
        print("Goodbye")
        break

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.connect((HOST, PORT))
        sock.sendall(bytes(data + "\n", "utf-8"))

        if int(data) >= 1 and int(data) <= 6:
            name = input("Customer Name: ").strip()
            while(not check_name(name)):
                name = input("Customer Name: ").strip()
            sock.sendall(bytes(name + "\n", "utf-8"))
        if data == "2":
            age = input("Customer Age: ").strip()
            while(not check_age(age)):
                age = input("Customer Age: ").strip()
            sock.sendall(bytes(age + "\n", "utf-8"))
            address = input("Customer Address: ").strip()
            while(not check_address(address)):
                address = input("Customer Address: ").strip()
            sock.sendall(bytes(address + "\n", "utf-8"))
            phone = input("Customer Phone: ").strip()
            while(not check_phone(phone)):
                phone = input("Customer Phone: ").strip()
            sock.sendall(bytes(phone + "\n", "utf-8"))
        elif data == "4":
            age = input("Customer Age: ").strip()
            while(not check_age(age)):
                age = input("Customer Age: ").strip()
            sock.sendall(bytes(age + "\n", "utf-8"))
        elif data == "5":
            address = input("Customer Address: ").strip()
            while(not check_address(address)):
                address = input("Customer Address: ").strip()
            sock.sendall(bytes(address + "\n", "utf-8"))
        elif data == "6":
            phone = input("Customer Phone: ").strip()
            while(not check_phone(phone)):
                phone = input("Customer Phone: ").strip()
            sock.sendall(bytes(phone + "\n", "utf-8"))

        received = str(sock.recv(1024), "utf-8")

    print("Response: {}".format(received))
    data = input("Press Enter To Continue... ")