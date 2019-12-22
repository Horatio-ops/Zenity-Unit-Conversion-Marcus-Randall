##############################################
# Welcome to my awesome unit convertor tool. #
# The simple script uses Zenity and advance  # 
# scripting concepts. I hope you enjoy this  #
# did as it took me some time to create :)   #
#                                            #
# Don't forget to leave a like and comment!  #
#                                            #
# (⌐■_■) Peace out dudes!	             #
##############################################
# ------------------------------------------ #
#    Accredited Aurthor: Marcus Randall      #
# ------------------------------------------ #
# Check out my other programs and scrpts on: #
#   Github account github.com/Horatio-ops    #
# ------------------------------------------ #
#          Get in contact with me:           #
#         marcusrandall06@gmail.com          #
#        mr156603@truro-penwith.ac.uk        #
# -------------------------------------------#
# If you do use my work, please reference it #
##############################################

#!/bin/bash

convarray=""
factarray=""

conv=()
fact=()

# read from 'conversion_list.txt' file to construct $conv and $fact arrays used for conversions
INPUT=conversion_list.txt
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read conversion factor
do
  convarray=$convarray"|"$conversion
  factarray=$factarray"|"$factor
  conv+=($conversion)
  fact+=($factor)
done < $INPUT
IFS=$OLDIFS
echo "${conv[@]}"
echo "${fact[@]}"

while :
do
  # use zenity to show dialog with combobox for various conversion options read above and an input text to entry a number
  val=$(zenity --forms --title="Marcus Randall - Conversion tool" --text="Details" \
     --add-combo="Select Conversion" --combo-values="$convarray" \
     --add-entry="Input Value")

  # get the selected conversion and value
  curr_conv="$(cut -d'|' -f1 <<<$val)"
  curr_val="$(cut -d'|' -f2 <<<$val)"

  # if no values are selected (i.e. zenity dialog closed) => terminate the script
  exit_value=""
  if [ "$val" == "$exit_value" ] ; then
      exit
  fi

  # if no values are selected (i.e. no value selected in combo and input value was not set) => show the above zenity dialog again for correct values
  exit_value=" |"
  if [ "$val" == "$exit_value" ] ; then
      continue
  fi

  # if no values are selected (i.e. input value was not set) => show the above zenity dialog again for correct values
  exit_value=""
  if [ "$curr_val" == "$exit_value" ] ; then
      continue
  fi

  # run validation on $curr_val: it checks if it is a number (float numbers are supported)
  regex="^[0-9]*\.?[0-9]*$"
  if [[ $curr_val =~ $regex ]]; then
    :
  else
    # if $curr_val does not match a valid value, shows a message dialog with zenity and then show the above zenity dialog again for correct values
    zenity --info --title="Marcus Randall -  Conversion tool" --text="You have entered: $curr_val\n\nPlease enter numbers only \n" --no-wrap
    continue
  fi

  ind=0
  ind_found=-1
  for i in "${conv[@]}"
  do
    if [ "$i" == "$curr_conv" ] ; then
      ind_found=$ind
      # FIXME: maybe a break could be used here as optimisation?
    fi
    ind=$((ind + 1))
  done
  relation=1
  for i in "${!fact[@]}"; do 
    if [ "$i" -eq "$ind_found" ] ; then
      relation=${fact[$i]}
      # FIXME: maybe a break could be used here as optimisation?
    fi
  done

  # performs the calculation and shows result in zenity dialog
  result=$(echo "scale=5; $curr_val * $relation " | bc -l)
  zenity --info --title="Unit Conversion tool" --text="Conversion: $curr_conv\n\nInput value: $curr_val\nResult: $result \n" --no-wrap
done
