#Varying Flows
printf "0 0\n">outputs/Flows/throughput.out
printf "0 0\n">outputs/Flows/delay.out
printf "0 0\n">outputs/Flows/deliveryRatio.out
printf "0 0\n">outputs/Flows/dropRatio.out

factor=10

for (( i = 1; i <= 5; i++ )); do
	flow="$(($i * $factor))"
	ns wired.tcl flow $flow
	List=$(gawk -f wired.awk wired.tr)
	arr=($List)
	printf "$flow ${arr[0]}\n" >> outputs/Flows/throughput.out
	printf "$flow ${arr[1]}\n" >> outputs/Flows/delay.out
	printf "$flow ${arr[2]}\n" >> outputs/Flows/deliveryRatio.out
	printf "$flow ${arr[3]}\n" >> outputs/Flows/dropRatio.out
done

xgraph outputs/Flows/throughput.out -geometry 800x800
xgraph outputs/Flows/delay.out -geometry 800x800
xgraph outputs/Flows/deliveryRatio.out -geometry 800x800
xgraph outputs/Flows/dropRatio.out -geometry 800x800

