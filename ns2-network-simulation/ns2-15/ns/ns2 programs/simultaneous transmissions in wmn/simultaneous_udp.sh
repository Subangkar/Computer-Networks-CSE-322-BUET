cd /
cd home
cd ubuntu
cd ns2\ programs/

#		CHANGE PATH IN 4 PLACES *******************************************************

#INPUT: output file AND number of iterations
output_file_format="simultaneous";
iteration_float=5.0;

start_per=0
end_per=0

start=10
end=10

#hop_15_4=5
#dist_15_4=30
#dist_11=$ expr $hop_15_4*$dist_15_4*2


start_pckt_size=28
end_pckt_size=28

start_pckt_per_sec=200
end_pckt_per_sec=200

start_data_rate=11000000
end_data_rate=11000000

start_range_11=250
end_range_11=250
#pckt_interval=[expr 1 / $pckt_per_sec]
#echo "INERVAL: $pckt_interval"

routing=DSDV

time_sim=10

iteration=$(printf %.0f $iteration_float);
#echo "initial total iteration: $iteration"


range_11=$start_range_11
while [ $range_11 -le $end_range_11 ]
do


inc_data_rate=1000000
data_rate=$start_data_rate
while [ $data_rate -le $end_data_rate ]
do


inc_pckt_per_sec=400
pckt_per_sec=$start_pckt_per_sec
while [ $pckt_per_sec -le $end_pckt_per_sec ]
do


pckt_size=$start_pckt_size
while [ $pckt_size -le $end_pckt_size ]
do

p=$start_per
while [ $p -le $end_per ]
do

r=$start
while [ $r -le $end ]
do
echo "total iteration: $iteration"
###############################START A ROUND
l=0;thr=0.0;del=0.0;s_packet=0.0;r_packet=0.0;d_packet=0.0;del_ratio=0.0;
dr_ratio=0.0;time=0.0;t_energy=0.0;energy_bit=0.0;energy_byte=0.0;energy_packet=0.0;total_retransmit=0.0;energy_efficiency=0.0;

i=0
while [ $i -lt $iteration ]
do
#################START AN ITERATION
echo "                             EXECUTING $(($i+1)) th ITERATION (per=$p)"


#                            CHNG PATH		1		######################################################
ns /home/ubuntu/ns2\ programs/simultaneous\ transmissions\ in\ wmn/simultaneous_udp.tcl $r $p $pckt_size $pckt_per_sec $data_rate $range_11    # $dist_11 $pckt_size $pckt_per_sec $routing $time_sim
echo "SIMULATION COMPLETE. BUILDING STAT......"
#awk -f rule_th_del_enr_tcp.awk 802_11_grid_tcp_with_energy_random_traffic.tr > math_model1.out
#                            CHNG PATH		2		######################################################
awk -f /home/ubuntu/ns2\ programs/simultaneous\ transmissions\ in\ wmn/rule_wireless_udp.awk /home/ubuntu/ns2\ programs/raw_data/simultaneous.tr > /home/ubuntu/ns2\ programs/raw_data/simultaneous.out

ok=1;
while read val
do
#	l=$(($l+$inc))
	l=$(($l+1))


	if [ "$l" == "1" ]; then
		if [ `echo "if($val > 0.0) 1; if($val <= 0.0) 0" | bc` -eq 0 ]; then
			ok=0;
			break
			fi	
		thr=$(echo "scale=5; $thr+$val/$iteration_float" | bc)
#		echo -ne "throughput: $thr "
	elif [ "$l" == "2" ]; then
		del=$(echo "scale=5; $del+$val/$iteration_float" | bc)
#		echo -ne "delay: "
	elif [ "$l" == "3" ]; then
		s_packet=$(echo "scale=5; $s_packet+$val/$iteration_float" | bc)
#		echo -ne "send packet: "
	elif [ "$l" == "4" ]; then
		r_packet=$(echo "scale=5; $r_packet+$val/$iteration_float" | bc)
#		echo -ne "received packet: "
	elif [ "$l" == "5" ]; then
		d_packet=$(echo "scale=5; $d_packet+$val/$iteration_float" | bc)
#		echo -ne "drop packet: "
	elif [ "$l" == "6" ]; then
		del_ratio=$(echo "scale=5; $del_ratio+$val/$iteration_float" | bc)
#		echo -ne "delivery ratio: "
	elif [ "$l" == "7" ]; then
		dr_ratio=$(echo "scale=5; $dr_ratio+$val/$iteration_float" | bc)
#		echo -ne "drop ratio: "
	elif [ "$l" == "8" ]; then
		time=$(echo "scale=5; $time+$val/$iteration_float" | bc)
#		echo -ne "time: "
	elif [ "$l" == "9" ]; then
		t_energy=$(echo "scale=5; $t_energy+$val/$iteration_float" | bc)
#		echo -ne "total_energy: "
	elif [ "$l" == "10" ]; then
		energy_bit=$(echo "scale=5; $energy_bit+$val/$iteration_float" | bc)
#		echo -ne "energy_per_bit: "
	elif [ "$l" == "11" ]; then
		energy_byte=$(echo "scale=5; $energy_byte+$val/$iteration_float" | bc)
#		echo -ne "energy_per_byte: "
	elif [ "$l" == "12" ]; then
		energy_packet=$(echo "scale=5; $energy_packet+$val/$iteration_float" | bc)
#		echo -ne "energy_per_packet: "
	elif [ "$l" == "13" ]; then
		total_retransmit=$(echo "scale=5; $total_retransmit+$val/$iteration_float" | bc)
#		echo -ne "total_retrnsmit: "
	elif [ "$l" == "14" ]; then
		energy_efficiency=$(echo "scale=9; $energy_efficiency+$val/$iteration_float" | bc)
#		echo -ne "energy_efficiency: "
	fi


	echo "$val"
#                            CHNG PATH		3		######################################################
done < /home/ubuntu/ns2\ programs/raw_data/simultaneous.out

if [ "$ok" -eq "0" ]; then
	l=0;
	ok=1;
	continue
	fi
i=$(($i+1))
l=0
#################END AN ITERATION
done

enr_nj=$(echo "scale=2; $energy_efficiency*1000000000.0" | bc)

#dir="/home/ubuntu/ns2\ programs/raw_data/"
#tdir="/home/ubuntu/ns2\ programs/multi-radio\ random\ topology/"
#                            CHNG PATH		4		######################################################
dir="/home/ubuntu/ns2_data/simultaneous/"
under="_"
#output_file="$dir$output_file_format$under$r$under$r.out"
data_rate_name=$((data_rate/1000000))
#output_file="$dir$output_file_format$under$r$under$pckt_size$under$pckt_per_sec$under$data_rate_name$under$p.out"
output_file="$dir$output_file_format$under$r$under$pckt_size$under$pckt_per_sec$under$data_rate_name$under$range_11.out"

echo -ne "Percentage_11:          $p " >> $output_file
echo -ne "Throughput:          $thr " >> $output_file
echo -ne "AverageDelay:         $del " >> $output_file
echo -ne "Sent Packets:         $s_packet " >> $output_file
echo -ne "Received Packets:         $r_packet " >> $output_file
echo -ne "Dropped Packets:         $d_packet " >> $output_file
echo -ne "PacketDeliveryRatio:      $del_ratio " >> $output_file
echo -ne "PacketDropRatio:      $dr_ratio " >> $output_file
echo -ne "Total time:  $time " >> $output_file
echo -ne "" >> $output_file
echo -ne "" >> $output_file
echo -ne "Total energy consumption:        $t_energy " >> $output_file
echo -ne "Average Energy per bit:         $energy_bit " >> $output_file
echo -ne "Average Energy per byte:         $energy_byte " >> $output_file
echo -ne "Average energy per packet:         $energy_packet " >> $output_file
echo -ne "total_retransmit:         $total_retransmit " >> $output_file
echo -ne "energy_efficiency(nj/bit):         $enr_nj " >> $output_file
echo "" >> $output_file

r=$(($r+1))
#######################################END A ROUND
done

p=$(($p+1))
done

pckt_size=$(($pckt_size*2))
done

#pckt_per_sec
pckt_per_sec=$(($pckt_per_sec+$inc_pckt_per_sec))
inc_pckt_per_sec=$(($inc_pckt_per_sec+100))
done

#data_rate
data_rate=$(($data_rate+$inc_data_rate))
inc_data_rate=$(($inc_data_rate+8000000))
done

#range_11
range_11=$(($range_11+150))
done


