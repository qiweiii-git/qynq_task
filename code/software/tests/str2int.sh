
rm -f str2int
gcc -I../utils -o str2int str2int.c ../utils/StrToInt.c
echo "str2int Generated"
./str2int