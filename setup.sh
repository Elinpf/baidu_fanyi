#!/bin/bash

echo '#!/bin/bash'>./lwd
echo 'save_path=$PWD'>>./lwd
echo 'cd '$PWD >>./lwd
echo './llwd.rb $*' >>./lwd
echo 'cd $save_path'>>./lwd

sudo cp ./lwd /usr/bin/lwd
chmod +x /usr/bin/lwd

echo 'Setup Finished!'
echo 'use lwd [TEXT] to query.'
