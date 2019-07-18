# Les contraintes sur les entrés sorties sont plusieur type.
#  - choix des pattes associées à chaque signal entrant ou sortant du FPGA
#  - programmation des caractéristiques électriques de ces signaux
#  - programmation des caractéristiques des pattes non utilisées.
#  ATTENTION : il est important de maîtriser le comportement de TOUTES les pattes du FPGA
#  même si elles ne sont pas utilisées dans le design courant (évitons les courts circuits fâcheux...)

# NEUTRALISATON DE TOUTES LES ENTREES SORTIES NON UTILISEES
set_global_assignment -name RESERVE_ALL_UNUSED_PINS_NO_OUTPUT_GND "AS INPUT TRI-STATED"
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

# RECUPERATION OU INVALIDATION EVENTUELLE DES ENTREES SORTIES DE PROGRAMMATION DU FPGA POUR  L'APPLICATION 
# (entrées/sorties à double usage...)
set_global_assignment -name RESERVE_ASDO_AFTER_CONFIGURATION "AS OUTPUT DRIVING AN UNSPECIFIED SIGNAL"

# Pour définir le standard d'une IO en particulier on peut utiliser la syntaxe suivante
#     set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to mon_signal

# On peut définir le courant maximum débité par une sortie: le limiter pour limiter la consommation, ou
# l'augmenter pour tenir compte de la charge, la syntaxe est la suivante
#     set_instance_assignment -name CURRENT_STRENGTH_NEW "4MA" -to mon_signal

# On peut programmer les "temps de montée", l'insertion de résistances de "pull-up" ou de "pull-down", l'insertion de maintien de bus....
set_instance_assignment -name SLEW_RATE 1 -to fpga_LEDR0
set_instance_assignment -name SLEW_RATE 1 -to fpga_LEDR1
set_instance_assignment -name SLEW_RATE 1 -to fpga_LEDR2
set_instance_assignment -name SLEW_RATE 1 -to fpga_LEDR3
set_instance_assignment -name SLEW_RATE 1 -to fpga_SEL_CLK_AUX   


# CHOIX DE POSITION DES ENTREES SORTIES
# Cela doit évidemment être en fait en cohérence avec ce que l'on sait du FPGA et des circuits
# qui lui sont reliés. La ligne ci-dessous est un exemple d'assignation.
#     set_location_assignment PIN_M20 -to address[10] -comment "Address pin to Second FPGA"
#

# Nous choisissons ici de définir des valeurs par défaut pour le standard d'IO et le courant maximum piloté
# par les pattes de sortie du FPGA.
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL"  -to fpga_*
set_instance_assignment -name CURRENT_STRENGTH_NEW "8MA" -to fpga_*

##### PLACEZ ICI VOTRE LISTE DE PINS PROPREMENT DITE

set_location_assignment PIN_AF14 -to fpga_CLK
set_location_assignment PIN_H15 -to fpga_CLK_AUX
set_location_assignment PIN_F6 -to fpga_SEL_CLK_AUX
set_location_assignment PIN_V16 -to fpga_LEDR0
set_location_assignment PIN_W16 -to fpga_LEDR1
set_location_assignment PIN_V17 -to fpga_LEDR2
set_location_assignment PIN_V18 -to fpga_LEDR3
set_location_assignment PIN_AB12 -to fpga_SW0
set_location_assignment PIN_AC12 -to fpga_SW1
set_location_assignment PIN_AA14 -to fpga_NRST

# Le E/S du contrôleur VGA
source pins_assignment_vga.tcl
# La sdram
source pins_assignment_sdram.tcl
