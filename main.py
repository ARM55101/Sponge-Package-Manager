#bin/bash/python3
import socket
import hashlib
input = input('')
hashmap = []
def push(package):
    push.package = package
    package_hash = hashlib.sha256(package.encode("utf-8")).hexdigest()
    hashmap.append(package_hash)
def pull(position):
    pull.position = position
    print(hashmap[pull.position])
    return 0
if input == '':
    input = "rbenv/ruby-build/"
push(input)
GET = 'GET' + ' ' + input + ' ' + 'HTTP/1.1\r\n'
print(GET)
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect(("140.82.121.3", 8080))
    s.sendall(bytes(GET, 'utf-8'))
    return_hash = s.recv(1024)
    print(return_hash)
