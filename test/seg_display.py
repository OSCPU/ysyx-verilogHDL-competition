import fileinput

TEMPLATE = '''
     AAAAAAAAA
    FF       BB
    FF       BB
    FF       BB
    FF       BB
     GGGGGGGG
   EE       CC
   EE       CC
   EE       CC
   EE       CC
    DDDDDDDDD PP
''' 

# These are ANSI Escape Codes

# Clear the screen and move the cursor to the top-left corner, this is used to reset the display before the first frame.
RESET = '\033[2J\033[1;1f'
# Clear the screen from the current cursor position to the end of the screen, this is used to reset the display before each frame.
CLEAR = '\033[1;1f\033[J'
WHITE = '\033[37m░\033[0m'  # A white block
BLACK = '\033[31m█\033[0m'  # A black block

print(RESET)

for line in fileinput.input():
    # Execute the input line (like "A=0; B=1; ...") as Python code; the
    # variables A, B, ... will be stored in ctx.
    exec(line, (ctx := {}))

    # Initialize the display with a clear screen and the template.
    disp = CLEAR + TEMPLATE

    for ch in 'ABCDEFGP':
        # Determine the block color.
        block = {
            1: WHITE,
            0: BLACK,
        }.get(ctx.get(ch, 0), '?')

        # Replace each character in the template with its block.
        disp = disp.replace(ch, block)

    print(disp)
