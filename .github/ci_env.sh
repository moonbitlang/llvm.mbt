cc_macro="-D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS"
export llvm_link_lib="-lLLVM-19 -lstdc++ -lm -lpthread -ldl"

target=''

case $(uname -ms) in
'Darwin x86_64')
    target=darwin-x86_64
    # warning x86_64 and aarch64 llvm installed path is different
    # Darwin x86_64 is installed in /usr
    # Darwin arm64 is installed  in  /opt
    
    llvm_include="-I/usr/local/opt/llvm@19/include"
    llvm_link_dir="-L/usr/local/opt/llvm@19/lib"
    export C_INCLUDE_PATH="/usr/local/opt/llvm@19/include":$C_INCLUDE_PATH
    export CC=clang
    export CC_FLAGS="$llvm_include $cc_macro"
    export CC_LINK_FLAGS="$llvm_link_dir $llvm_link_lib"
    ;;
'Darwin arm64')
    target=darwin-aarch64
    llvm_include="-I/opt/homebrew/opt/llvm@19/include"
    llvm_link_dir="-L/opt/homebrew/opt/llvm@19/lib"
    export C_INCLUDE_PATH="/opt/homebrew/opt/llvm@19/include":$C_INCLUDE_PATH
    export CC=clang
    export CC_FLAGS="$llvm_include $cc_macro"
    export CC_LINK_FLAGS="$llvm_link_dir $llvm_link_lib"
    ;;
'Linux x86_64')
    target=linux-x86_64
    # downloaded llvm-19 only support use lld to link
    llvm_home=/usr/lib/llvm-19
    ld=lld
    llvm_include="-I $llvm_home/include"
    llvm_link_dir="-L $llvm_home/lib"

    export C_INCLUDE_PATH="$llvm_home/include":$C_INCLUDE_PATH
    export CC=clang
    export CC_FLAGS="$llvm_include $cc_macro"
    export CC_LINK_FLAGS="$llvm_link_dir $llvm_link_lib"
    ;;
esac
