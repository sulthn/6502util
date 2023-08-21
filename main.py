from ctypes import windll
import tkinter as tk
from tkinter import ttk, filedialog as fd
import subprocess
import os

windll.shcore.SetProcessDpiAwareness(1)
root = tk.Tk()
root.title('Compile 65c02 asm')
root.resizable(False, True)
#root.geometry('300x220')
root.geometry("400x300+100+100")

file_path = ""


def select_file():
    filetypes = (
        ('Assembly Files', '*.s'),
        ('All Files', '*.*')
    )

    filename = fd.askopenfilename(title='Open a file', initialdir='C:\\Users\\ASUS\\Desktop\\6502', filetypes=filetypes)
    global file_path
    file_path = os.path.abspath(filename)
    file.config(text=file_path)


def compile_asm():
    cmd = ['C:\\Users\\ASUS\\Desktop\\sulthansprojects\\6502\\vasm6502_oldstyle.exe', '-Fbin', '-wdc02', '-dotdir', '-o', f"{file_path}.bin", f"{file_path}"]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    proc.wait()

    if proc.returncode != 0:
        e = proc.stderr.read().decode()
        errmsg = e[2:e.index("\r\n",3)]
        status.config(text=errmsg)
    else:
        a = proc.stdout.read().decode()
        a = a[260:len(a)].replace("\n", "").replace("\t", "")
        status.config(text=f"Compiled file{a}")

file = ttk.Label(root, text="", justify='center', wraplength=350, font=("Segoe UI", 7))
file.pack()
open_file = ttk.Button(root, text='Open 65c02 file', command=select_file)
open_file.pack(ipadx=10, ipady=10, fill='x')
compile_file = ttk.Button(root, text='Compile file', command=compile_asm)
compile_file.pack(ipadx=10, ipady=10, fill='x')
status = ttk.Label(root, justify='center', wraplength=350)
status.pack(ipady=5)
root.mainloop()
