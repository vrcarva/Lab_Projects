EESchema Schematic File Version 4
LIBS:trigger-cache
EELAYER 29 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Isolator:PC817 Optocoupler2
U 1 1 5BD9C5BC
P 3750 4000
F 0 "Optocoupler2" H 3750 4325 50  0000 C CNN
F 1 "PC817b" H 3750 4234 50  0000 C CNN
F 2 "Package_DIP:DIP-4_W7.62mm" H 3550 3800 50  0001 L CIN
F 3 "http://www.soselectronic.cz/a_info/resource/d/pc817.pdf" H 3750 4000 50  0001 L CNN
	1    3750 4000
	1    0    0    -1  
$EndComp
$Comp
L Isolator:PC817 Optocoupler1
U 1 1 5BD9CE81
P 3750 3300
F 0 "Optocoupler1" H 3750 3625 50  0000 C CNN
F 1 "PC817b" H 3750 3534 50  0000 C CNN
F 2 "Package_DIP:DIP-4_W7.62mm" H 3550 3100 50  0001 L CIN
F 3 "http://www.soselectronic.cz/a_info/resource/d/pc817.pdf" H 3750 3300 50  0001 L CNN
	1    3750 3300
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small Resistor1
U 1 1 5BD9EED0
P 3000 3200
F 0 "Resistor1" V 2804 3200 50  0000 C CNN
F 1 "220ohm" V 2895 3200 50  0000 C CNN
F 2 "" H 3000 3200 50  0001 C CNN
F 3 "~" H 3000 3200 50  0001 C CNN
	1    3000 3200
	0    1    1    0   
$EndComp
$Comp
L Device:R_Small Resistor2
U 1 1 5BD9FB67
P 3000 3900
F 0 "Resistor2" V 2804 3900 50  0000 C CNN
F 1 "220ohm" V 2895 3900 50  0000 C CNN
F 2 "" H 3000 3900 50  0001 C CNN
F 3 "~" H 3000 3900 50  0001 C CNN
	1    3000 3900
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR01
U 1 1 5BD9FFE7
P 3150 3450
F 0 "#PWR01" H 3150 3200 50  0001 C CNN
F 1 "GND" H 3155 3277 50  0000 C CNN
F 2 "" H 3150 3450 50  0001 C CNN
F 3 "" H 3150 3450 50  0001 C CNN
	1    3150 3450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR02
U 1 1 5BDA08AE
P 3150 4150
F 0 "#PWR02" H 3150 3900 50  0001 C CNN
F 1 "GND" H 3155 3977 50  0000 C CNN
F 2 "" H 3150 4150 50  0001 C CNN
F 3 "" H 3150 4150 50  0001 C CNN
	1    3150 4150
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x02_Female .1
U 1 1 5BDA11BE
P 2550 3450
F 0 ".1" H 2442 3635 50  0000 C CNN
F 1 "." H 2442 3544 50  0000 C CNN
F 2 "" H 2550 3450 50  0001 C CNN
F 3 "~" H 2550 3450 50  0001 C CNN
	1    2550 3450
	-1   0    0    -1  
$EndComp
Wire Wire Line
	2750 3900 2750 3550
Wire Wire Line
	2750 3200 2750 3450
$Comp
L Device:Varistor Varistor1
U 1 1 5BDA450B
P 4050 2750
F 0 "Varistor1" H 4153 2796 50  0000 L CNN
F 1 "100K" H 4153 2705 50  0000 L CNN
F 2 "" V 3980 2750 50  0001 C CNN
F 3 "~" H 4050 2750 50  0001 C CNN
	1    4050 2750
	1    0    0    -1  
$EndComp
$Comp
L Device:Varistor Varistor2
U 1 1 5BDA4B1C
P 4050 4550
F 0 "Varistor2" H 4153 4596 50  0000 L CNN
F 1 "100k" H 4153 4505 50  0000 L CNN
F 2 "" V 3980 4550 50  0001 C CNN
F 3 "~" H 4050 4550 50  0001 C CNN
	1    4050 4550
	1    0    0    -1  
$EndComp
Wire Wire Line
	4050 4100 4050 4400
Wire Wire Line
	4050 3200 4050 2900
Wire Wire Line
	4050 3900 4050 3650
Wire Wire Line
	4050 3650 4450 3650
Connection ~ 4050 3650
Wire Wire Line
	4050 3650 4050 3400
$Comp
L Device:R_Small Resistor3
U 1 1 5BDA7AC3
P 4450 3850
F 0 "Resistor3" H 4509 3896 50  0000 L CNN
F 1 "500ohm" H 4509 3805 50  0000 L CNN
F 2 "" H 4450 3850 50  0001 C CNN
F 3 "~" H 4450 3850 50  0001 C CNN
	1    4450 3850
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR05
U 1 1 5BDA7E25
P 4450 4100
F 0 "#PWR05" H 4450 3850 50  0001 C CNN
F 1 "GND" H 4455 3927 50  0000 C CNN
F 2 "" H 4450 4100 50  0001 C CNN
F 3 "" H 4450 4100 50  0001 C CNN
	1    4450 4100
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR06
U 1 1 5BDA8306
P 4950 4100
F 0 "#PWR06" H 4950 3850 50  0001 C CNN
F 1 "GND" H 4955 3927 50  0000 C CNN
F 2 "" H 4950 4100 50  0001 C CNN
F 3 "" H 4950 4100 50  0001 C CNN
	1    4950 4100
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_Coaxial Jack1
U 1 1 5BDA8A05
P 4950 3650
F 0 "Jack1" H 5050 3625 50  0000 L CNN
F 1 "Coaxial" H 5050 3534 50  0000 L CNN
F 2 "" H 4950 3650 50  0001 C CNN
F 3 " ~" H 4950 3650 50  0001 C CNN
	1    4950 3650
	1    0    0    -1  
$EndComp
Wire Wire Line
	4950 3850 4950 4100
Wire Wire Line
	4450 3950 4450 4100
Wire Wire Line
	4450 3750 4450 3650
Connection ~ 4450 3650
Wire Wire Line
	4450 3650 4750 3650
Wire Wire Line
	3100 3900 3450 3900
Wire Wire Line
	2900 3900 2750 3900
Wire Wire Line
	3100 3200 3450 3200
Wire Wire Line
	2750 3200 2900 3200
$Comp
L power:+9V #PWR03
U 1 1 5BDAF007
P 4050 2500
F 0 "#PWR03" H 4050 2350 50  0001 C CNN
F 1 "+9V" H 4065 2673 50  0000 C CNN
F 2 "" H 4050 2500 50  0001 C CNN
F 3 "" H 4050 2500 50  0001 C CNN
	1    4050 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	4050 2600 4050 2550
$Comp
L power:-9V #PWR04
U 1 1 5BDAFDCA
P 4050 4800
F 0 "#PWR04" H 4050 4675 50  0001 C CNN
F 1 "-9V" H 4065 4973 50  0000 C CNN
F 2 "" H 4050 4800 50  0001 C CNN
F 3 "" H 4050 4800 50  0001 C CNN
	1    4050 4800
	-1   0    0    1   
$EndComp
Wire Wire Line
	4050 4700 4050 4800
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 5C5F7C38
P 3750 2450
F 0 "#FLG0101" H 3750 2525 50  0001 C CNN
F 1 "PWR_FLAG" H 3750 2623 50  0000 C CNN
F 2 "" H 3750 2450 50  0001 C CNN
F 3 "~" H 3750 2450 50  0001 C CNN
	1    3750 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	3750 2450 3750 2550
Wire Wire Line
	3750 2550 4050 2550
Connection ~ 4050 2550
Wire Wire Line
	4050 2550 4050 2500
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 5C5F85C5
P 3750 4750
F 0 "#FLG0102" H 3750 4825 50  0001 C CNN
F 1 "PWR_FLAG" H 3750 4923 50  0000 C CNN
F 2 "" H 3750 4750 50  0001 C CNN
F 3 "~" H 3750 4750 50  0001 C CNN
	1    3750 4750
	1    0    0    -1  
$EndComp
Wire Wire Line
	3750 4750 3750 4800
Wire Wire Line
	3750 4800 4050 4800
Connection ~ 4050 4800
Wire Wire Line
	3150 3450 3150 3400
Wire Wire Line
	3150 4150 3150 4100
Wire Wire Line
	3150 3400 3450 3400
Wire Wire Line
	3150 4100 3450 4100
$EndSCHEMATC
