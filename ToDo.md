
# 230324
sette opp arm virt lab med qemu. OK
kan kjøre ropEmporium binærer. OK
kan kjøre azeria VM lab med Vmware. OK
må sette opp gdb server for å kunne debugge fra guest til host. 
port fwd i qemu config.


puts@plt

plt means procedure linkage table. can be seen as a tag for all funcs that is located in another module, e.g libc.
PLT is an area in you executable or .so file where all outstanding references are collected together.
format: they have the target machine jump instruction, with actuall address remaining unfilled. It is the responsibility of the loader to fill these addresses.

remaining part of your module makes func calls through PLT using relative addressing, and offset to PLT is kown at the time of linke. nothing has to be fixed up.

Complementery to the PLT is the GOT, global offset table. PLT is used for function calls, GOT is used for data.
GOT also holds actual pointers to external code used by PLT stubs
