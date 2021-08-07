## Chip8-cpp
I started working on this project a few weeks into Summer 2021, and I am still working on it.  I have always found emulation very interesting (in some sense
an emulator is a type of universal machine), and this machine is the one nearly everyone suggests to get started with.  
There are some great resources online
such as  
- [CHIP-8 Technical Reference](https://github.com/mattmikolay/chip-8/wiki/CHIP%E2%80%908-Technical-Reference)
- [Guide to making a CHIP-8 emulator](https://tobiasvl.github.io/blog/write-a-chip-8-emulator/)
- [CHIP 8 by secondsun using TDD](https://github.com/secondsun/chip8)  
I was interested in using a TDD approach to development so I started using the [boost-ext/ut](https://github.com/boost-ext/ut) testing library.
It is a nice small library, and it worked perfectly for a TDD approach as I was implementing the instructions for the emulator.        

Some goals I had for this project were:

1. Use `SDL` for graphics.  I had used `SFML` on my DiceGame project, so I wanted to try out `SDL` for this one.
2. Implement a simple debugger with pause and step functionality and an interface using `DearImGui`.
3. Make save state functionality and rewinding.

My hope is that I will be able to reuse some of the code/logic from the debugger and save state manager to use in future emulator projects.  
I think it would be really interesting to make an NES or GameBoy emulator.  

Currently, I have about half of the instructions implemented and can currently run the IBM logo test rom.  I wanted to start adding the ImGui interface,
but realized I will have to setup a 3D renderer to use it (previously I had used `ImGui` with `SFML` and this was all taken care of).  So, I am
now trying to get an OpenGL renderer running (after looking into Vulkan for about a week, I decided it may be better to get my feet wet with OpenGL first
for such a simple project).
