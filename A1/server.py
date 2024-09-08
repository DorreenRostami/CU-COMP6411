import socketserver

class MyTCPHandler(socketserver.BaseRequestHandler):
    def handle(self):
        # self.request is the TCP socket connected to the client
        self.data = self.request.recv(1024).strip().decode()
        # print("Received from {}: {}".format(self.client_address[0], self.data))

        req = int(self.data)

        if req >= 1 and req <= 6:
            name = self.request.recv(1024).strip().decode().lower()
            if req == 1:
                for cust in records:
                    if cust.name == name:
                        self.request.sendall(str(cust).encode())
                        return
                self.request.sendall('{} not found'.format(name).encode())
            if req == 2:
                age = self.request.recv(1024).strip().decode()
                adr = self.request.recv(1024).strip().decode()
                phone = self.request.recv(1024).strip().decode()
                for cust in records:
                    if cust.name == name:
                        self.request.sendall('Customer named {} already exists'.format(name).encode())
                        return
                newEntry = Entry(name, age, adr, phone)
                records.append(newEntry)
                self.request.sendall('Customer {} added'.format(newEntry).encode())
            if req == 3:
                for i in range(len(records)):
                    if records[i].name == name:
                        self.request.sendall('{} deleted'.format(records[i]).encode())
                        del records[i]
                        return
                self.request.sendall('{} not found'.format(name).encode())
            if req >= 4:
                toUpdate = self.request.recv(1024).strip().decode()
                idx = -1
                for i in range(len(records)):
                    if records[i].name == name:
                        idx = i
                        break
                if idx == -1:
                    self.request.sendall('Customer named {} does not exist'.format(name).encode())
                    return
                if req == 4:
                    records[i].age = toUpdate
                    self.request.sendall('{}\'s age updated to {}'.format(name, toUpdate).encode())
                elif req == 5:
                    records[i].address = toUpdate
                    self.request.sendall('{}\'s address updated to {}'.format(name, toUpdate).encode())
                else:
                    records[i].phone = toUpdate
                    self.request.sendall('{}\'s phone updated to {}'.format(name, toUpdate).encode())
                
        elif req == 7:
            sorted_list = sorted(records, key=lambda x: x.name, reverse=False)
            self.request.sendall('\n'.join([repr(record) for record in sorted_list]).encode())
        

class Entry:
    def __init__(self, name, age, address, phone):
        self.name = name
        self.age = age
        self.address = address
        self.phone = phone

    def __repr__(self):
        return "%s|%s|%s|%s" % (self.name, self.age, self.address, self.phone) 

def read_data():
    f = open("data.txt", "r")
    valid_records = []
    for line in f:
        fields = line.split(",")
        fields = [x.strip() for x in fields]
        if len(fields) != 4:
            print('Record skipped [missing field(s)] {}'.format(line))
            continue 
        if fields[0] == "":
            print('Record skipped [missing name] {}'.format(line))
            continue
        if not fields[0].isalpha():
            print('Record skipped [invalid name field] {}'.format(line))
            continue
        if fields[1] != "" and not(fields[1].isnumeric() and int(fields[1]) <= 120 and int(fields[1]) >= 1):
            print('Record skipped [invalid age field] {}'.format(line))
            continue
        if fields[2] != "" and not fields[2].replace(' ', '').replace('.', '').replace('-', '').isalnum():
            print('Record skipped [invalid address field] {}'.format(line))
            continue
        if fields[3] != "" :
            if not(len(fields[3]) == 8 or len(fields[3]) == 12) or fields[3][-5] != '-':
                print('Record skipped [invalid phone field] {}'.format(line))
                continue
            if len(fields[3]) == 12 and fields[3][3] != " ":
                print('Record skipped [invalid phone field] {}'.format(line))
                continue
            if len(fields[3])==8 and not(fields[3][:3]+fields[3][4:]).isnumeric():
                print('Record skipped [invalid phone field] {}'.format(line))
                continue
            if len(fields[3])==12 and not(fields[3][:3]+fields[3][4:7]+fields[3][8:]).isnumeric():
                print('Record skipped [invalid phone field] {}'.format(line))
                continue
        valid_records.append(Entry(fields[0], fields[1], fields[2], fields[3]))
        x = Entry(fields[0], fields[1], fields[2], fields[3])
        x.name
    return valid_records
            

records = read_data()
# print(records)

print("python DB server is now running")
HOST, PORT = "localhost", 9999

# Create the server, binding to localhost on port 9999
with socketserver.TCPServer((HOST, PORT), MyTCPHandler) as server:
    server.serve_forever()