#Varying Nodes
printf "0 0\n">outputs/Nodes/throughput.out
printf "0 0\n">outputs/Nodes/delay.out
printf "0 0\n">outputs/Nodes/deliveryRatio.out
printf "0 0\n">outputs/Nodes/dropRatio.out
printf "0 0\n">outputs/Nodes/energyConsumption.out

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

#Varying Flows
printf "0 0\n">outputs/Flows/throughput.out
printf "0 0\n">outputs/Flows/delay.out
printf "0 0\n">outputs/Flows/deliveryRatio.out
printf "0 0\n">outputs/Flows/dropRatio.out
printf "0 0\n">outputs/Flows/energyConsumption.out

factor=1

for (( i = 1; i <= 3; i++ )); do
	flow="$(($i * $factor))"
	ns 802_11_udp.tcl flow $flow
	List=$(gawk -f rule_wireless_udp.awk multi_radio_802_11_random.tr)
	arr=($List)
	printf "$flow ${arr[0]}\n" >> outputs/Flows/throughput.out
	printf "$flow ${arr[1]}\n" >> outputs/Flows/delay.out
	printf "$flow ${arr[2]}\n" >> outputs/Flows/deliveryRatio.out
	printf "$flow ${arr[3]}\n" >> outputs/Flows/dropRatio.out
	printf "$flow ${arr[4]}\n" >> outputs/Flows/energyConsumption.out
done

xgraph outputs/Flows/throughput.out -geometry 800x800
xgraph outputs/Flows/delay.out -geometry 800x800
xgraph outputs/Flows/deliveryRatio.out -geometry 800x800
xgraph outputs/Flows/dropRatio.out -geometry 800x800
xgraph outputs/Flows/energyConsumption.out -geometry 800x800


#Varying Rate
printf "0 0\n">outputs/Rate/throughput.out
printf "0 0\n">outputs/Rate/delay.out
printf "0 0\n">outputs/Rate/deliveryRatio.out
printf "0 0\n">outputs/Rate/dropRatio.out
printf "0 0\n">outputs/Rate/energyConsumption.out

factor=1

for (( i = 1; i <= 3; i++ )); do
	rate="$(($i * $factor))"
	ns 802_11_udp.tcl rate $rate
	List=$(gawk -f rule_wireless_udp.awk multi_radio_802_11_random.tr)
	arr=($List)
	printf "$rate ${arr[0]}\n" >> outputs/Rate/throughput.out
	printf "$rate ${arr[1]}\n" >> outputs/Rate/delay.out
	printf "$rate ${arr[2]}\n" >> outputs/Rate/deliveryRatio.out
	printf "$rate ${arr[3]}\n" >> outputs/Rate/dropRatio.out
	printf "$rate ${arr[4]}\n" >> outputs/Rate/energyConsumption.out
done

xgraph outputs/Rate/throughput.out -geometry 800x800
xgraph outputs/Rate/delay.out -geometry 800x800
xgraph outputs/Rate/deliveryRatio.out -geometry 800x800
xgraph outputs/Rate/dropRatio.out -geometry 800x800
xgraph outputs/Rate/energyConsumption.out -geometry 800x800


#Varying Area
printf "0 0\n">outputs/Area/throughput.out
printf "0 0\n">outputs/Area/delay.out
printf "0 0\n">outputs/Area/deliveryRatio.out
printf "0 0\n">outputs/Area/dropRatio.out
printf "0 0\n">outputs/Area/energyConsumption.out

factor=1

for (( i = 1; i <= 3; i++ )); do
	area="$(($i * $factor))"
	ns 802_11_udp.tcl area $area
	List=$(gawk -f rule_wireless_udp.awk multi_radio_802_11_random.tr)
	arr=($List)
	printf "$area ${arr[0]}\n" >> outputs/Area/throughput.out
	printf "$area ${arr[1]}\n" >> outputs/Area/delay.out
	printf "$area ${arr[2]}\n" >> outputs/Area/deliveryRatio.out
	printf "$area ${arr[3]}\n" >> outputs/Area/dropRatio.out
	printf "$area ${arr[4]}\n" >> outputs/Area/energyConsumption.out
done

xgraph outputs/Area/throughput.out -geometry 800x800
xgraph outputs/Area/delay.out -geometry 800x800
xgraph outputs/Area/deliveryRatio.out -geometry 800x800
xgraph outputs/Area/dropRatio.out -geometry 800x800
xgraph outputs/Area/energyConsumption.out -geometry 800x800

