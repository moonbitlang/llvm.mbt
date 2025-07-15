const { execSync } = require('child_process')
const path = require('path')

try {
  // Helper function to execute shell commands and trim output
  const runCommand = (command) => {
    try {
      return execSync(command, { encoding: 'utf8' }).trim()
    } catch (error) {
      console.error(`Error executing command: ${command}`)
      console.error(error.stderr || error.message)
      process.exit(1)
    }
  }

  // 1. Set CC
  const cc = process.env.CC || 'gcc' // Use environment CC if set, otherwise default to gcc

  // 2. Construct CC_FLAGS
  const ccFlagsCmd = 'llvm-config --cflags'
  const ccFlags = runCommand(ccFlagsCmd)

  const llvmCInclude = 'llvm-config --prefix'
  const llvmCIncludePath = runCommand(llvmCInclude)
  const stubCCFlags = `-I${llvmCIncludePath} -DNDEBUG`

  // 3. Get LLVM ldflags
  const llvmLdflagsCmd = 'llvm-config --cflags --ldflags --libs all'
  const ccLinkFlags = runCommand(llvmLdflagsCmd).replace(/(\r\n|\n|\r)/gm, " ") + ' -lpthread -ldl -lm -lstdc++'

  // 4. Construct C_INCLUDE_PATH
  const existingCIncludePath = process.env.C_INCLUDE_PATH || ''
  const cIncludePath = existingCIncludePath

  // 5. Assemble the variables
  const output = {
    vars: {
      CC: cc,
      CC_FLAGS: ccFlags,
      STUB_CC_FLAGS: stubCCFlags,
      CC_LINK_FLAGS: ccLinkFlags,
      C_INCLUDE_PATH: cIncludePath,
    },
    link_configs: [
      {
        package: 'Kaida-Amethyst/llvm/unsafe',
        link_flags: ccLinkFlags,
      },
    ],
  }

  console.log(JSON.stringify(output, null, 2))
} catch (error) {
  // Catch any unexpected errors during setup or JSON stringification
  console.error('An unexpected error occurred:', error.message)
  process.exit(1)
}
