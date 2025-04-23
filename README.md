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

```
minifiling init
```

### Import File

```sh
minifiling import http://.../file.pdf       # Online file
minifiling import /path/to/local/file.pdf   # Local file
```

### Find File by Hash

```sh
minifiling find f7579c9b451c1054fc5bb48435841bb639fac763
```

### Export Static Website

```sh
minifiling www
```






## Filesystem Structure

- `/files/`
- `/files/id/2025/1745384870592/`
- `/files/hash/f7/f7579c9b451c1054fc5bb48435841bb639fac763/`
- `/files/{ id... | hash... }/index.html` Human readable metadata
- `/files/{ id... | hash... }/file_f7579c9b451c1054fc5bb48435841bb639fac763.pdf` EOC PDF
- `/files/{ id... | hash... }/raw/RAWFN.pdf` Original file






## Copyright

Copyright (c) 2025 Neruthes.

Released with the GNU GPL 2.0 license.
