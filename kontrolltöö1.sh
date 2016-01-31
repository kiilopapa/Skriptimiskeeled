#!/bin/bash
#Autor: Kristjan Peterson ITK DK12
#Skript saab käsurealt kolm parameetrit. 1. kataloog 2. kasutajanimi 3.väljundfail .Skript kirjutab väljundfaili kõikide failide nimekirja, kuhu teise #parameetrina antud kasutaja saab kirjutada ja mis asuvad esimese #parameetrina antud kataloogis või selle alamkataloogides.

# Kontroll, kas kasutajal on root õigused.

if [ "$UID" -ne "0" ]
then
    echo "Skripti käivitamine vajab root õigusi !"
    echo "Kasutamine: "
    echo "sudo $0 KATALOOG KASUTAJA VÄLJUNDFAIL"
    exit 4
fi

# Kontroll, kas on õige arv muutujaid

if [ $# -eq 3 ]
then
    KATALOOG=$1
    KASUTAJA=$2
    VALJUND=$3
    ASUKOHT=$(pwd)
else
    echo "Kasutamine: "
    echo "sudo $0 KATALOOG KASUTAJA VÄLJUNDFAIL"
exit 3
fi


# Kontroll, kas kasutaja ja kaust on olemas.

getent passwd $KASUTAJA > /dev/null

if [ ! $? -eq 0 ] && [ ! -d $KATALOOG ]
then
    echo "Vale kasutajanimi või kataloog."
    exit 1
fi

# Kontroll, kas väljundfaili saab kirjutamiseks avada.

if [ ! -w $VALJUND ]
then
    echo "Väljundfaili ei saa kirjutada, kontrolli faili olemasolu !"
    exit 2
fi

# Kirjutatavate failide otsing ja väljundisse kirjutamine.

find $KATALOOG -writable -user $KASUTAJA > $VALJUND
if [ $? -eq 0 ]
then
    if [ "${VALJUND:0:1}" != "/" ]
    then
        echo "Nimekiri failidest, millesse $KASUTAJA saab kirjutada asub failis $ASUKOHT/$VALJUND "
    else
        echo "Nimekiri failidest, millesse $KASUTAJA saab kirjutada asub failis $VALJUND "
    fi
else
    echo "Mingi Force Majure, tee parem käsitsi :)"
fi

        


