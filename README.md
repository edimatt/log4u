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
- LOG4U.LEVEL=DEBUG|INFO|WARN|ERR|FAIL
- LOG4U.LOGCOLORS
- LOG4U.LOGFILE=filename,[d|a]

3. If you have a config file, initialize it:
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
