#!/bin/bash


# This program is a free software released with the GNU GPL 2.0 license.
# Source code: https://github.com/neruthes/minifiling


### Real env
# ENABLE_XELATEX_EVIDENCE


### Flags inferred from env
[[ -n "$ENABLE_XELATEX_EVIDENCE" ]] && enabled_evidence_pdf=true


### Installer should replace values for these
SRC_REPO_PATH="3f267dd07ddf482cba39e0c298d8bd44"


### Automatically set some quais-env constants
WSPATH="$PWD"
YEAR="$(TZ=UTC date +%Y)"
TIMESTAMP="$(TZ=UTC date +%s)"
TIME_ISO="$(TZ=UTC date -Is | cut -c1-19)Z"


### Default values for some stuff to be replaced by instance owners
SITE_PREFIX="http://example.com"
ASSETS_DIR="$SRC_REPO_PATH/assets"
ITEM_METADATA_HTML_PATH="$ASSETS_DIR/item_metadata.html"
ASSET_EVIDENCE_TEX_PATH="$ASSETS_DIR/evidence.tex"
ASSET_EVIDENCE_TEXDEPS_PATH="$ASSETS_DIR/evidence.tex.d"
[[ -e .env ]] && source .env



### Global variables to be filled by some subcommands
SESSION_ID=""
SESSION_DIR="" # is realpath
IMPORTED_HASH=""
IMPORTED_BASENAME=""





function die() {
    echo "$2" > /dev/stderr
    exit "$1"
}

function create_import_session() {
    SESSION_ID="$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM"
    SESSION_DIR="$PWD/.tmp/import_session/$SESSION_ID"
    mkdir -p "$SESSION_DIR"
}

function destroy_import_session() {
    [[ -d "$SESSION_DIR" ]] && echo "[INFO] Remember to clear session:  " rm -r "$SESSION_DIR"
}


function try_import_file() {
    target_path="$1"
    create_import_session
    if [[ "$target_path" == "http"* ]]; then
        try_import_file_remote "$target_path"
    else
        try_import_file_local "$target_path"
    fi
}

function try_import_file_remote() {
    target_path="$1"
    IMPORTED_BASENAME="$(basename "$target_path")"
    cd "$SESSION_DIR"
    mkdir -p raw
    cd raw
    if ! wget "$target_path" -O "$IMPORTED_BASENAME"; then
        destroy_import_session
        die 2 "[ERROR] Cannot get file"
    fi
    IMPORTED_HASH="$(sha1sum "$IMPORTED_BASENAME" | cut -d' ' -f1)"
    cd "$SESSION_DIR"
    cd "$WSPATH"
    finish_importing
}
function try_import_file_local() {
    target_path="$1"
    if [[ ! -e "$target_path" ]] || [[ -d "$target_path" ]]; then
        destroy_import_session
        die 1 "[ERROR] Cannot get file:  $target_path "
    fi
    IMPORTED_BASENAME="$(basename "$target_path")"
    cd "$SESSION_DIR"
    mkdir -p raw
    cd raw
    cp -a "$target_path" "./$IMPORTED_BASENAME"
    IMPORTED_HASH="$(sha1sum "$IMPORTED_BASENAME" | cut -d' ' -f1)"
    cd "$SESSION_DIR"
    cd "$WSPATH"
    finish_importing
}
function finish_importing() {
    ### Try hash collision
    if [[ -d "$WSPATH/files/hash/${IMPORTED_HASH:0:2}/$IMPORTED_HASH" ]]; then
        destroy_import_session
        die 1 "[WARN] Hash collision!"
    fi
    ### Generate companion stuff
    cp -a "$ITEM_METADATA_HTML_PATH" ".item_metadata.html.txt"
    ln -svf "$PWD/.item_metadata.html.txt" "$SESSION_DIR/index.html"
    printf '{
        "hash": "%s",
        "basename": "%s",
        "timestamp": "%s",
        "timeiso": "%s",
        "enabled_evidence_pdf": "%s"
    }' "$IMPORTED_HASH" "$IMPORTED_BASENAME" "$TIMESTAMP" "$TIME_ISO" "$enabled_evidence_pdf" > "$SESSION_DIR/metadata.json"
    ### Put into '/files' dir
    cd "$WSPATH"
    dir1="$WSPATH/files/id/$YEAR/$TIMESTAMP"
    dir2="$WSPATH/files/hash/${IMPORTED_HASH:0:2}/$IMPORTED_HASH"
    echo "dir = $dir1"
    echo "dir = $dir2"
    rsync -avpx --mkpath  "$SESSION_DIR/"  "$dir1/"
    rsync -avpx --mkpath  "$SESSION_DIR/"  "$dir2/"
    rm -r "$dir1/raw"
    ### Generate evidence
    if [[ -n "$ENABLE_XELATEX_EVIDENCE" ]] && [[ $ENABLE_XELATEX_EVIDENCE != false ]]; then
        xelatex_make_evidence_pdf "$dir2"
        
    fi
}

function xelatex_make_evidence_pdf() {
    echo '(xelatex_make_evidence_pdf)'
    dir2="$1"
    IMPORTED_HASH="$(basename "$dir2")"
    echo "dir2=$dir2"
    echo "IMPORTED_HASH=$IMPORTED_HASH"
    cd "$dir2"
    cp "$ASSET_EVIDENCE_TEX_PATH"  "zzz_file_$IMPORTED_HASH.tex"
    cp -r "$ASSET_EVIDENCE_TEXDEPS_PATH"  evidence.tex.d
    (
        printf '\\providecommand{\\METADATAhash}[0]{%s}\n'          "$(jq -r .hash metadata.json)"
        printf '\\providecommand{\\METADATAtimestamp}[0]{%s}\n'     "$(jq -r .timestamp metadata.json)"
        printf '\\providecommand{\\METADATAtimeiso}[0]{%s}\n'       "$(jq -r .timeiso metadata.json)"
        printf '\\providecommand{\\METADATAbasename}[0]{%s}\n'      "$(jq -r .basename metadata.json)"
        printf '\\providecommand{\\METADATAsiteprefix}[0]{%s}\n'    "$SITE_PREFIX"
        printf '\\providecommand{\\METADATAurlbyid}[0]{%s}\n'       "$SITE_PREFIX/id/$YEAR/$TIMESTAMP/"
        printf '\\providecommand{\\METADATAurlbyhash}[0]{%s}\n'     "$SITE_PREFIX/hash/${IMPORTED_HASH:0:2}/$IMPORTED_HASH/"
    ) > evidence-data.tex
    xelatex "zzz_file_$IMPORTED_HASH.tex"
    mv "zzz_file_$IMPORTED_HASH.pdf" "file_$IMPORTED_HASH.pdf"
    rm zzz*
    rm evidence-data.tex
    rm -r evidence.tex.d
}






















SUBCOMMAND="$1"
case "$SUBCOMMAND" in
    import | i )
        try_import_file "$2"
        # cert | make_evidence_pdf )
        # dir2="$WSPATH/files/hash/${IMPORTED_HASH:0:2}/$IMPORTED_HASH"
        ;;
    files/hash/*/*/ )
        if [[ -e "$1"metadata.json ]]; then
            xelatex_make_evidence_pdf "$(realpath "$1")"
        fi
        ;;
esac
