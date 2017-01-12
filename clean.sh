#!/bin/sh

set -e

printf "Cleaning test repos..."
rm -rf $HOME/sandbox/client-A
rm -rf $HOME/sandbox/client-B
rm -rf $HOME/sandbox/host-X.git
rm -rf $HOME/sandbox/host-Z.git
echo " done"
