TARGET = shooter.gb
LINKFILE = linkfile

SRC = main.asm

BIN_DIR := ./bin/
OBJ_DIR := ./obj/
SRC_DIR := ./src/
INC_DIR := ./include/ ./src/ ./data/

#OBJ = $(SRC:.asm=.o)
OBJ := $(patsubst %.asm, $(OBJ_DIR)%.o, $(SRC))
INCLUDES := $(addprefix -i,$(INC_DIR))

all: assemble link fix

$(OBJ_DIR)%.o: $(SRC_DIR)%.asm
	rgbasm $(INCLUDES) -o$@ $<

assemble: $(OBJ_DIR) $(OBJ)

link: $(BIN_DIR) write_linkfile
	@mkdir -p bin
	xlink $(OBJ_DIR)$(LINKFILE)

fix:
	rgbfix -p0 -v $(BIN_DIR)$(TARGET)

write_linkfile:
	echo "[Objects]\n" > $(OBJ_DIR)$(LINKFILE)
	echo $(OBJ) >> $(OBJ_DIR)$(LINKFILE)
	echo "[Output]\n" >> $(OBJ_DIR)$(LINKFILE)
	echo $(BIN_DIR)$(TARGET) >> $(OBJ_DIR)$(LINKFILE)

run: all
	wine ~/bgb/bgb.exe $(BIN_DIR)$(TARGET)

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -f $(BIN_DIR)$(TARGET)

re : fclean run

upload: $(BIN_DIR)$(TARGET)
	sudo ~/ems-flasher/ems-flasher --write $(BIN_DIR)$(TARGET)

$(BIN_DIR):
	mkdir -p $@

$(OBJ_DIR):
	mkdir -p $@
