<div class="Image" align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Bash_Logo_Colored.svg/512px-Bash_Logo_Colored.svg.png?20180723054350" alt="Logo" width="130" height="120">
</div>
<h1 align="center">EDDY</h1>

## About:
**Eddy** editing commands are a subset of the important tool [Sed](https://en.wikipedia.org/wiki/Sed) which is a Unix utility that parses and transforms text, using a simple, compact programming language. This project aims to provide a concrete understanding of Sed's core semantics. While Sed is a very complex program that has many commands, Eddy contains only a few of the most importatnt Sed commands.

## Features:
* **eddy-quit (q):** Exits the program if the regex matches a line.
* **eddy-print (p):** Prints the input line if it matches the regex.
* **eddy-delete (d):** Deletes the input line if it matches the regex.
* **eddy-substitute (s):** Substitutes the first occurrence of the regex in the line with the replacement text. If the **g** modifier is present, substitutes all occurrences.
* **eddy-append (a):** Appends text after a line if it matches the regex or index.
* **eddy-insert (i):** Inserts text before a line if it matches the regex or index.
* **eddy-change (c):** Replaces the line with the text if it matches the regex or index.

## Installation:

1. Clone the repository:
   ```sh
   git clone https://github.com/aryaman-sakthi/Eddy.git

2. Ensure your system has /usr/bin/env python3 installed. If not, you can install it using your package manager.  

3. Make the scripts executable:
   ```sh
   chmod -R 777 .

## Built With:
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54) 
![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white) 
![Bash](https://img.shields.io/badge/Bash-4EAA25?logo=gnubash&logoColor=fff&style=for-the-badge)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

## Conclusion:
The Eddy project successfully implements a streamlined version of the sed tool, focusing on a core subset of editing commands. By developing eddy, we aimed to provide a simplified yet powerful text manipulation utility for a variety of use cases, including text editing, transformation, and formatting.
