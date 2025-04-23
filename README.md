# MiniFiling

Tool for collecting files into archive.


## Key Ideas

- Files are collected into a timeline.
- Use a directory as archive timeline namespace.
- Importing a file will generate an evidence of collection (EOC) for its hash.
- Generate EOC PDF...?
- Easy lookup by hash, especially over HTTP.



## Installation

```
./make.sh install
```


## Usage

### Initialize Archive

Just pick a directory. No explicit init is needed.

### Import File

```sh
minifiling.sh import http://.../file.pdf       # Online file
minifiling.sh import /path/to/local/file.pdf   # Local file
```

### Find File by Hash (TODO)

```sh
minifiling.sh find f7579c9b451c1054fc5bb48435841bb639fac763
```




## Filesystem Structure

- `/files/`
- `/files/id/2025/1745384870592/`
- `/files/hash/f7/f7579c9b451c1054fc5bb48435841bb639fac763/`
- `/files/{ id... | hash... }/index.html` Human readable metadata
- `/files/{ hash... }/file_f7579c9b451c1054fc5bb48435841bb639fac763.pdf` Certificate of Digital File Identification PDF
- `/files/{ hash... }/raw/RAWFN.pdf` Original file




## Supported ENV

| Env                     | Description                                      |
| ----------------------- | ------------------------------------------------ |
| ENABLE_XELATEX_EVIDENCE | Set empty or false to disable. Others mean true. |
| SITE_PREFIX             | Supply a string for PDF links.                   |




## Copyright

Copyright (c) 2025 Neruthes.

Released with the GNU GPL 2.0 license.
