#!/bin/bash

secretstring=$(aws secretsmanager get-secret-value --secret-id $1 | sed 's/[\]//g' | sed 's/\"{/{/g' | sed 's/}\"/}/g' | jq ".SecretString")
cert_body=$(jq ".cert_body" <<< $secretstring | sed 's/\"//g')
cert_priv_key=$(jq ".cert_priv_key" <<< $secretstring | sed 's/\"//g')
cert_chain=$(jq ".cert_chain" <<< $secretstring | sed 's/\"//g')

jq -n --arg cert_body $cert_body --arg cert_priv_key $cert_priv_key --arg cert_chain $cert_chain '{"cert_body":$cert_body,"cert_priv_key":$cert_priv_key,"cert_chain":$cert_chain}'