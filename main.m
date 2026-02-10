#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <unistd.h>

NSMutableArray<NSString *> *hashmap;

NSString *sha3String(NSString *input) {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];

    uint8_t hash[CC_SHA3_256_DIGEST_LENGTH];
    CC_SHA3_256(data.bytes, (CC_LONG)data.length, hash);

    NSMutableString *hex = [NSMutableString string];
    for (int i = 0; i < CC_SHA3_256_DIGEST_LENGTH; i++) {
        [hex appendFormat:@"%02x", hash[i]];
    }
    return hex;
}

void push(NSString *package) {
    NSString *packageHash = sha3String(package);
    [hashmap addObject:packageHash];
}

int pull(NSUInteger position) {
    if (position < hashmap.count) {
        NSLog(@"%@", hashmap[position]);
    }
    return 0;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        hashmap = [NSMutableArray array];

        // Read stdin
        char buffer[1024];
        fgets(buffer, sizeof(buffer), stdin);
        NSString *input =
            [[NSString stringWithUTF8String:buffer]
                stringByTrimmingCharactersInSet:
                [NSCharacterSet newlineCharacterSet]];

        if (input.length == 0) {
            input = @"rbenv/ruby-build/";
        }

        push(input);

        NSString *GET =
            [NSString stringWithFormat:@"GET %@ HTTP/1.1\r\n", input];
        NSLog(@"%@", GET);

        // Socket
        int sock = socket(AF_INET, SOCK_STREAM, 0);
        if (sock < 0) return 1;

        struct sockaddr_in addr;
        addr.sin_family = AF_INET;
        addr.sin_port = htons(8080);
        inet_pton(AF_INET, "140.82.121.3", &addr.sin_addr);

        if (connect(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
            close(sock);
            return 1;
        }

        send(sock, GET.UTF8String, strlen(GET.UTF8String), 0);

        char recvBuf[1024];
        ssize_t received = recv(sock, recvBuf, sizeof(recvBuf), 0);
        if (received > 0) {
            NSData *data = [NSData dataWithBytes:recvBuf length:received];
            NSLog(@"%@", data);
        }

        close(sock);

        // os.system equivalents
        NSString *cdCmd = [NSString stringWithFormat:@"cd %@", input];
        system(cdCmd.UTF8String);
        system("make");
    }
    return 0;
}
