#======================================================================
# SEGA-CD PCM to WAV
#======================================================================
# Original script by GF64 (Twitter: @_gf64)
# Modified by KatKuriN to fix crackling and convert proper
# 
# Args:
# 'SOURCE','DESTINATION','OFFSET'
#======================================================================
 
import sys
      
#======================================================================
# -------------------------------------------------
# Init
# -------------------------------------------------
 
# For lunar eternal blue:
# 16000 - Original
# 16323 - SEGA CD style
SAMPLE_RATE = (int(sys.argv[4]))
      
input_file = open(sys.argv[1],"rb")
output_file = open(sys.argv[2],"wb")
option_mode = sys.argv[3]
 

input_file.seek(int(sys.argv[3]))
WAVE_START = input_file.tell()
input_file.seek(0,2)
WAVE_END =input_file.tell()
input_file.seek(WAVE_START)
output_file.seek(0)
 
# head
output_file.seek(0x0)
output_file.write( bytes([0x52,0x49,0x46,0x46]) )
output_file.seek(0x8)
output_file.write( bytes([0x57,0x41,0x56,0x45,0x66,0x6D,0x74,0x20]) )
output_file.write( bytes([16]) ) #size 16
 
output_file.seek(20)
output_file.write( bytes([1]) ) # PCM=1
output_file.seek(22)
output_file.write( bytes([1]) ) # MONO
 
a = SAMPLE_RATE         # Samplerate
output_file.seek(24)        # 16000 in reverse
output_file.write( bytes([a&0xFF,
              a>>8&0xFF,
              a>>16&0xFF,
              a>>24&0xFF
              ]) )
a = SAMPLE_RATE         # Samplespeed
output_file.write( bytes([a&0xFF,
              a>>8&0xFF,
              a>>16&0xFF,
              a>>24&0xFF
              ]) )
 
output_file.seek(0x20)
output_file.write( bytes([0x01,0x00,0x08,0x00]) )
output_file.write( bytes([0x64,0x61,0x74,0x61]) )
output_file.seek(0x2C)
 
#output_file.seek(0x20)
#output_file.write(chr(0x01))
#output_file.write(chr(0x00))
#output_file.write(chr(0x08))
#output_file.write(chr(0x00))
#output_file.write("data")
#output_file.seek(0x2C)
 
# write the head
#output_file.seek(0x0)
#output_file.write("RIFF")
#output_file.seek(0x8)
#output_file.write("WAVEfmt ")
#output_file.write(chr(16)) #size 16
 
#output_file.seek(20)       #pcm=1
#output_file.write(chr(1))
#output_file.seek(22)       # MONO (1)
#output_file.write(chr(1))
 
## SAMPLERATE
#a = SAMPLE_RATE
#output_file.seek(24)       # 16000 in reverse
#output_file.write(chr(a&0xFF))
#output_file.write(chr((a>>8)&0xFF))
#output_file.write(chr((a>>16)&0xFF))
#output_file.write(chr((a>>24)&0xFF))
## SAMPLESPEED
#a = SAMPLE_RATE
#output_file.write(chr(a&0xFF))
#output_file.write(chr((a>>8)&0xFF))
#output_file.write(chr((a>>16)&0xFF))
#output_file.write(chr((a>>24)&0xFF))
 
#output_file.seek(0x20)
#output_file.write(chr(0x01))
#output_file.write(chr(0x00))
#output_file.write(chr(0x08))
#output_file.write(chr(0x00))
#output_file.write("data")
#output_file.seek(0x2C)
 
# lets go to work
working=True
 
#======================================================================
# -------------------------------------------------
# Start
# -------------------------------------------------
 
print("Converting...")
working = (WAVE_END-WAVE_START)
 
while working:
    
    a = ord(input_file.read(1))
    working -= 1
        
    #0x00 - 0x7F == [-128, -1]
    if a < 0x80:
        a = 0x80 + a
        
    #0x80 - 0xFF == [0, 127]
    elif a > 0x80:
        a = 0x80 - (a & ~0x80)
    
    output_file.write(bytes([a&0xFF]))
 
    
# ------------------
# Last steps
# ------------------
 
a = output_file.tell() - 0x2C
b = a + 36
 
output_file.seek(0x04)
output_file.write( bytes([b&0xFF,
              b>>8&0xFF,
              b>>16&0xFF,
              b>>24&0xFF
              ]) )
output_file.seek(0x28)
output_file.write( bytes([a&0xFF,
              a>>8&0xFF,
              a>>16&0xFF,
              a>>24&0xFF
              ]) )
 
#output_file.seek(0x4)
#output_file.write( chr(b&0xFF) )
#output_file.write( chr(b>>8&0xFF) )
#output_file.write( chr(b>>16&0xFF) )
#output_file.write( chr(b>>24&0xFF) )
 
#output_file.seek(0x28)
#output_file.write( chr(a&0xFF) )
#output_file.write( chr(a>>8&0xFF) )
#output_file.write( chr(a>>16&0xFF) )
#output_file.write( chr(a>>24&0xFF) )
 
# ----------------------------
# End
# ----------------------------
 
print("Done.")
input_file.close()
output_file.close()
 
