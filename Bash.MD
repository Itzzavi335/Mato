# MATO - Lua Obfuscator
# ======================

# Clone and run
git clone https://github.com/Itzzavi335/Mato
cd mato

# Obfuscate input.lua to output.lua
lua mato.lua input.lua output.lua

# Obfuscate and print to screen
lua mato.lua input.lua

# Show help
lua mato.lua --help

# Make executable and run
chmod +x mato.lua
./mato.lua input.lua output.lua

# Install globally
sudo cp mato.lua /usr/local/bin/mato
mato input.lua output.lua

# Test with example
lua mato.lua examples/input.lua examples/output.lua
lua examples/output.lua

# Different protection levels
lua mato.lua input.lua -p lite
lua mato.lua input.lua -p medium
lua mato.lua input.lua -p heavy
lua mato.lua input.lua -p insane

# Batch obfuscate all .lua files
for f in *.lua; do lua mato.lua "$f" "obf_$f"; done

# Check version
lua mato.lua --version
