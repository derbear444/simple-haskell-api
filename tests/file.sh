#!/bin/zsh

# Goes back by a directory
#cd ..

# Performs a GET command with the specified URI
fileJSON=$(echo $(<tests/items.txt))
echo "https://appallocate-cad69-default-rtdb.firebaseio.com/haskell.json\n post\n$fileJSON\n quit" | cabal run