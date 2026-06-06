#!/bin/bash

set -e

rojo sourcemap test.project.json -o sourcemap.json
if [ ! -f ./globalTypes.d.lua ]; then
    curl -O -s https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.lua
fi

luau-lsp-rokit analyze \
    --definitions=globalTypes.d.lua \
    --base-luaurc=.luaurc \
    --sourcemap=sourcemap.json \
    --platform roblox \
    --flag:LuauSolverV2=True \
    src/ \
2>&1 | sed -e 's/ \[.*\](/(/; s|'"$PWD"'/||' 1>&2
