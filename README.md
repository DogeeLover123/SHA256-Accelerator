# SHA256-Accelerator

Constrained SHA256 Accelerator that only takes in 512 bit padded hash digest inputs. User enters up to 55 ASCII characters and padding.cpp adds the padding and sends it to Putty via UART.
To be fully transparent this padding.cpp was made with chatgpt with minor modifications. NONE of the Verilog was made with any AI help though (if you look at my RTL you'll see that I am not lying my code is so ugly it is probably way worse then what AI would have done lmao)

I used this PDF heavily as I found it explains the SHA-256 algorithm really nicely:
https://helix.stormhub.org/papers/SHA-256.pdf
To check my work I tested my code against this SHA-256 simulator:
https://sha256algorithm.com/

The UART recieving module I made recieves the 512 bit padded message. It waits until 3 separate padded hash digest messages are sent. Once 3 have been sent, it moves on to the block decomposition block. This then moves on to the core hash computation module. The hash computation module has 64 rounds that need to happen in the correct order. This hash computation module interleaves between 3 messages, improving throughput for this module by 200%
Finally, the 3 hash messages are sent back via the UART TX controller

Some insights:
The hash computation module features quite a few adds and shifts, and so in order to meet timing closure I had to add pipeline stages. I ended up having 3 pipeline stages. I don't think I needed that many but I wanted to get some more experience dealing with increased latencies from higher pipelined stuff. The problem is that these computations are recursive, meaning we are repeatedly performing computations on the same number that require the state from the immediate previous round. With pipelining, each 'round' takes 3 cycles, so we can only work on the next round until we see the output from the first round which takes 3 cycles. This would basically mean that I would have to stall the hash computation core 2/3 of the time for a 3 pipeline stage, which is really bad. The way I tackled this was by introducing interleaving. Assuming you can get 3 completely separate and independent messages, you can work on:
Cycle 1: Message 1 round 1
Cycle 2: Message 2 round 1
Cycle 3: Message 3 round 2 // Message 1 round 1 is just now being registered and will be ready for use in the next cycle
Cycle 4: Message 1 round 2
...

This is doubly good because we don't need to increase the amount of logic needed to improve throughput, and we also increase utilization to 100% instead of 33%!

I have to state though that all of this is kind of pointless because even at 115200 baud rate the UART controller is BY FAR the biggest bottleneck, and takes up 99% of the full end-to-end time. Unfortunately I am stuck with UART for this fpga so in the interest of atleast being able to practice high speed RTL design I chose to implement this change anyways. :)

I had an issue with the UART controller with making sure the internally generated uart baud clocks are synchronized with the actual baud rate. The way I generated them was by dividing the main sys clk by using the simple counter register but this of course is not exactly the same. I helped mitigate this by oversampling the baud clk by 16x for the RX controller, and only sampling the middle bit 8. This provides some margin, but over time my clock will slowly drift more then 8 bits if we do not ever resynchronize so this is only a temporary fix.
The big fix required is that in the UART state logic, when it goes from data->stop bit, we do not sample at the middle bit, but look for the state transition from from stop->start every cycle (rx=1->rx=0). So basically this means that as long as within one byte transfer (1 start bit + 8 data bits + 1 stop bit) my internal baud sample clock doesn't drift by more then 8 bits it will resynchronize every byte transfer.
