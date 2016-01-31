#!/usr/bin/env  python
#-*- coding: utf-8 -*-
""" 
Autor: Kristjan Peterson DK12

Skript loeb esimese parameetrina antud failist sisse URL-id ja nende järel
olevad sõned. URLi ja sõne vahel peab olema tühik, skript seda ei kontrolli.
String ja URL eraldatakse, seejärel tehakse päring vastava URLi pihta.
Vastuse lähtekoodist otsitakse URLi järel olnud stringi. Teise parameetrina 
antud faili kirjutatakse uuesti URL, otsitav string ja "JAH/EI" vastavalt
sellele, kas otsitav string leiti või mitte.

 Veakoodid:

  exit 1 vale arv argumente
  exit 2 viga loetava faili avamisel
  exit 3 väljundfaili ei saa kirjutada

"""

import sys
import urllib2


if len(sys.argv) != 3:
    print '\nKASUTAMINE:\n'
    print '\t%s SISENDFAIL VÄLJUNDFAIL' % sys.argv[0]
    sys.exit(1)

try:
    valjund = open(sys.argv[2], 'a+')
except IOError:
    print '\nVäljundfaili ei saa kirjutada\n'
    sys.exit(3)
    
try:
    sisend = open(sys.argv[1], 'r')
except IOError:
    print '\nSisendfaili avamine ebaõnnestus\n'
    sys.exit(2)

for rida in sisend.readlines():        
    eraldatud = rida.split(' ')
    url = eraldatud[0].strip()
    sone = eraldatud[1].strip()

    try:
        uh = urllib2.urlopen(url)
        puhver = uh.read()
    
    except Exception :
        vpuhver = '\n%s\t%s\tEI(URL avamine ebaõnnestus)\n' % (url, sone)
        
    else:
        if puhver.find(sone) == -1:
            vpuhver = '\n%s\t%s\tEI\n' % (url, sone)

        else:
            vpuhver = '\n%s\t%s\tJAH\n' % (url, sone)
            
    print vpuhver
    valjund.write(vpuhver)
        
valjund.close()
sisend.close()
