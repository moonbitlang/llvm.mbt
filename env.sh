cc_macro="-D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS"

llvm_cflags=$(llvm-config --cflags)
llvm_ldflags=$(llvm-config --ldflags)
llvm_libs=$(llvm-config --libs all)
llvm_sys_libs="-lpthread -ldl -lm -lstdc++"

export CC=gcc
export CC_FLAGS="$llvm_cflags $llvm_ldflags $cc_macro"
export CC_LINK_FLAGS="./unsafe/warp.c $llvm_libs $llvm_sys_libs"
