with open('input.bin', 'rb') as f, open('CHANNEL1.PCM', 'wb') as c1, open('CHANNEL2.PCM', 'wb') as c2:
    while True:
        data1 = f.read(0x4000)
        if not data1:
            break
        c1.write(data1)
        data2 = f.read(0x4000)
        if not data2:
            break
        c2.write(data2)
