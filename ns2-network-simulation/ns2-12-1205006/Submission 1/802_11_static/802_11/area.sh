#Varying Area
printf "0 0\n">outputs/Area/throughput.out
printf "0 0\n">outputs/Area/delay.out
printf "0 0\n">outputs/Area/deliveryRatio.out
printf "0 0\n">outputs/Area/dropRatio.out
printf "0 0\n">outputs/Area/energyConsumption.out

factor=50

for (( i = 1; i <= 5; i++ )); do
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

