
#!/bin/bash
#
# SEC-OPS
# --------
# Herramienta para detectar ataques básicos a redes en archivos pcap.
# Luis Herrera, Abril 2023

clear

#colors
default="\033[0m\e[0m"
yellow="\e[1;93m"
red="\e[1;91m"
cyan="\e[1;94m"
green="\e[1;92m"
purple="\e[1;95m"

#variables
current=$PWD
new_directory="PCAPS"
flag=0
flag2=0
instalation=0
id_file=1
techniques_verif=False

name_option=""
name_suboption=""

#options in main menu
declare -A options
options=(
    ["pcap_analyze"]=1
    ["sniffing"]=2
    ["packet_manipulation"]=3
    ["layer2_attacks"]=4
    ["malicious_ip"]=5
    ["exit"]=6
)

#options in pcap analyzer
declare -A options_pcap_analyzer
options_pcap_analyzer=(
    ["Denial_of_service"]=1
    ["nmap_scan"]=2
    ["vlan_hopping"]=3
    ["hsrp_attack"]=4
    ["tcp_port_scan"]=5
    ["ARP_spoofing"]=6
    ["DHCP_spoofing"]=7
    ["Back"]=8
)

function frame() {
    
    repeat="."
    for (( i=0;i<=70;i++ ))
    do
	echo -n "$repeat"
    done
}

#main banner
function banner() {
    echo -e "${green}"
    echo -e '      ________  ______   ______             _____  __________   ________'
    echo -e '     /   ____/ /  __  \ /  ____\   _____   /     \ \_____    \ /   ____/'
    echo -e '     \____   \ |  ____/ \  \____   |____|    ---     |    ___/ \____   \ '
    echo -e "     /_______/ \_____>   \______\          \_____/   |    |    /_______/      ${cyan}By: Luis Herrera :)${green}"
    echo -e "                                                     |____|                   ${cyan}V.1.0"
    echo -e "${red}"
    echo -e " +-------------------------------------------------------------------------------------------------------------+"
    echo -e " | Speed up the process of detecting basic attacks from a pcap file                                            |"
    echo -e " | and streamline the processes of attacks to local networks.                                                  |"
    echo -e " +-------------------------------------------------------------------------------------------------------------+"
    echo -e "${default}"
}

#prompt
function prompt_option() {
    echo -e "\n${green}┌─[${red}${HOSTNAME}${green}]──[${red}~${green}]─[${yellow}/MainMenu/${name_option}/${green}]:"
}

function prompt_suboption() {
    echo -e "${green}┌─[${red}${HOSTNAME}${green}]──[${red}~${green}]─[${yellow}/MainMenu/PcapAnalyzer/${name_suboption}${green}]:"
}

#errors
function error_option() {
    echo -e "${red}\n ERROR, the specified option does not exist!!\n\n${default}"
}

function error_load_pcap() {
    echo -e "${red}\n ERROR, the specified PCAP file does not exist!!\n\n${default}"
}

function error_instalation() {
    echo -e "${red}\n [+] ERROR, an unexpected error occurred during installation!!${default}"
}

#checking required tools
function tool_check() {

    required_tools=(
        'tshark'
        'scapy'
        'yersinia'
    )

    tool_check=0
    no_tool=()

    echo -e "${yellow}\n [+] Checking required tools.....${default}"
    sleep 0.2

    for i in "${required_tools[@]}"
    do
        if [[ $(which $i) ]];
        then
            echo -e "\n${green} [$i] ${red}Tool is installed $(frame) ${green}[OK]${default}"
            sleep 0.2

        else
            echo -e "\n${green} [$i] ${red}Tool is installed $(frame) [ERROR]${default}"
            tool_check=1
            no_tool+=("$i")
            sleep 1
        fi
    done

    if [ "$tool_check" -eq 1 ];
    then
        for tool in "${no_tool[@]}"
        do
            echo -e "${yellow}\n\n [+] Installing Tool ${green}(${tool})${yellow}, wait a moment.....${default}"

            if [ $(`grep -i "debian" /etc/*-release`) ];
            then
                sudo apt-get install -fy $tool &>/dev/null

            elif [ $(grep -i "arch" /etc/*-release) ];
            then
                sudo pacman -Syu $tool >/dev/null 2>&1

            elif [ $(grep -i "cent0S" /etc/*-release) ];
            then
                sudo yum -y install $tool >/dev/null 2>&1
            fi

            if [ "$?" -eq 0 ];
            then
                echo -e "${green}\n [+] Installation complete.${default}"
                sleep 1

            else
                error_instalation
                sleep 2
                main_menu_option_6
            fi
        done

        echo -e "${green}\n\n [+] Reloading......${default}"
        sleep 2
        main_menu
    fi
}

#pcap analyzer options
function pcap_analyzer_option_1() {
    load_pcap
    detect_DoS
}

function pcap_analyzer_option_2() {
    load_pcap
}

function pcap_analyzer_option_3() {
    load_pcap
}

function pcap_analyzer_option_4() {
    load_pcap
}

function pcap_analyzer_option_5() {
    load_pcap
}

function pcap_analyzer_option_6() {
    load_pcap
}

function pcap_analyzer_option_7() {
    load_pcap
}

function pcap_analyzer_option_8 () {
    main_menu
}

function slowloris() {

   filters=(
	
	'tcp.flags.syn == 1'
	'tcp.flags.syn == 0'
	'tcp.flags.ack == 1'
	'tcp.flags.ack == 0'
	'tcp.dstport == ${port}'
	'tcp.port == ${port}'
	'tcp.window_size < 1000'
	'http.response.code == 400'
	'http.response.code == 408'
	'tcp.flags == 0x018'
    )

    groups=(
	
	'ip.src'
	'ip.dst'
	'tcp.srcport'
	'tcp.dstport'
	'tcp.flags'
	'http.response.code'
	'tcp.segment_data'
    )

    points=0

    input1=$(tshark -r $new_directory/capture-$id_file.pcap -Y "tcp" -T fields -e "${groups[2]}" 2> /dev/null | wc -l)
    value=$((input1))
    
    if [ "$((input1))" -gt 100000 ];
    then
	limit=100000
	
    else
	limit=$((input1))
    fi

    #tiempo
    input2=$(tshark -r $new_directory/capture-$id_file.pcap -Y "tcp" 2> /dev/null | awk '{print $2}' | head -n $limit | awk -F'.' '{print $1}')
    array1=($input2)

    begin="${array1[0]}"

    input3=$(tshark -r $new_directory/capture-$id_file.pcap -Y "tcp" -T fields -e "${groups[4]}" 2> /dev/null | head -n $limit | tr -d '[0x]')
    array2=($input3)

    input4=$(tshark -r $new_directory/capture-$id_file.pcap -Y "${filters[0]} && ${filters[3]}" -T fields -e "${groups[2]}" 2> /dev/null | head -n $limit)
    array3=($input4)
    
    
    # SE PLANEA IMPLEMENTAR NUEVO METODO, MAS EFICIENTE, EXAMINANDO NUMEROS DE SECUENCIA Y ACUSES DE RECIBO
    
    n_elements="${#array1[@]}"
    srcports=()
    syn=0
    j=0
    k=0

    p=0
    q=0
    r=0
    for i in "${array1[@]}"
    do
	if [ "${array2[$j]}" == "2" ];
	then
	    synn=0
	    p=$((p+1))

	elif [ "${array2[$j]}" == "12" ];
	then
	    synack=0
	     q=$((q+1))

        elif [ "${array2[$j]}" == "1" ];
	then
	    ack=0
	    r=$((r+1))

	    if [ "$synn" -eq 0 ];
	    then 
		if [ "$synack" -eq 0 ];
		then
	       	    if [ "${array3[$k-1]}" != "${array3[$k]}" ];
		    then
			syn=$((syn+1))
			srcports+=("${array3[$k]}")
			k=$((k+1))
			synn=1
			synack=1
			ack=1
		    fi
		fi
            fi
        fi

        if [ "$i" == "$((begin+5))" ];
      	then
	    break
	fi

	j=$((j+1))
    done

    echo $p
    echo $q
    echo $r

   # uniqs=$(echo "${srcports[@]}" | tr ' ' '\n' | sort | uniq)
   # unset srcports[*]
   # srcports=($uniqs)

    #n_elements="${#srcports[@]}"

   # if [ "$n_elements" -gt 1 ];
   # then
#	test=$(($n_elements / 2 | bc))

 #   else
#	test=$n_elements
 #   fi
    
  #  input5=$(tshark -r $new_directory/capture-$id_file.pcap -Y "tcp.port == ${srcports[$test]}" -T fields -e "${groups[4]}" 2> /dev/null | tr -d '[0x]')
    array4=($input5)

   # n_elements="${#array4[@]}"
    
   # psh=0
   # for (( i=0;i<=$n_elements-1;i++ ))
   # do
#	if [ "${array4[$i]}" == "18" ];
#	then
#	    psh=$((psh+1))
 #       fi
  #  done

  #  payload=0
   # if [ "$psh" -gt 1 ];
   # then
    #    input6=$(tshark -r $new_directory/capture-$id_file.pcap -Y "tcp.port ==  ${srcports[$test]} && tcp.flags == 0x018" -T fields -e "tcp.segment_data" 2> /dev/null | xxd -r -p | tr -d ' ')
#	array5=($input6)
#	n_elements="${#array5[@]}"

#	input7=$(tshark -r $new_directory/capture-$id_file.pcap -Y "tcp.port == ${srcports[$test]} && (http.response.code == 408 || http.response.code == 400)" -T fields -e "http.response.code" 2> /dev/null)
#	array6=($input7)

#	if $(echo "${array5[0]}" | grep 'GET' 1> /dev/null);
#	then
#	    if $(echo "${array5[2]}" | grep 'WindowsNT5.1' 1> /dev/null);
#	    then
		
#		for (( i=4;i<=$n_elements-1;i++ ))
#		do
#		    if $(echo "${array5[$i]}" | grep 'X-a:b' 1> /dev/null);
#		    then
#			payload=$((payload+1))
#		    fi
#		done

#		code=1
#		for i in "${array6[@]}"
#		do
#		    if [[ "$i" == "400" || "$i" == "408" ]];
#		    then
#			code=0
#		    fi
#		done
	#    fi
#	fi
 #   fi

  #  if [ "$syn" -gt 100 ];
   # then
#	points=$((points+1))
#
#	if [ "$payload" -gt 5 ];
#	then
#	    points=$((points+1))
#
#	    if [ "$code" -eq 0 ];
#	    then
#		points=$((points+1))
#	    fi
 #       fi
  #  fi
#
 #   if [ "$points" -gt 1 ];
  #  then
#	techniques_verif=True

#	echo -e "${green} $(frame)\n  Port impacted: ${red}80\n${green} $(frame)${default}"
#	echo -e "\n${yellow}  (+) Open conections in 5 seconds: ${red}${syn}${default}"
#	echo -e "\n${yellow}  (+) Random port analyzed: ${red}${srcports[$test]}${default}"
#	echo -e "\n${yellow}\t (+) HTTP Request: ${red}${array5[0]}${default}"
#	echo -e "\n${yellow}\t (+) User-Agent: ${red}${array5[2]}${default}"
#	echo -e "\n${yellow}\t (+) Suspicious payloads: ${red}${payload}${default}"
#	echo -ne "\n${yellow}\t (+) Response Code(s):${red}"
#	
#	for i in "${array6[@]}"
#	do
#	    echo -ne " $i ${default}"
 #       done
#	
#	echo -e "\n\n${green} $(frame)${default}"
 #   fi
}

function syn_flood() {
    echo ""
}

function detect_Denial_of_service() {
    
    echo -e "\n${green} [+] ${count}Getting ready......${default}"

    #    hping3                     scapy                    slowloris           
    # un origen                   un origen                  un origen         
    # spoofing                    spoofing                                    
    # cualquier puerto(s)         cualquier puerto(s)            
    # tamaño de ventana -         tamaño de ventana -         
    # repuestas < solicitudes     respuestas < solicitudes                       
    # miles de requets            miles de requests                             
    #                                                        solo al puerto 80 o 443
    #                                                        user agent: windows xp
    #                                                        carga util
    #                                                        psh,ack GET
    #                                                        miles de conexiones abiertas
    #                                                        error 400

    icmp=$(tshark -r  $new_directory/capture-$id_file.pcap -Y "icmp" -T fields -e "ip.src" 2> /dev/null | wc -l)
    tcp=$(tshark -r  $new_directory/capture-$id_file.pcap -Y "tcp" -T fields -e "ip.src" 2> /dev/null | wc -l)
    udp=$(tshark -r  $new_directory/capture-$id_file.pcap -Y "udp" -T fields -e "ip.src" 2> /dev/null | wc -l)

    if [[ "$((icmp))" -gt "$((tcp))" && "$((icmp))" -gt "$((udp))" ]];
    then
	echo -e "\n\n${green} [+] Examining ICMP......${default}\n"
	
    elif [[ "$((tcp))" -gt "$((icmp))" && "$((tcp))" -gt "$((udp))" ]];
    then

	echo -e "\n\n${green} [+] Examining TCP......${default}\n"

	input2=$(tshark -r $new_directory/capture-$id_file.pcap -Y "tcp.flags.syn == 1 && tcp.flags.ack == 0" -T fields -e "tcp.dstport" 2> /dev/null | sort | uniq)
	array1=($input2)

	n_elements="${#array1[@]}"

	if [ "$n_elements" -gt 0 ];
	then
	    for i in "${array1[@]}"
	    do
		if [[ "$i" == '80' || "$i" == '443' ]];
		then
		    slowloris
		    
		    if [ "$techniques_verif" == "False" ];
		    then
			syn_flood
		    fi
		    
		else
		    syn_flood
		fi
	    done
	    
	else
	    echo -e "\n${red} [+] ERROR, there are no packages to analyze!.${default}\n"
	fi

    elif [[ "$((udp))" -gt "$((icmp))" && "$((udp))" -gt "$((tcp))" ]];
    then
	echo -e "\n\n${green} [+] Examining UDP......${default}\n"
    fi
  
}

#load pcap files
function load_pcap() {

    clear
    banner
    echo -e "\n\n ${yellow}[OPTIONS] \n\n${green} [1] Back \n${default}"
    check=0

    while [ "$check" -eq 0 ];
    do
        echo -e "\n${yellow} Enter the path of PCAP file to analyze.${default}\n"
        prompt_suboption
        read -p "└─────► $(tput setaf 7)" path

        if [ "$path" == "1" ];
        then
            main_menu_option_1
            check=1

        else
            echo -e "\n${green} [+] Finding ${path} .....${default}\n"
            sleep 2

            if [ -f "$path" ];
            then

                while [ -f $current/$new_directory/capture-$id_file.pcap ];
                do
                    id_file=$((id_file+1))
                done

                cp $path $current/$new_directory/capture-$id_file.pcap

                echo -e "\n${green} [+] Correct! File selected ==> ${path} \n"
		sleep 1
                detect_${name_suboption}
                check=1

            else

                error_load_pcap
                check=0
            fi
        fi

        if [ "$check" -eq 1 ];
        then
            echo -e "\n\n${yellow} Please, if you analyze other PCAP file, enter de path of this, otherwise, press 1 for back.${default}\n"
            check=0
        fi
    done
}

#option 1 in main menu
function main_menu_option_1() {

    flag=0
    clear
    banner
    echo -e "\n\n ${yellow}[OPTIONS] \n\n${green} [1] Denial of Service\n\n [2] Nmap Scan \n\n [3] Vlan Hopping\n\n [4] HSRP Attack\n\n [5] TCP Port Scan\n\n [6] ARP Spoofing\n\n [7] DHCP Spoofing\n\n [8] Back \n\n ${default}"
    echo -e "${yellow} Please, enter a option${default}\n"

    while [ "$flag" -eq 0 ];
    do
        prompt_option
        read -p "└─────► $(tput setaf 7)" suboption

        if [[ "$suboption" -gt 8 || "$option" -lt 1 ]];
        then
            flag2=1

        else
            flag2=0
        fi

        if [ "$flag2" -eq 0 ];
        then
            for key in "${!options_pcap_analyzer[@]}";
            do
                value="${options_pcap_analyzer[$key]}"
                name_suboption=$key

                if [ "$suboption" == "$value" ];
                then
                    pcap_analyzer_option_${value}
                    flag=1
                fi
            done

        else

            error_option
            flag=0
            flag2=0
        fi
    done
}

#exit
function main_menu_option_6() {

    echo -e "\nBYE!.\n"
    sleep 1
    clear
    exit
    flag=0
}

#main menu
function main_menu() {

    flag=0
    clear
    banner
    tool_check
    echo -e "\n\n ${yellow}[OPTIONS] \n\n${green} [1] PCAP Analyze\n\n [2] Sniffing\n\n [3] Packet Manipulation\n\n [4] Layer 2 Attacks\n\n [5] Malicious Ip\n\n [6] Exit\n\n ${default}"
    echo -e "${yellow} Please, enter a option${default}\n"

    while [ "$flag" -eq 0 ];
    do
        echo -e "\n${green}┌─[${red}${HOSTNAME}${green}]──[${red}~${green}]─[${yellow}/MainMenu/${green}]:"
        read -p "└─────► $(tput setaf 7)" option

        if [[ "$option" -gt 6 || "$option" -lt 1 ]];
        then
            flag2=1

        else
            flag2=0
        fi

        if [ "$flag2" -eq 0 ];
        then
            for key in "${!options[@]}";
            do
                value="${options[$key]}"
                name_option=$key

                if [ "$option" == "$value" ];
                then
                    main_menu_option_${value}
                    flag=1
                fi
            done

        else

            error_option
            flag=0
            flag2=0
        fi
    done
}

#main program

if [[ ! -d $new_directory ]];
then
    mkdir $new_directory
fi

main_menu
