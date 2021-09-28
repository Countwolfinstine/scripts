#!/bin/bash -ex

if [ "apply" = "$1" ]
then
    mkdir /tmp/backup || true
    echo "Deleting following files"
    sudo ls -l /etc/ssl/certs | grep DST_Root_CA_X3.pem | awk '{print $9}' 
    sudo ls -l /etc/ssl/certs | grep DST_Root_CA_X3.pem | awk '{print $9}' | xargs rm -f 
    echo "Deleting /usr/share/ca-certificates/mozilla/DST_Root_CA_X3.crt"
    cp /usr/share/ca-certificates/mozilla/DST_Root_CA_X3.crt  /temp/backup || true
    sudo rm -f /usr/share/ca-certificates/mozilla/DST_Root_CA_X3.crt 
    echo "Updating /etc/ca-certificates.conf by adding ! to mozilla/DST_Root_CA_X3.crt"
    sudo sed -i 's/mozilla\/DST_Root_CA_X3.crt/!mozilla\/DST_Root_CA_X3.crt/g' /etc/ca-certificates.conf
    sudo update-ca-certificates --fresh
    
    cat>/tmp/ISRG_Root_X1.crt <<EOC
-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
-----END CERTIFICATE-----
EOC
    
    X1=`ls -l /etc/ssl/certs | grep ISRG_Root_X1.pem`
    
    if [ -z "$X1" ]
    then
        echo "ISRG_Root_X1 not present"

    sudo cp /tmp/ISRG_Root_X1.crt /usr/local/share/ca-certificates.crt
    sudo update-ca-certificates

    else
        echo "ISRG_Root_X1 Already present"
    fi

    if [ "java" = "$2" ]
    then
    for path in $(find / -name cacerts 2>/dev/null)
    do
        if [ "/etc/default/cacerts" != $path ]
        
        then
            timestamp=$(date +%s) 
            keytool -trustcacerts -keystore $path -storepass changeit -importcert -alias isgrrootx1_$timestamp -file "/tmp/ISRG_Root_X1.crt" -noprompt
            sleep 2
        fi
    done
    rm /tmp/ISRG_Root_X1.crt
    fi

else
    echo "RUNNING IN DRY MODE, RERUN WITH ARGUMENT  $0 apply"
    echo "Deleting following files"
    ls -l /etc/ssl/certs | grep DST_Root_CA_X3.pem | awk '{print $9}'
    ls -l /usr/share/ca-certificates/mozilla | grep DST_Root_CA_X3 
    echo "Deleting /usr/share/ca-certificates/mozilla/DST_Root_CA_X3.crt"
    echo "Updating /etc/ca-certificates.conf and running sudo update-ca-certificates --fresh"

fi
