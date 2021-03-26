
SRC  = ../../code/firmware/fpgatools/*.sv
SRC += ../../code/firmware/fpgatools/*.v
SRC += ../../code/firmware/fpgatools/axis/*.sv
SRC += ../../code/firmware/fpgatools/axis/*.v
SRC += ../../code/firmware/fpgatools/hdmi/*.v
SRC += ../../code/firmware/fpgatools/iic/*.sv
SRC += ../../code/firmware/fpgatools/iic/*.v
SRC += ../../code/firmware/fpgatools/others/*.v
SRC += ../../code/firmware/model/*.v
SRC += ../../code/firmware/ov5640/*.v
TST = ../../sim/t_fifo/t_fifo.sv

CC = iverilog
CC_FLAGS = -Wall

all: top.sim

top.sim: $(TST) $(SRC)
	$(CC) $(CC_FLAGS) -I../../code/firmware -I../../code/firmware/fpgatools -D IVERILOG -o top.sim $(TST) $(SRC)

sim: top.sim
	./top.sim > result.log
	rm -f top.sim
	rm -f top.vcd

clean:
	rm -f top.sim
	rm -f top.vcd
	rm -f result.log
