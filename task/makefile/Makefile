
SRC = ../../code/firmware/model/*.v

CC = iverilog
CC_FLAGS = -Wall

all: top.sim

top.sim: ../../sim/t_autobus/t_autobus.v $(SRC)
	$(CC) $(CC_FLAGS) -I../../code/firmware -o top.sim ../../sim/t_autobus/t_autobus.v $(SRC)

sim: top.sim
	./top.sim > result.log
	rm -f top.sim

clean:
	rm -f top.sim
	rm -f result.log
