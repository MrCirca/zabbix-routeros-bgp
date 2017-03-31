#!/usr/bin/python3

import sys, posix, time, hashlib, binascii, socket, select, re

class ApiRos:
    "Routeros api"
    def __init__(self, sk):
        self.sk = sk
        self.currenttag = 0
        
    def login(self, username, pwd):
        for repl, attrs in self.talk(["/login"]):
            chal = binascii.unhexlify(attrs['=ret'])
        md = hashlib.md5()
        md.update(b'\x00')
        md.update(bytes(pwd, 'utf-8'))
        md.update(chal)
        self.talk(["/login", "=name=" + username,
                   "=response=00" + binascii.hexlify(md.digest()).decode('utf-8')])

    def talk(self, words):
        if self.writeSentence(words) == 0: return
        r = []
        while 1:
            i = self.readSentence();
            if len(i) == 0: continue
            reply = i[0]
            attrs = {}
            for w in i[1:]:
                j = w.find('=', 1)
                if (j == -1):
                    attrs[w] = ''
                else:
                    attrs[w[:j]] = w[j+1:]
            r.append((reply, attrs))
            if reply == '!done': return r

    def writeSentence(self, words):
        ret = 0
        for w in words:
            self.writeWord(w)
            ret += 1
        self.writeWord('')
        return ret

    def readSentence(self):
        r = []
        while 1:
            w = self.readWord()
            if w == '': return r
            r.append(w)
            
    def writeWord(self, w):
        #print(w)
        b = bytes(w, "utf-8")
        self.writeLen(len(b))
        self.writeBytes(b)

    def readWord(self):
        ret = self.readBytes(self.readLen()).decode('utf-8')
        if ret != '!done' and not re.match("^=ret=\S*[a-z]\S*", ret) and ret != '!re':
            print("%s" % ret)
        return ret

    def writeLen(self, l):
        if l < 0x80:
            self.writeBytes(bytes([l]))
        elif l < 0x4000:
            l |= 0x8000
            self.writeBytes(bytes([(l >> 8) & 0xff, l & 0xff]))
        elif l < 0x200000:
            l |= 0xC00000
            self.writeBytes(bytes([(l >> 16) & 0xff, (l >> 8) & 0xff, l & 0xff]))
        elif l < 0x10000000:        
            l |= 0xE0000000         
            self.writeBytes(bytes([(l >> 24) & 0xff, (l >> 16) & 0xff, (l >> 8) & 0xff, l & 0xff]))
        else:                       
            self.writeBytes(bytes([0xf0, (l >> 24) & 0xff, (l >> 16) & 0xff, (l >> 8) & 0xff, l & 0xff]))

    def readLen(self):
        c = self.readBytes(1)[0]
        if (c & 0x80) == 0x00:      
            pass                    
        elif (c & 0xC0) == 0x80:    
            c &= ~0xC0              
            c <<= 8                 
            c += self.readBytes(1)[0]
        elif (c & 0xE0) == 0xC0:    
            c &= ~0xE0              
            c <<= 8                 
            c += self.readBytes(1)[0]
            c <<= 8                 
            c += self.readBytes(1)[0]
        elif (c & 0xF0) == 0xE0:    
            c &= ~0xF0              
            c <<= 8                 
            c += self.readBytes(1)[0]
            c <<= 8                 
            c += self.readBytes(1)[0]
            c <<= 8                 
            c += self.readBytes(1)[0]
        elif (c & 0xF8) == 0xF0:    
            c = self.readBytes(1)[0]
            c <<= 8                 
            c += self.readBytes(1)[0]
            c <<= 8                 
            c += self.readBytes(1)[0]
            c <<= 8                 
            c += self.readBytes(1)[0]
        return c                    

    def writeBytes(self, str):        
        n = 0;                      
        while n < len(str):         
            r = self.sk.send(str[n:])
            if r == 0: raise RuntimeError("connection closed by remote end")
            n += r                  

    def readBytes(self, length):      
        ret = b''                    
        while len(ret) < length:    
            s = self.sk.recv(length - len(ret))
            if len(s) == 0: raise RuntimeError("connection closed by remote end")
            ret += s
        return ret

def main():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((sys.argv[1], 8728))  
    apiros = ApiRos(s);             
    apiros.login(sys.argv[2], sys.argv[3]);

    inputsentence = [line[:-1] for line in sys.stdin.readlines()]
    apiros.writeSentence(inputsentence)
    r = select.select([s], [], [], None)
    if s in r[0]: 
        while 1: 
            x = apiros.readSentence()
            if '!done' in x:
                break
    #if s in r[0]:
            # something to read in socket, read sentence
    #        x = apiros.readSentence()

    #if sys.stdin in r[0]:
            # read line from input and strip off newline
    #        l = sys.stdin.readline()
    #        l = l[:-1]
            # if empty line, send sentence and start with new
            # otherwise append to input sentence
    #        if l == '':
    #            apiros.writeSentence(inputsentence)
    #            inputsentence = []
    #        else:
    #            inputsentence.append(l)

if __name__ == '__main__':
    main()

