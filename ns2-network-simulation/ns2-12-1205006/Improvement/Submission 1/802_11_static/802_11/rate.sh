#Varying Rate
#printf "0 0\n">outputs/Rate/throughput.out
#printf "0 0\n">outputs/Rate/delay.out
#printf "0 0\n">outputs/Rate/deliveryRatio.out
#printf "0 0\n">outputs/Rate/dropRatio.out
#printf "0 0\n">outputs/Rate/energyConsumption.out

factor=100

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

