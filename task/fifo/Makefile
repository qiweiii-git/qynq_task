
SRC = ../../code/firmware/fpgatools/qwicom.sv
TST = ../../sim/t_fifo/t_fifo.sv

CC = iverilog
CC_FLAGS = -Wall

all: top.sim

top.sim: $(TST) $(SRC)
	$(CC) $(CC_FLAGS) -I../../code/firmware -o top.sim $(TST) $(SRC)

sim: top.sim
	./top.sim > result.log
	vvp -n top.sim -lxt2
	mv top.vcd top.lxt
	rm -f top.sim

clean:
	rm -f top.sim
	rm -f top.vcd
	rm -f result.log
	rm -f top.lxt
