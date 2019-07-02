# shellmamu
A stupid shell helper mamu(friend) who politely ask for parameters when you forgot them.

![Screenshot]( https://github.com/benzamin/shellmamu/blob/develop/Screenshot1.png?raw=true)

##Install
Download or clone this repo, then from terminal, first go to the downloaded/cloned folder, then run
```
$ sudo sh install
```
Note that, mamu needs your admin access/password to get copied in the system folder.

##Usage
Just write any command, and mamu will ask you for needed parameters, like-
```
mamu countdown
```
And it'll ask for how many seconds it will countdown
```
::TIPS:: You can also use countdown command like - $ mamu countdown 10  
 How many seconds you want to countdown? ->  4
 ```
 And thats how it all works.
 
##Available commands
 ```
$ mamu help (Prints help for all available commands)
$ mamu countdown (counts down with voice feedback a certain amount of seconds)
$ mamu findnreplace (finds given text and replaces it with a new one in a file)
$ mamu findtext (finds given text in a file or folder and shows a list of them)
$ mamu symboliclink (make a symbolic link of a file/folder into another folder)
$ mamu httpserver (starts basic python HTTP server in a given port & directory)
$ mamu killnode (kills all running node.js instances or a given one)
$ mamu testtls (tests which TLS versions supported on a given website)
$ mamu iossimulator ( shows/open ios simulator documents directory location)
```
