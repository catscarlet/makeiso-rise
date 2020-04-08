echo '#'
echo "#####################################"
echo "### Running Post Configuration    ###"
echo "#####################################"
echo '#'


echo "### Prepare Payload Packages ###"
mkdir -p /target/root/PAYLOAD
cp -avR /cdrom/PAYLOAD/* /target/root/PAYLOAD/

echo "### RPM Packages Copied ###"
echo "#"
echo "#"
echo "#"


echo "### Prepare initstart.sh ###"
cat << EOF > /target/root/initstart.sh
#!/bin/bash
#set -uxo pipefail

DEBINSTALLRESULT=0

echo 'Check if initstart.sh has executed already'
if [ -f /root/initstart_flag.log ]; then
    echo "initstart.sh has already finished"
    exit
fi

#echo 'Disable APT repos'
# TBD

echo 'Install PAYLOAD'
cd /root/PAYLOAD/
chmod +x install.sh
bash install.sh | tee /root/payload_install.log

/sbin/depmod -a
dpkg -l > /root/dpkg_list.list

echo '#'
echo "#####################################"
echo "### initstart.sh finished at \`date "+%Y-%m-%d %H:%M:%S"\`." >> /root/initstart_flag.log
echo '### Finished'
echo "#####################################"

# Remove initstart.sh in /etc/rc.local
sed -i "/initstart.sh/d" /etc/rc.local

EOF

echo  "#!/bin/bash" >> /target/etc/rc.local
echo  "/root/initstart.sh | tee -a /root/initstart.log" >> /target/etc/rc.local
chmod a+x /target/etc/rc.local
chmod a+x /target/root/initstart.sh

echo "### initstart.sh Prepared ###"
