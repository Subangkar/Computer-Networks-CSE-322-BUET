#Varying Rate
printf "0 0\n">outputs/Rate/throughput.out
printf "0 0\n">outputs/Rate/delay.out
printf "0 0\n">outputs/Rate/deliveryRatio.out
printf "0 0\n">outputs/Rate/dropRatio.out

factor=100

for (( i = 1; i <= 5; i++ )); do
	rate="$(($i * $factor))"
	ns wired.tcl rate $rate
	List=$(gawk -f wired.awk wired.tr)
	arr=($List)
	printf "$rate ${arr[0]}\n" >> outputs/Rate/throughput.out
	printf "$rate ${arr[1]}\n" >> outputs/Rate/delay.out
	printf "$rate ${arr[2]}\n" >> outputs/Rate/deliveryRatio.out
	printf "$rate ${arr[3]}\n" >> outputs/Rate/dropRatio.out
done

xgraph outputs/Rate/throughput.out -geometry 800x800
xgraph outputs/Rate/delay.out -geometry 800x800
xgraph outputs/Rate/deliveryRatio.out -geometry 800x800
xgraph outputs/Rate/dropRatio.out -geometry 800x800

