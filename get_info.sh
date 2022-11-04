#!/bin/sh
# アカウントの情報を一気に取得するためのスクリプト
flow transactions send src/transactions/get_info.cdc
flow transactions send --signer anpan src/transactions/get_info.cdc
flow transactions send --signer jam src/transactions/get_info.cdc
flow transactions send --signer baikin src/transactions/get_info.cdc
