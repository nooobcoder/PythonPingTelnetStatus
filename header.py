# import call method from subprocess module
from subprocess import call
import os


def clear():
    # check and make call for specific operating system
    # !WARN: Below line of code is deprecated due to incompatibility with Windows
    # _ = call('clear' if os.name == 'posix' else 'cls')
    os.system('cls' if os.name == 'nt' else 'clear')


def printHeader():
    print """
    Welcome to,

    /$$$$$$$             /$$     /$$                                 /$$$$$$$  /$$                    
    | $$__  $$           | $$    | $$                                | $$__  $$|__/                    
    | $$  \ $$/$$   /$$ /$$$$$$  | $$$$$$$   /$$$$$$  /$$$$$$$       | $$  \ $$ /$$ /$$$$$$$   /$$$$$$ 
    | $$$$$$$/ $$  | $$|_  $$_/  | $$__  $$ /$$__  $$| $$__  $$      | $$$$$$$/| $$| $$__  $$ /$$__  $$
    | $$____/| $$  | $$  | $$    | $$  \ $$| $$  \ $$| $$  \ $$      | $$____/ | $$| $$  \ $$| $$  \ $$
    | $$     | $$  | $$  | $$ /$$| $$  | $$| $$  | $$| $$  | $$      | $$      | $$| $$  | $$| $$  | $$
    | $$     |  $$$$$$$  |  $$$$/| $$  | $$|  $$$$$$/| $$  | $$      | $$      | $$| $$  | $$|  $$$$$$$
    |__/      \____  $$   \___/  |__/  |__/ \______/ |__/  |__/      |__/      |__/|__/  |__/ \____  $$
              /$$  | $$                                                                       /$$  \ $$
            |  $$$$$$/                                                                      |  $$$$$$/
              \______/                                                                        \______/ 

    by © Ankur Paul (https://github.com/nooobcoder/PythonPingTelnetStatus)

    [PLEASE SPONSOR THIS PROJECT HERE]

    You are not allowed to redistribute, duplicate, modify this source code without the author's permission. Will be seriously dealt with if not acknowledged.

    Thank You!
    """


clear()
printHeader()
