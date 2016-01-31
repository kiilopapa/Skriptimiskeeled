#!/bin/bash

#Autor: Kristjan Peterson ITK DK12


# Kontroll, kas kasutajal on root õigused.
if [ "$UID" -ne "0" ]
then
    echo -e "\nSkripti käivitamine vajab root õigusi !"
    echo -e "\nKasutamine: "
    echo -e "sudo $0 KAUST GRUPP [JAGATUD KAUST]\n"
    exit 1
fi

# Kui on õige arv muutujaid määratakse muutujad
if [ $# -eq 2 ] || [ $# -eq 3 ]
then
    KAUST=$1
    GRUPP=$2
    JAGATUD_KAUST=$(basename ${3-$KAUST})
    ASUKOHT=$(pwd)
    if [ "${KAUST:0:1}" != "/" ]
    then
        KAUST=$ASUKOHT/$KAUST
    fi
#    SHARE_NIMI=$(basename $JAGATUD_KAUST)
    SAMBA_KONF=/etc/samba/smb.conf 
else
    echo -e "\nKasutamine: "
    echo -e "sudo $0 KAUST GRUPP [JAGATUD KAUST]\n" 
    exit 2
fi

# Kausta loomine
if [ ! -d "$KAUST" ]
then 
    echo -e "\n Loon kausta $KAUST"
    mkdir $KAUST
fi

# Grupi loomine
getent group $GRUPP > /dev/null
if [ ! $? -eq 0 ]
then
    echo "Loon grupi $GRUPP"
    addgroup $GRUPP || echo -e "\nGrupi loomine ebaõnnestus" && exit 4
fi

# Samba install (vajadusel)
type smbd > /dev/null 2>&1

if [ $? -ne 0 ]
then
    echo -e "\nPaigaldan Sambat ...."
    apt-get update > /dev/null 2>&1 && apt-get install samba -y || exit 5
fi

# Kas selline kaust on juba sellisele grupile välja jagatud ??
cat $SAMBA_KONF | grep -A 3 path=$KAUST | grep @$GRUPP > /dev/null 2>&1
if [ $? -eq 0 ]
then
    echo -e "\nKaust $KAUST on juba grupile $GRUPP välja jagatud !!! \n"
    exit 7
else
# Kas sellise nimega share juba eksisteerib ?
cat $SAMBA_KONF | grep $JAGATUD_KAUST /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo -e "\n Sellise nimega share on juba olemas !!! .\n"
        exit 8
    fi
fi

# Konfi lisamine, kui võimalik
if [ ! -w $SAMBA_KONF ]
then 
        echo -e "\nSamba konfifaili ei saa kirjutada!"
        exit 9
else
    cp $SAMBA_KONF ${SAMBA_KONF}_copy	#Konfifailist varukoopia
    echo -e "\n[$JAGATUD_KAUST]" >> $SAMBA_KONF 
    echo "    path=$KAUST" >> $SAMBA_KONF
    echo "    writeable=yes" >> $SAMBA_KONF
    echo "    valid users=@$GRUPP" >> $SAMBA_KONF
    echo "    create mask=0664" >> $SAMBA_KONF
    echo "    directory mask=0775" >> $SAMBA_KONF
    # Samba konfifaili kontroll
    testparm -s > /dev/null 2>&1
    if [ $? -gt 0 ]
    then
        echo "Samba konfifaili muutmine ebaõnnestus !!!"
        echo "Taastan esialgse konfiguratsiooni...."
        mv ${SAMBA_KONF}_copy $SAMBA_KONF
    else
    rm ${SAMBA_KONF}_copy
    echo -e "\n Taaskäivitan failiserveri.\n "
    service smbd restart > /dev/null 2>&1 || echo "samba restart ebaõnnestus" exit 10
    echo -e " Kaust $KAUST nimega $JAGATUD_KAUST grupile $GRUPP edukalt välja jagatud\n"
    fi
fi

