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

