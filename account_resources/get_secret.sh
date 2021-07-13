#!/bin/bash

secretstring=$(aws secretsmanager get-secret-value --secret-id $1 | sed 's/[\]//g' | sed 's/\"{/{/g' | sed 's/}\"/}/g' | jq ".SecretString")
token=$(jq ".token" <<< $secretstring | sed 's/\"//g')

jq -n --arg token $token '{"token":$token}'
