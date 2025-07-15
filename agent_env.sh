export PATH="/usr/lib/llvm-19/bin:$PATH"
export C_INCLUDE_PATH="/usr/lib/llvm-19/include:$C_INCLUDE_PATH"
export CC=gcc
export CC_FLAGS="$(llvm-config --cflags)"
export CC_LINK_FLAGS="$(llvm-config --ldflags --libs all) -lpthread -ldl -lm -lstdc++"
