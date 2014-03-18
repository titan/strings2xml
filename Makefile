TARGET = strings2xml
SRC = strings2xml.hs
LIB = -p parsec -p containers

all: $(TARGET)

# we set the no-global-optimize flag to avoid the type checking bug of ajhc,
# see https://github.com/ajhc/ajhc/issues/45
$(TARGET): $(SRC)
	ajhc $(LIB) -fno-global-optimize --cache-dir=/dev/shm/ --tdir=/dev/shm/ $(SRC) -o $@
	strip $@

clean:
	rm -f $(TARGET)

.PHONY: all clean
