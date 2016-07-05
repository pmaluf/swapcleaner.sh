# swapcleaner.sh

Script to cleaner the swap area on Linux

## Notice

This script was tested in:

* Linux
  * OS Distribution: CentOS release 6.5 (Final)

## Prerequisities

* Sudo permission to execute it.
* Kernel >= 2.6.16 

## How to use it

Examples:
```
$ sudo  ./swapcleaner.sh
Swap is OK! No SWAPOFF needed.

$ sudo ./swapcleaner.sh
Memory total: 16051Mb Memory free: 545Mb Used: 96%
Swap total: 1048568 Swap free: 1016184 Used: 3%
swapoff is running, please wait...
Swap area cleaner successfully!
Memory total: 16051Mb Memory free: 520Mb Used: 96%
Swap total: 1048568 Swap free: 1048568 Used: 0%

$ sudo ./swapcleaner.sh
There's no space avaiable for swappoff.
Trying to clear RAM cache area.
Cache cleared.
Sorry, could not clear swap area.! Try again...
```

## License

This project is licensed under the MIT License - see the [License.md](License.md) file for details
