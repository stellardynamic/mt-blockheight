#!/bin/bash

#####################################################
#     Multithreaded blockheight monitor Script      #
#         by ForgingPenguin a.k.a tharude           #
#####################################################

# Variables

## Mainnet Nodes ##
node0=("01.lskwallet.space:8000" "01.lskwallet")
node1=("02.lskwallet.space:8000" "02.lskwallet")
node2=("03.lskwallet.space:8000" "03.lskwallet")
node3=("04.lskwallet.space:8000" "04.lskwallet")
node4=("lisk.phoenix1969.net:8000" "phoenix1969")
node5=("lisk.liskwallet.io:8000" "liskwallet.io")
node6=("lisk.fastwallet.online:8000" "fastwallet")
node7=("lisk.cryptostorms.net:8000" "cryptostorms")
node8=("lisknode.io:8000" "lisknode.io")
#node9=()
#node10=()

## Testnet Nodes ##
tnode0=("testnet.lisk.io:7000" "lisk.io")
tnode1=("test-pri.lskwallet.space:7000" "test primary")
tnode2=("lisk.testwallet.online:7000" "testwallet")
tnode3=("158.69.216.49:7000" "158.69.216.49")
#tnode4=()
#tnode5=()
#tnode6=()
#tnode7=()
#tnode8=()
#tnode9=()
#tnode10=()

apicall="/api/loader/status/sync"

## Arrays ##
declare -a nodes=(node0[@] node1[@] node2[@] node3[@] node4[@] node5[@] node6[@] node7[@] node8[@]) # node9[@] node10[@])
declare -a tnodes=(tnode0[@] tnode1[@] tnode2[@] tnode3[@]) # tnode4[@] tnode5[@] tnode6[@] tnode7[@] tnode8[@] tnode9[@])
declare -a height=()
declare -a theight=()

# Get array length

arraylength=${#nodes[@]}
tarraylength=${#tnodes[@]}

## Main loop ##

while true; do

# Spawning curl mainnet processes loop

for n in {1..$arraylength..$arraylength}; do   # start $(arraylength) fetch loops
	for (( i=1; i<${arraylength}+1; i++ )); do
		saddr=${!nodes[i-1]:0:1}
		echo $i $(curl -m 2 -s $saddr$apicall | cut -f 5 -d ":" | sed 's/}$//') >> out.txt &
        done
        wait
done

# Spawning curl testnet processes loop

for n in {1..$tarraylength..$tarraylength}; do   # start $(tarraylength) fetch loops
	for (( i=1; i<${tarraylength}+1; i++ )); do
		tsaddr=${!tnodes[i-1]:0:1}
		echo $i $(curl -m 2 -s $tsaddr$apicall | cut -f 5 -d ":" | sed 's/}$//') >> tout.txt &
	done
	wait
done

# Array read

while read ind line; do
	height[$ind]=$line # assign array values
	done < ./out.txt
rm ./out.txt

while read ind line; do
	theight[$ind]=$line # assign array values
	done < ./tout.txt
rm ./tout.txt

# Output

clear

echo -e "\e[33m----- MAINNET BLOCKHEIGHTS -----\033[0m"

# Finding the highest block

highest=$(echo "${height[*]}" | sort -nr | cut -f 1 -d " ")
echo -e "\e[32m  Highest block is ==> $highest \033[0m"

# Decreasing current blockheight for checks
two=$((highest-2)) # two blocks behind
five=$((highest-5)) # five blocks behind

echo -e "\e[33m--------------------------------\033[0m"

for (( i=1; i<${arraylength}+1; i++ )); do
	sname=${!nodes[i-1]:1:1}
		if [ ! ${height[$i]} ];
		then
			echo -e "  $sname\t\e[31m ==>\tNo Data\033[0m"
		elif [ ${height[$i]} -lt $five ];
		then
			echo -e "  $sname\t\e[31m ==>\t${height[$i]}\033[0m"
		elif [ ${height[$i]} -lt $two ];
		then
			echo -e "  $sname\t\t\e[33m ==>\t${height[$i]}\033[0m"
		else
			echo -e "  $sname\t\t\e[32m${height[$i]}\033[0m"
		fi
done

echo
echo -e "\e[33m----- TESTNET BLOCKHEIGHTS -----\033[0m"

# Finding the highest testnet block

thighest=$(echo "${theight[*]}" | sort -nr | cut -f 1 -d " ")
echo -e "\e[32m  Highest block is ==> $thighest \033[0m"

# Decreasing current blockheight for checks
two=$((thighest-2)) # two blocks behind
five=$((thighest-5)) # five blocks behind

echo -e "\e[33m--------------------------------\033[0m"

for (( i=1; i<${tarraylength}+1; i++ )); do
	tsname=${!tnodes[i-1]:1:1}
		if [ ! ${theight[$i]} ];
		then
			echo -e "  $tsname\t\e[31m ==>\tNo Data\033[0m"
		elif [ ${theight[$i]} -lt $five ];
		then
			echo -e "  $tsname\t\e[31m ==>\t${theight[$i]}\033[0m"
		elif [ ${theight[$i]} -lt $two ];
		then
			echo -e "  $tsname\t\t\e[33m${theight[$i]}\033[0m"
		else
			echo -e "  $tsname\t\t\e[32m${theight[$i]}\033[0m"
		fi
done

sleep 10
done