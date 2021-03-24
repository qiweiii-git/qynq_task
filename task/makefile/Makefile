
SRC = ../../code/firmware/model/*.v

CC = iverilog
CC_FLAGS = -Wall

all:top.sim

top.sim: ./t_autobus.v $(SRC)
	$(CC) $(CC_FLAGS) -I../../code/firmware -o top.sim ./t_autobus.v $(SRC)
