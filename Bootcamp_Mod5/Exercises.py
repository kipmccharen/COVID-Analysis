from datetime import datetime
import os
import re

def wait_key(result='time'):
    os.system("pause")
    if result == 'time':
        return datetime.now()
    else:
        return result

class BootCampExercises:
    def __init__(self):
        self.created = datetime.now()
        print("Let's do Boot Camp Exercises! your options are: ", [x for x in dir(self) if x[:2] != '__'])
    
    def whattimeisit(self):
        current_time = datetime.now()
        print("Current Time =", current_time.strftime("%H:%M:%S"))
        #print("I've been here for {} seconds".format(current_time-self.created))

    def stopwatch(self): 
        current_time = datetime.now()
        print('STOPWATCH active')
        print("{} seconds elapsed".format(wait_key() - current_time))

    def printthis(self):
        printme = input("What words you want me to print? (no numbers or special characters)   ->    ")
        print(wait_key('OK got it\n\n\n'))
        if re.match(r'([0-9\@\#\$\%\^\&\*.])', printme):
            print('\n\n\nCan you read? NO NUMBERS OR SPECIAL CHARACTERS. Try again....\n\n\n')
            self.printthis()
        else:
            print(printme)
        
if __name__ == '__main__':    
    bce = BootCampExercises()
    bce.whattimeisit()
    bce.stopwatch()
    bce.printthis()
    print(bce.created)