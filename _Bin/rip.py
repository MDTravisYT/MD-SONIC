import sys

with open(sys.argv[1],'rb') as f, open(sys.argv[2], 'wb') as out:
    while True:
        data = f.read(0x8000)
        if not data:
            break
        out.write(data)
        f.seek(0x1D800, 1)
