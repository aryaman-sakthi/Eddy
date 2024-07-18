#!/usr/bin/env python3

# ===================================================================================================>
#                                  COMP2041: SOFTWARE CONSTRUCTION 
#                                        ASSIGNMENT 2: Eddy       
#                                       
#                                         Program: eddy.py
# About: This program implements the Eddy editing commands which are a simple subset of the tool Sed
#
#
#                                 by: Aryaman Sakthivel (z5455785)
#====================================================================================================>

import sys, os
import re

#Get arguments and number of arguments
arguments = sys.argv[1:]
num_args = len(arguments)

#Set option statuses
option_n = False
option_f = False
option_i = False
option_ipfile = False

#Check for valid arguments
if num_args == 1 and arguments[0] != '-n':
    #Get eddy command from arguments
    command = arguments[0]

#Check if -n option was specified
elif num_args == 2 and arguments[0] == '-n' and arguments[1] != arguments[0]:
    command = arguments[1]
    option_n = True

#Check if -f option was specified
elif num_args == 2 and arguments[0] == '-f' and arguments[1] != arguments[0]:
    command_file = arguments[1]
    option_f = True

#Check if -n and -f option was specified
elif num_args == 3 and arguments[0] == '-n' and arguments[1] == '-f':
    command_file = arguments[2]
    option_n = True
    option_f = True

#Check if input files were provide with -n and -f option
elif num_args > 3 and arguments[0] == '-n' and arguments[1] == '-f':
    command_file = arguments[2]
    input_files = arguments[3:]
    option_ipfile = True
    option_n = True
    option_f = True

#Check if input files were provide with -i and -f option
elif num_args > 3 and arguments[0] == '-i' and arguments[1] == '-f':
    command_file = arguments[2]
    input_files = arguments[3:]
    option_ipfile = True
    option_i = True
    option_f = True

#Check if input files were provide with -n option
elif num_args > 2 and arguments[0] == '-n':
    command = arguments[1]
    input_files = arguments[2:]
    option_ipfile = True
    option_n = True

#Check if input files were provide with -f option
elif num_args > 2 and arguments[0] == '-f':
    command_file = arguments[1]
    input_files = arguments[2:]
    option_ipfile = True
    option_f = True

#Check if input files were provide with -i option
elif num_args > 2 and arguments[0] == '-i':
    command = arguments[1]
    input_files = arguments[2:]
    option_ipfile = True
    option_i = True

#Check if input files were provide
elif num_args > 1 and arguments[0]:
    command = arguments[0]
    input_files = arguments[1:]
    option_ipfile = True

#Invalid arguments
else:
    #Print error to stderr and exit program
    print(f"usage: eddy [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]", file=sys.stderr)
    sys.exit(1)


#If commands file was used
if option_f:
    file = open(command_file,'r')
    command = file.read()
    command = command.rstrip()
    file.close()
    
#Check for multiple commands
if m:= re.search('[;\n]',command):
    command_list = re.split('[;\n]',command)
    commands = []
    #Clean up each comment
    for command in command_list:
        #Remove whitespaces and comments
        command = re.sub('\s*','',command)
        command = re.sub('#.*','',command)
        #Add command to commands list
        if len(command) == 0: continue #Continue if command is empty
        commands.append(command)
else: 
    #Store original command
    original_command = command
    #Remove whitespaces and comments
    command = re.sub('\s*','',command)
    command = re.sub('#.*','',command)
    commands = [command]

# Create eddy_stdin file to store data to be eddied
eddy_stdin = open('eddy_stdin','w')


#Check if input files were provided:
if option_ipfile:
    #Store input file contents into eddy_stdin
    for filename in input_files:
        try:
            file = open(filename,'r')
            data = file.read()
            #Write filedata into eddy_stdin
            eddy_stdin.write(data)
            #Close input file
            file.close()
        except FileNotFoundError:
            print(f"eddy: error", file=sys.stderr)

#Store stdin contents into eddy_stdin 
for line in sys.stdin:
    try:
        eddy_stdin.write(line)
    except IOError:
        break

#Close eddy_stdin (to be opened later)
eddy_stdin.close()

#Get command type 
def get_command_type(command):
    #Types: q - quit, p - print, d - delete, s - substitue, s..g - modified substitute
    if command[-1] == 'q': command_type = 'QUIT'
    elif command[-1] == 'p': command_type = 'PRINT'
    elif command[-1] == 'd': command_type = 'DELETE'
    elif s:=re.search('s',command) and command[-1] == 'g': command_type = 'MODIFIED_SUB'
    elif s:=re.search('s',command): command_type = 'SUB'
    elif s:=re.search('a',command): command_type = 'APPEND'
    elif s:=re.search('i',command): command_type = 'INSERT'
    elif s:=re.search('c',command): command_type = 'CHANGE'
    else: 
        command_type = 'INVALID'
        #Print error in stderr and exit program
        print(f"eddy: command line: invalid command",file=sys.stderr)
        sys.exit(1)

    return command_type

def get_regex(command):
    #Check if search is regex
    if c:= re.search('/.*/.',command):
        search = 'regex'
        regex = re.findall('/.*/',command)
        regex = re.sub('/','',regex[0])
        regex_list = regex.split(',')
        if len(regex_list) == 1:
            regex = regex_list[0]
        #Range of regex's given
        else:
            regex = re.sub('[\$\^]','',regex)
            regex_list = regex.split(',')
            regex = f'[{min(regex_list)}-{max(regex_list)}]'

    #Check if search is index 
    elif c:= re.search('\d+',command):
        search = 'index'
        regex = re.findall('\d+',command)
        if len(regex) == 1:
            regex = [int(regex[0])]
        #Range of indexs given
        elif len(regex) == 2:
            start = min(int(regex[0]),int(regex[1]))
            end = max(int(regex[0]),int(regex[1]))
            regex=[]
            for i in range(start,end+1): regex.append(i)

    #Check if regex is only $
    elif c:= re.search('^\$',command):
        search = 'index'
        regex = [len(stdin)]
    #Check if regex is empty 
    else:
        search = 'regex'
        regex = ''
 
    #Returns search type and regex    
    return search,regex


#Check if command type is substitute
def sub_command_args(command):
    #Get the non whitespace charecter used to delimit
    delimiter = re.findall('s\S',command)[0]
    delimiter = str(delimiter[1:])

    #If substitution is performed on specific index or regex
    regex_sub = False
    indexed_sub = False
    #Create empty sub and index regex's
    sub_regex = []
    sub_index = []

    #Check for specified index
    if c:= re.search('\ds',command):
        sub_index = re.findall('[\d,]+s',command)
        sub_index = re.sub('s','',sub_index[0])
        sub_index_list = sub_index.split(',')
        #Single index is given
        if len(sub_index_list) == 1:
            sub_index = [int(re.sub('s','',sub_index[0]))]
            indexed_sub = True
        #Range of index is given
        elif len(sub_index_list) == 2:
            start = min(int(sub_index_list[0]),int(sub_index_list[1]))
            end = max(int(sub_index_list[0]),int(sub_index_list[1]))
            sub_index=[]
            for i in range(start,end+1): sub_index.append(i)
            indexed_sub = True

    elif c:= re.search('/.*/s',command):
        #Check for specified regex
        sub_regex = re.findall(f'.*{delimiter}s',command)
        sub_regex = re.sub(f'[{delimiter}s]','',sub_regex[0])
        sub_regex_list = sub_regex.split(',')
        #Single regex
        if len(sub_regex_list) == 1:
            sub_regex = sub_regex_list[0]
            regex_sub = True
        #Range of regex given
        elif len(sub_regex_list) == 2:
            sub_regex = re.sub('[\$\^]','',sub_regex)
            sub_regex_list = sub_regex.split(',')
            sub_regex = f'[{min(sub_regex_list)}-{max(sub_regex_list)}]'
            regex_sub = True

    #print(f'regex sub= {regex_sub} index sub = {indexed_sub}')

    #Get the sub command ignoring the index
    sub_command = re.findall('s.*',command)[0]
    #Split the command to get regex and replacement
    #If delimiter is alphanumerical no escape charecter
    if delimiter.isalnum(): data = re.split(f'{delimiter}',sub_command)
    else: data = re.split(f'\{delimiter}',sub_command)
    regex = data[1] 
    replacement = data[2]

    return regex_sub, indexed_sub, sub_regex, sub_index, regex, replacement


#Get the text to be used and index
def get_text(command):
    text = re.findall('\s\w+',command)
    text = re.sub('\s','',text[0],count=1)

    search, regex = get_regex(command)

    return text, search, regex


#Quit: This command causes eddy to exit on regex match 
def eddy_quit(line,search,address,line_count):
    result = False
    #Check if search is regex
    if search == 'regex':
        if l:= re.search(address,line):
            result = True
    elif search == 'index':
        if line_count in address:
            result = True
    
    return result
            
#Print: This command prints the input line on regex match 
def eddy_print(line,search,address,line_count):
    #Check if search is regex:
    if search == 'regex':
        if l:= re.search(address,line):
            eddy_stdout.append(line)
    elif search == 'index':
        if line_count in address:
            eddy_stdout.append(line)
        
#Delete: This command deletes the input line on regex match 
def eddy_delete(line,search,address,line_count):
    result = False
    #Check if search is regex
    if search == 'regex':
        if l:= re.search(address,line):
            result = True
    elif search == 'index':
        if line_count in address:
            result = True
    
    return result

#Substiture: This command substitutes the regex with replacement 
def eddy_substitute(line,regex,replacement,modified=False):
    #Substitute only the first occurance of regex
    if modified == False:
        line = re.sub(regex,replacement,line,count=1)
    #If modifier charecter 'g' present then sub all occurances of regex
    elif modified == True:
        line = re.sub(regex,replacement,line)
    
    #Return the new line
    return line

    
#Create file to store eddy editted data
eddy_stdout = []

#Read and store input lines from eddy.stdin
eddy_stdin = open('eddy_stdin','r')
stdin = eddy_stdin.readlines()
eddy_stdin.close()


#Eddy reads from standard input
line_count = 1
stop = False
for line in stdin:
    #IF stop flag was raised then exit 
    if stop: break

    #Set delete flag to False
    delete_line = False

    #Remove extra previous new line charecter
    line = line.rstrip()

    for command in commands:
        command_type = get_command_type(command)

        #________Eddy Quit________
        if command_type == 'QUIT':
            #Get search type and regex from command
            search, regex = get_regex(command) 

            #Call eddy_quit function
            result = eddy_quit(line,search,regex,line_count)
            #Stop program if result is true
            if result: stop = True; break
                

        #________Eddy Print________
        elif command_type == 'PRINT':
            #Get search type and regex from command
            search, regex = get_regex(command) 

            #Call eddy_print function
            eddy_print(line,search,regex,line_count)

        #________Eddy Delete________
        elif command_type == 'DELETE':
            #Get search type and regex from command
            search, regex = get_regex(command) 

            #Call eddy_delete function 
            result = eddy_delete(line,search,regex,line_count)

            #If result is true then delete line
            if result: 
                #Set delete flag
                delete_line = True
                #Other commands on this line are skipped
                break
                

        #________Eddy Substitute________
        elif command_type == 'SUB' or command_type == 'MODIFIED_SUB':
            #Get substitution arguments from command
            regex_sub, indexed_sub, sub_regex, sub_index, regex, replacement = sub_command_args(command)

            #Check for type of substitution
            if command_type == 'SUB': modified = False
            elif command_type == 'MODIFIED_SUB': modified = True

            #Check for specified regex
            if regex_sub == True:
                #Search for all input lines matching regex
                if r:= re.fullmatch(sub_regex,line):
                    #Call eddy_substitute on specified regex
                    line = eddy_substitute(line,regex,replacement,modified)

            #Check for specified index
            elif indexed_sub == True:
                #Search for line matching index
                if line_count in sub_index:
                    #Call eddy_substitute on specified index
                    line = eddy_substitute(line,regex,replacement,modified)

            #If no specified index or regex then 
            else:
                #Call eddy_dubstitute on all lines
                line = eddy_substitute(line,regex,replacement,modified)

        #________Eddy Append________
        elif command_type == 'APPEND':
            #Get text and index from command
            text,search, index = get_text(original_command)

            if search == 'index':
                #Append the text to the stdout
                if line_count == int(index[0])+1:
                    eddy_stdout.append(text)
            else:
                if s:= re.search(index,line):
                    eddy_stdout.append(line)
                    eddy_stdout.append(text)
                    delete_line = True

        #________Eddy Insert_______
        elif command_type == 'INSERT':
            #Get text and index from command
            text,search, index = get_text(original_command)

            #Insert the text to the stdout
            if search == 'index':
                #Append the text to the stdout
                if line_count in index:
                    eddy_stdout.append(text)
            else:
                if s:= re.search(index,line):
                    eddy_stdout.append(text)

        #________Eddy Change______
        elif command_type == 'CHANGE':
            #Get text and index from command
            text,search, index = get_text(original_command)

            #Change the text in the stdout
            if search == 'index':
                #Change the text in the stdout
                if line_count in index:
                    eddy_stdout.append(text)
                    delete_line = True
            else:
                if s:= re.search(index,line):
                    eddy_stdout.append(text) 
                    delete_line = True 
                

    #Add editted line to eddy_stdout list
    if not option_n: eddy_stdout.append(line)

    #Delete line if delete flag raised
    if delete_line: 
        try:
            eddy_stdout.pop()
        except IndexError:
            pass

    line_count += 1

#If option -i was selected
if option_i:
    file = open(input_files[0],'w')

    #Add the stdout list contents to the file
    for line in eddy_stdout:
        print(line.rstrip(),file=file)
    
    file.close()

else:
    #Print out the stdout list contents 
    for line in eddy_stdout:
        print(line.rstrip())

#Remove the eddy_stdin temporary file
os.remove('eddy_stdin')