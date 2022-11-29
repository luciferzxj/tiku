from web3 import Web3

s1 = '0xffD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B'

s3 = '0b78d35a41822a355f7add7babe8dfa9bd8caf25834aa99826342933f199eb7b'

i = 0
while(1):
    salt = hex(i)[2:].rjust(64, '0')
    s = s1+salt+s3
    hashed = Web3.sha3(hexstr=s)
    hashed_str = ''.join(['%02x' % b for b in hashed])
    if '5b' in hashed_str[24:26]:
        print(salt,hashed_str)
        break
    i += 1
    print(salt)







