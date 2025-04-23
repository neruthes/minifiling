#!/bin/bash

function _dev_ci_hook() {
    find data -mindepth 1 -maxdepth 1 -type d | while read -r sitedir; do
        [[ -d "$sitedir/files/hash" ]] && cp -a assets/item_metadata.html "$sitedir"/.item_metadata.html.txt
    done
}


case "$1" in
    install | i )
        mkdir -p .tmp
        sed "s|3f267dd07ddf482cba39e0c298d8bd44|$PWD|g" src/minifiling.sh > .tmp/minifiling.sh
        install -m755  .tmp/minifiling.sh  "$HOME/.local/bin/minifiling.sh"
        _dev_ci_hook
        ;;

    _test | _test/ )
        ### Simple test case
        cd data/minifiling.neruthes.xyz &&
        rm -r .tmp files/{id,hash}
        export ENABLE_XELATEX_EVIDENCE=true
        minifiling.sh import /home/neruthes/DEV/ntexdb/_dist/office/poster-eye-exam.pdf
        ;;
esac
