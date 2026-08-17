import sys

QtyBox = float(sys.argv[1])
SizeBox = float(sys.argv[2])
GapBox = float(sys.argv[3])

def calculationCenter(QtyBox, SizeBox, GapBox):
    return ((QtyBox*SizeBox + (QtyBox-1)*GapBox) / 2)

print(calculationCenter(QtyBox, SizeBox, GapBox))