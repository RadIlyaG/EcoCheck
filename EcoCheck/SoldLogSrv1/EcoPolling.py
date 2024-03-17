import os
import ctypes
import glob
# import tkinter as tk
# import tkinter.messagebox


class Polling:
    def __init__(self):
        self.ecoFilePath = '//prod-svm1/tds/Temp/SQLiteDB/EcoNoiNpi'

    def ReadEcoFiles(self):
        if not os.path.exists(self.ecoFilePath):
            ctypes.windll.user32.MessageBoxW(0, "The 'self.ecoFilePath' doesn't exist", "No path ", 0x00 | 0x40 | 0x0)
            return False
        else:
            ecoFiles0 = os.listdir(self.ecoFilePath)
            ecoFiles = glob.glob(self.ecoFilePath + "/[CN]*")

            if ecoFiles:
                for self.ecoFile in ecoFiles:
                    self.ReadEcoFile()

                print(ecoFiles0)
                print(ecoFiles)

            return ecoFiles

    def ReadEcoFile(self):
        print(f"ReadEcoFileeco file:{self.ecoFile}")
        with open(self.ecoFile) as f:
            lines = f.readlines()
            for line in lines:
                print(line)

if __name__ == '__main__':
    print(f'gg')
    poll = Polling()
    ret = poll.ReadEcoFiles()
    #print(f"{ret}")
