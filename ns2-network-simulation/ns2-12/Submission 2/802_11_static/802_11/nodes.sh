#Varying Nodes
#printf "0 0\n">outputs/Nodes/throughput.out
#printf "0 0\n">outputs/Nodes/delay.out
#printf "0 0\n">outputs/Nodes/deliveryRatio.out
#printf "0 0\n">outputs/Nodes/dropRatio.out
#printf "0 0\n">outputs/Nodes/energyConsumption.out

factor=1

for (( i = 1; i <= 3; i++ )); do
	node="$(($i * $factor))"
	ns 802_11_udp.tcl node $node
	List=$(gawk -f rule_wireless_udp.awk multi_radio_802_11_random.tr)
	arr=($List)
	printf "$node ${arr[0]}\n" >> outputs/Nodes/throughput.out
	printf "$node ${arr[1]}\n" >> outputs/Nodes/delay.out
	printf "$node ${arr[2]}\n" >> outputs/Nodes/deliveryRatio.out
	printf "$node ${arr[3]}\n" >> outputs/Nodes/dropRatio.out
	printf "$node ${arr[4]}\n" >> outputs/Nodes/energyConsumption.out
done

xgraph outputs/Nodes/throughput.out -geometry 800x800
xgraph outputs/Nodes/delay.out -geometry 800x800
xgraph outputs/Nodes/deliveryRatio.out -geometry 800x800
xgraph outputs/Nodes/dropRatio.out -geometry 800x800
xgraph outputs/Nodes/energyConsumption.out -geometry 800x800

