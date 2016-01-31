#!/bin/bash

#Autor: Kristjan Peterson DK12

#loo-kodu www.minuveebisait.ee
#Skript paigaldab apache2 serveri, kui see puudub
#Loob nimelahenduse (lihtsalt /etc/hosts failis)
#Kopeerib vaikimisi veebisaidi ja modifitseerib index.html faili sisu vastavalt loodavale lehele

#

# exit 1 ei ole root õigusi
# exit 2 vale arv argumente
# exit 3 ei ole interneti ühendust
# exit 4 apache paigaldamine ebaõnnestus
# exit 5 hosts faili kirjutamine ebaõnnestus
# exit 6 veebilehe jaoks kausta loomine ebaõnnestus
# exit 7 index.html-i kirjutamine ebaõnnestus
# exit 8 sites-available konfi loomine ebaõnnestus
# exit 9 sites-available konfi lubamine ebaõnnestus
# exit 10 Apache reload ebaõnnestus
# exit 11 Selline kodu on juba olemas


export LC_ALL=C



# Kontroll, kas kasutajal on root õigused.
if [ "$UID" -ne "0" ] 
then
    echo -e "\nSkripti käivitamine vajab root õigusi !"
    echo -e "\nKasutamine: "
    echo -e "sudo $0 www.minuveebisait.ee]\n"
    exit 1
fi

# Kas sisendiks on täpselt üks parameeter ?
if [ $# -eq 1 ]
then
    SAIT=$1
    KAUST=/var/www
    HOSTS=/etc/hosts
    SITESAVAILABLE=/etc/apache2/sites-available
else
    echo -e "\nKasutamine: "
    echo -e "sudo $0 www.minuveebisait.ee\n"
    exit 2
fi

# Kas apache on olemas, kui ei ole siis paigaldus

apt-cache policy apache2 | grep 'Installed: (none)' > dev>null 2>&1

if [ $? -eq 0 ]
then
    ping 8.8.8.8 -c1 || echo -c "\nInterneti ühendus puudub" exit 3
    echo -e "\nPaigaldan Apachet ...."
    apt-get update > dev>null 2>&1 && apt-get install apache2 -y || echo "apache paigaldamine ebaõnnestus" exit 4
fi

# Katkestamine, kui selline kodu juba eksisteerib

ls /etc/apache2/sites-enabled/ | grep $SAIT > dev>null 2>&1

if [ $? -eq 0  ]
then
    echo " Selline kodu on juba olemas !!! "
    exit 11
fi

# Hosts faili kirje lisamine, kui seda seal eelnevalt pole

grep $SAIT $HOSTS > /dev/null || echo "127.0.0.1 $SAIT" >> $HOSTS || exit 5

# Kausta loomiine veebilehe jaoks

mkdir -p $KAUST/$SAIT || echo "Kausta loomine ebaõnnestus" exit 6

# index.html kirjutamine

echo "<h1>$SAIT</h1>" > $KAUST/$SAIT/index.html || echo "index.html-i kirjutamine ebaõnnestus" exit 7

# kodu konfi faili loomine ja muutmine

sed -e "s@#ServerName www.example.com@ServerName $SAIT@" -e "s@DocumentRoot /var/www/html@DocumentRoot $KAUST/$SAIT@"  $SITESAVAILABLE/000-default.conf > $SITESAVAILABLE/$SAIT.conf

if [ $? -ne 0 ]
then
    echo "Uue kodu konfifali loomine ebaõnnestus"
    exit 8
fi

# uue kodu lubamine

a2ensite $SAIT.conf > dev>null 2>&1 || exho "Uue kodu konfi lubamine ebõnnestus" exit 9

service apache2 reload > dev>null 2>&1
if [ $? -ne 0 ]
then
    echo "Apache reload ebaõnnestus"
    a2dissite $SAIT.conf
    service apache2 reload
    exit 10
fi

echo "Uus kodu $SAIT loodud."


