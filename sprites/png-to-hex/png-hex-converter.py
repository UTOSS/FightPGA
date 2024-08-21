import math
import time
import png      # pypng

from typing import Generator, Any

# Config
COLOR_BITDEPTH = 2      # how many bits to use for color
                        # (make sure this is enough to fit below list!)
COLORS = {
    0: (0, 0, 0),       # black
    1: (255, 255, 255), # white
    2: (255, 0, 0),     # red
    3: (0, 0, 255),     # blue
}
TRANSPARENT = 1         # color that transparent maps to

# Constants
RADIX = "HEX"
PREAMBLE = f"""WIDTH={COLOR_BITDEPTH};
DEPTH={{}};
ADDRESS_RADIX={RADIX};
DATA_RADIX={RADIX};

CONTENT BEGIN

"""
POSTAMBLE = """
END;"""

# Helpers
def round_up_power_of_2(x: int) -> int:
    return 1 << ( int(math.log2(x)) + 1 )

def generate_data_line(addr: int, max_addr: int, data: int) -> str:
    if data.bit_length() > COLOR_BITDEPTH:
        raise ValueError(f"Bitdepth of passed data ({data.bit_depth()}) exceeds specified ({COLOR_BITDEPTH})")

    return f"{hex(addr)[2:].zfill((max_addr.bit_length() // 4)+1)} : {hex(data)[2:]}"

def generate_data_line_hex(addr: int, max_addr: int, data: int) -> str:
    if data.bit_length() > COLOR_BITDEPTH:
        raise ValueError(f"Bitdepth of passed data ({data.bit_depth()}) exceeds specified ({COLOR_BITDEPTH})")

    return f"{hex(data)[2:]}"

def rgb_euclidean_distance(x: tuple, y: tuple) -> float:
    return math.sqrt((x[0] - y[0])**2 + (x[1] - y[1])**2 + (x[2] - y[2])**2)

def closest_color(in_rgb: tuple) -> int:
    # <output color>: <euclidean distance>
    distances: dict[int, float] = {out_color: rgb_euclidean_distance(in_rgb, out_rgb) for out_color, out_rgb in COLORS.items()}
    return min(distances, key=distances.get)

def load_png(filename: str) -> tuple:
    reader = png.Reader(filename)
    width, height, pixels, _ = reader.asRGBA()
    return (width, height, pixels)

def convert_pixels(pixels: Generator):
    # RGBA bytearray -> palette
    for row in pixels:
        i = 0
        while (i + 3) < len(row):
            yield TRANSPARENT if row[i+3] <= 127 else closest_color((row[i], row[i+1], row[i+2]))
            i += 4

def main_hex():
    #in_filename = input("Filename (.png only): ")
    #width, height, pixels_raw = load_png(in_filename)

    #print(f"-\nLoaded image of {width} x {height} = {width * height} pixels")

    sprite_suffixes = ["base", "block", "grab_active", "grab_whiff", "kick_active", "kick_whiff", "wb0", "wb1", "wf0", "wf1"]

    #out_filename = f"out_{int(time.time())}.hex"
    #out_filename = in_filename.strip()[:-4]+".hex"
    out_filename = "ryu.hex"
    for suffix in sprite_suffixes:
        width, height, pixels_raw = load_png("ryu_"+suffix+".png")
        with open(out_filename, "w") as fp:
            print(f"-\nLoaded Ryu image of {width} x {height} = {width * height} pixels")
            for pixel in convert_pixels(pixels_raw):
                fp.write(generate_data_line_hex(0, 0, pixel) + '\n')
        print(f"Finished writing to {out_filename}")
    out_filename = "ken.hex"
    for suffix in sprite_suffixes:
        width, height, pixels_raw = load_png("ken_"+suffix+".png")
        with open(out_filename, "w") as fp:
            print(f"-\nLoaded Ken image of {width} x {height} = {width * height} pixels")
            for pixel in convert_pixels(pixels_raw):
                fp.write(generate_data_line_hex(0, 0, pixel) + '\n')
        print(f"Finished writing to {out_filename}")

if __name__ == "__main__":
    main_hex()