# NetBIOS reconaissance 
# Find SMB users

samrdump=/pentest/libs/impacket-examples/samrdump.py

if [ -z "$3" ]; then
    echo "[*] Simple SMB user gather of hosts in a range"
    echo "[*] Usage : $0 <class C ip>  <low> <high>"
    echo "[*] Example : $0 213.177.4 160 175"
    exit 0
fi

nbtscan -r $1.$2-$3 | grep "^$1." | cut -d " " -f 1 | sort | xargs -n 1 python $samrdump
