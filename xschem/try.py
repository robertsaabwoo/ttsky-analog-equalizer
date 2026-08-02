import random

# --- CONFIGURATION ---
BIT_RATE    = 1e9         # 1 GHz
VOLTAGE     = 1.8         # 1.8V Logic
RISE_TIME   = 50e-12      # 50ps edge
NUM_BITS    = 2000        # Enough time to lock (2 microseconds)
PATTERN     = None        # Set to [1,1,0,0,1,0] to force a pattern, or None for Random

# --- GENERATOR ---
period = 1 / BIT_RATE
t_curr = 0.0

# Open files
fp = open("vip.txt", "w")
fn = open("vin.txt", "w")

# Initial state
current_bit = 0
fp.write(f"0 0\n")
fn.write(f"0 {VOLTAGE}\n")

bits = []
if PATTERN:
    # Repeat the pattern to fill NUM_BITS
    while len(bits) < NUM_BITS:
        bits.extend(PATTERN)
    bits = bits[:NUM_BITS]
else:
    # Generate Random Data (PRBS-like)
    bits = [random.randint(0, 1) for _ in range(NUM_BITS)]

# Write PWL
for bit in bits:
    # Target voltages
    if bit == 1:
        vp_target = VOLTAGE
        vn_target = 0
    else:
        vp_target = 0
        vn_target = VOLTAGE
    
    # Write the transition (Rise/Fall)
    t_edge_start = t_curr
    t_edge_end   = t_curr + RISE_TIME
    
    fp.write(f"{t_edge_end} {vp_target}\n")
    fn.write(f"{t_edge_end} {vn_target}\n")
    
    # Hold the value until the end of the bit period
    t_curr += period
    
    fp.write(f"{t_curr} {vp_target}\n")
    fn.write(f"{t_curr} {vn_target}\n")

print(f"Generated {NUM_BITS} bits of differential data.")
print(f"Total Simulation Time needed: {t_curr * 1e6:.3f} us")
fp.close()
fn.close()
