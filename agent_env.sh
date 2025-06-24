export CC=gcc
export CC_FLAGS="$(llvm-config-19 --cflags)"
export CC_LINK_FLAGS="$(llvm-config-19 --ldflags --libs all) -lpthread -ldl -lm -lstdc++"
