# DXSummitSpider

This script imports [DXsummit.fi](https://dxsummit.fi) spots to DXSpider cluster node.
New spots are added every minute.

## Prerequisites 

* DXSpider node
* extra perl modules: `LWP::Protocol::https LWP::UserAgent JSON`
```
cpanm LWP::Protocol::https LWP::UserAgent JSON
```

## Installation 

Copy script to `spider/local_cmd`

Add crontab entry in `spider/local_cmd/crontab`:
```
* * * * * run_cmd('summit')
```

This will produce output like this: 
```
DX de SP6XD-@:   14265.0  SP6PWS       cq 
```

## Security

Script is limited to sysops and crontab only. Users will not be able to execute it. 

## Routing and filtering

DXSummit spots are sent to local node users only. 
Connected nodes won't receive those spots. 
As for now there is no option to filter out this spots by a user. 

## Usage options

Additional command options may be used: 
* `noat` - revmoves `-@` from spotter's callsign
* `addcomment` - adds comment *[DXSummit]* to the spot info field

Examples:
* **noat**
Usage:
```
* * * * * run_cmd('summit noat')
```
Output:
```
DX de SP6XD:     14265.0  SP6PWS       cq 
```
* **addcomment**
Usage:
```
* * * * * run_cmd('summit addcomment')
```
Output:
```
DX de SP6XD-@:   14265.0  SP6PWS       cq [DXSummit]
```
* **noat** and **addcomment**
Usage:
```
* * * * * run_cmd('summit noat addcomment')
```
Output:
```
DX de SP6XD:    14265.0  SP6PWS       cq [DXSummit]
```

## Notes 
Thanks to Ken G7VJA for suggestions and consultancy on this script. 

If you want to check how this script works, try our club cluster: `telnet dxcluster.sp6pws.pl 7300`.
