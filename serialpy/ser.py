from time import sleep
import serial

p = "A2FF9AA9008D0360A9FF8D0260207503A928208503A90C208503A906208503A901208503A200BD3503F00720AB03E84C26034C320348656C6C6F2C20576F726C64210048A9F08D0260A9208D0060A9608D0060AD006048A9208D0060A9608D0060AD0060682908D0E0A9208D0060A9FF8D02606860A9028D006009408D0060290F8D006060204303484A4A4A4A8D006009408D006049408D006068290F8D006009408D006049408D006060204303484A4A4A4A09108D006009408D006049408D006068290F09108D006009408D006049408D006060"

ser = serial.Serial(port="COM4", baudrate=19200, timeout=1)
ser.close()
ser.open()

for y in range(0x0300, 0x0300 + len(p), 40):
    for i in f"{y:04x}:":
        ser.write(bytes(i, "utf-8"))
        print(i, end="")
        sleep(0.1)
    for x in range(y - 0x300, y - 0x300 + 80):
        if (x % 2) == 0:
            ser.write(bytes(" ", "utf-8"))
            print(" ", end="")
        try:
            ser.write(bytes(p[x], "utf-8"))
            print(p[x], end="")
        except IndexError:
            break
        sleep(0.1)
    ser.write(bytes("\r", "utf-8"))
    sleep(0.5)
    print()

#while True:
#    print(ser.read(size=1))
    