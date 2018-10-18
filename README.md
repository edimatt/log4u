# LOG4U
Logging library for Unix. The purpose of this library is to provide a simple
interface for logging in your unix scripts.

Functionalities:
1. logging levels
2. message colors
3. console and file writer (append and replace)

## Installation
All you need is the log4u module. Optionally, write your own configuration file
## Usage
1. Source the log4u module:
```
    . ./log4u
```

2. Write a configuration file (optional). Supported properties are
- LOG4U.CONSOLE
- LOG4U.CONSOLE.LEVEL=DEBUG|INFO|WARN|ERROR|FAIL
- LOG4U.LOGCOLORS
- LOG4U.LOGFILE=filename,[d|a]
- LOG4U.LOGFILE.LEVEL=DEBUG|INFO|WARN|ERROR|FAIL

LOG4U.CONSOLE, if present, enables the messages to go to the console. The
LOG4U.CONSOLE.LEVEL specifies the corresponding level (default INFO). 

LOG4U.LOGFILE specifies the log file name and mode with an optional flag ('d'
for delete and 'a' for append. If this property is specified, the 
associated LOG4U.LOGFILE.LEVEL sets the corresponding level.
Levels can be different for file and console.

The property LOG4U.LOGCOLORS enables colors.

3. In case you have a config file, initialize the logging library:
```
    logInit logging.conf
```
4. Use the logging functions logDebug, logInfo, logWarn, logErr, logFail

![Log for Unix](img/log4u.PNG)

Colors are also supported, by enabling the corresponding property in the
configuration file.

![Log for Unix](img/log4u_colors.PNG)

## Contributing
You are welcome to extend/improve the library.
