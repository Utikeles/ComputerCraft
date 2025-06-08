This "telnet" program is used to remotely control computers and turtles, forcibly. 

The telnetHost.lua program is to be placed within the target computer/turtle. This program will remove the user's ability to terminate the program, and if the API call "shell.run("telnetHost.lua")" is placed in startup.lua, then the target computer will be effectively bricked, unless the "release" command is sent to said target from the client. 

the telnetHost.lua program runs any command given to it by the client, and has built in arbitrary remote lua code execution capabilities. With these, one can effectively take complete control of a computer remotely, as long as it has a modem. 

Please use this program responsibly, as this program is not intended to cause harm.

(JUICE brand is built into the program, but is trivial to remove with basic lua knowledge.)

the telnetClient.lua program is to be ran by the controller of all targets, and is the point at which one should send commands from. Any string entered will be ran directly in the shell of the computer the client is connected too, unless it begins with "release" or "lua". If the command is "release" the computer(s) connected to will be release from the connection, and the telnetHost.lua program will be terminated. If the "lua" commend prepends a command string, then the strings after "lua" will be executed, in lua, on the computer that the client is connected to.

Have fun!