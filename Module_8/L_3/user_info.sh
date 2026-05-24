#!/bin/bash

if [ "$1" = "1" ]; then
    echo "Chetv I S"
elif [ "$2" = "2" ] || [ "$1" = "2" ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S')"
else
    echo "Unknown parameter"
fi
