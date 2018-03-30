Rocket rv32 extension
=========================

This repo is a fork ("new-devices-cow") of the new-devices branch of fpga-zynq.
The README gives instructions to synthesize a 32 bit (rv32) RISC-V core on a Xilinx Zynq development board and to run bare metal binaries on it.
Apps running on top of linux (bbl) or the proxy kernel (pk) are out of
scope of this file.
We only roughly cover the steps to synthesize the rocket chip.
When you feel details are missing, check the regular fpga-zynq [README](https://github.com/ucb-bar/fpga-zynq).

_Note_: If you'd like to use a different branch of fpga-zynq, look at 
 [this section](#all_branches), which describes necessary steps to get rv32 running.


We assume here that you set up environmental variables like in the fpga-zynq readme (`$ROCKET_DIR`, `$RISCV`, `$REPO`). Most of the commands are relative to the fpga-zynq directory, so

    $ cd $REPO


<a name="synth"></a>Synthesizing a rv32 core
------------------

If you don't need to change anything in rocket chip, the following steps 
will provide you with all necessary files to instatiate a rv32 core on 
the fpga. Please note that this has been tested with the zc706 board only
and could cause errors on other boards.

First, source the following to set the environment for Xilinx Vivado and
to obtain the license.

    $ source /tools/flexlm/flexlm.sh
    $ source /tools/xilinx/Vivado/2016.2/settings64.sh
 
Enter the subdirectory of the baord

    $ cd zc706

Now, one after another

    $ make rocket CONFIG_PROJECT=zynq CONFIG=ZynqRV32ConfigCow
    $ make project  CONFIG_PROJECT=zynq CONFIG=ZynqRV32ConfigCow
    $ make fpga-images-zybo/boot.bin CONFIG_PROJECT=zynq CONFIG=ZynqRV32ConfigCow

There should be four files (`boot.bin`, `devicetree.dtb` ,`uImage`, `uramdisk.image.gz`) in the `fpga-images-zc706` folder. Copy these onto the SD card from which the board boots.

Prepare toolchain
------------------

In theory, every riscv64-unknown-elf toolchain should be capable of building 32 bit binaries by adding compiler flags to your gcc commands.

    $ riscv64-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -o hello.elf hello.c

However, we **strongly recommend** builing a dedicated rv32 toolchain. 
If you plan to build applications for the [Zephyr RTOS](#zephyr) anyway, you may use the one bundled with it.
Otherwise, build the toolchain that comes with fpga-zynq in `$ROCKET_DIR/riscv-tools/`. 
Therefore, look into and execute `build-rv32ima.sh`.


Building ARM binaries
------------------ 


In theory, the binaries running on the arm side of zynq (`fesvr-zynq` + `libicenet.so` + `libfesvr.so`) might be compatible with rv32 code. (As the arm side is untouched.)
To test whether that holds true for you, you may skip this section and
try running a simple test program described in the [next section](#programs).
However, I had to recompile fesvr to get stuff running.
If you don't see the expected output, consider doing this, too. 

Be aware that there are 2 different versions to be built:

- For simulation, compiled with normal x86 local gcc 
- For actual FPGA, compiled with arm-xilinx gcc 

### a) for simulation
To check, see whether the following compilation is executed by g++.
Goto build dir and compile

    $ cd $(ROCKET_DIR)/riscv-tools/riscv-fesvr/build
    $ ../configure --prefix=$RISCV 
    $ make
    $ make install

This will copy `libfesvr.so` into `$RISCV/lib` which is used for simulators (eg. vsim in `$REPO/simulation`)

### b) for RISC-V on fpga
Source Xilinx vivado to obtain the correct compiler. 

    $ source /tools/xilinx/Vivado/2016.2/settings64.sh

To check, see whether the following compilation is executed by `arm-linux-gnueabi-g++`. Go to your target board folder

    $ cd zc706

to build fesvr binary

    $ make fesvr-zynq

go to build dir 

    $ cd $REPO/common/build

and run 

    $ $ROCKET_DIR/riscv-tools/riscv-fesvr/configure --host=arm-xilinx-linux-gnueabi 
    $ make libfesvr.so # still inside common/build!
    
You should now find `libfesvr.so` and `fesvr-zynq` in `common/build`.

- If include error. Add following line after `fpga-zynq/common/Makefrag:225`. You might need to build at least fesvr from `riscv-tools/build-rv32ima.sh`.
    ```
    -I $(ROCKET_DIR)/riscv-tools/riscv-fesvr/fesvr
    ```

- If error: 'can't read format of `libfesvr.so`': check whether make fesvr-zynq was successfully built before.


<a name="programs"></a>First bare metal programs
------------------


 Even bare metal binaries need some additional code for communication with the arm
 to show output on the console. (Unless they run on the pk.)
 This fork comes with a few simple tests in `$REPO/common/csrc` that should be
 considered as examples. 
 Build one of them, eg. by

    $ cd common/csrc/test_hello32
    $ make

Now you can copy hello.elf onto the fpga. We recommend using an ethernet connection ([setup](https://github.com/ucb-bar/fpga-zynq#appendices)) to connect with the FPGA, ssh for terminal sessions and SCP for file transfer.
If you rebuilt fesvr, copy all needed files to `~` on the fpga.

    common/build/libfesvr.so -> ~
    common/build/fesvr-zynq  -> ~

If you are on a fpga-zynq branch that included icenet, additionally copy its lib.

    common/build/libicenet.so -> ~

Afterwards, log into the fpga terminal and

    $ cd ~
    $ cp libfesvr.so /usr/local/lib
    $ cp libicenet.so /usr/local/lib

We should be ready to run now:

    $ ./fesvr-zynq hello.elf


<a name="trouble"></a> Troubleshooting
------------------

If you don't see any output from the `hello.elf` example, you probably want to debug using Xilinx chipscope. This provides you with the ability to look into nearly every register / wire of your 
verilog source file.

### Create hardware debug core

Therefore, you first need to set up a debug core for your rocket chip. Go back in your workflow to the [synthesization](#synth) of your core. Right after giving the `make rocket` command, annotate the verilog file in `zc706/src/verilog/Top.ZynqRV32ConfigCow.v`.
Every line you want to scope in, needs to be prefixed like

```
(* mark_debug = "true" *) reg [31:0] wb_reg_pc
```

A good starting set of signals to look into is
```
// CSR
reg [31:0] wb_reg_pc, 	        // program counter
reg [31:0] wb_reg_raw_inst;

input io_interrupts_msip,       // machine software interrupt pending
input io_interrupts_meip        // machine external interrupt pending
reg [31:0] reg_mepc;	        // save interrupted pc
reg [31:0] reg_mbadaddr;
reg [31:0] reg_mtvec;           // trap vector
wire [31:0] read_mstatus;
reg [31:0] reg_mcause	        // gives interrupt port

// CPU exception
reg wb_reg_xcpt                 // cpu exception on instruction
reg wb_reg_cause                // as defined in rocket/Instructions.scala.
``` 

Now, add the debug core to the Vivado project:
- open vivado and open project file in `zc706/zc706_rocketchip_ZynqRV32ConfigCow/zc706_rocketchip_ZynqRV32ConfigCow.xpr`
- important: open block design at least once.
- hit run synthesis in the flow navigator.
- open synthesized design and then Windows/Debug. Should show a list of unconnected debug elements.
- open Tools/ Set Up Debug. Delete all old debug cores first.
  Then re-open the dialogue and choose all the desired nets for debug. Assign to clock domain `FCLK_CLK0` by right clicking.
- choose high sample of data depth to enable taking long traces. (reasonable: 16k for many debug signals, otherwise 32k)
- finish wizard.
	
Synthesize the modified verilog sources (detailed [here](https://github.com/ucb-bar/fpga-zynq#bitstream)):
- in the flow navigator: "generate bitstream"
- check vivado logs, especially if timing constraints are still met!

Generate the new boot.bin; all other files (`devicetree.dtb`, `uImage`, `uramImage.image.gz`) for the SD card can usually be kept. 
- There should be a symlink in `fpga-images-zc706/boot-images` pointing to `rocketchip_wrapper.bit` in the the `impl_1` dir. This allows to simply
    ``` 
    $ cd fpga-images-zc706
    bootgen -image boot.bif -w -o boot.bin
    ``` 
Copy for later use `debug_nets.ltx` from `zc706/zc706_rocketchip_ZynqRV32Config/zc706_rocketchip_ZynqRV32Config.runs/impl_1/`

### Capturing waveforms

You can look into waveforms on the fpga now. Therefore, connect the zc706 for debugging via Micro USB to your local machine. You won't need a license to use Vivado for waveform capturing.

- Open Vivado/Hardware Manager
- In window 'Trigger Setup' configure with `debug_netlist.ltx`
- Setup trigger, eg. on `io_interrupt_msip == 1`
- Open a terminal session and run eg. the `hello.elf` binary 

After the binary has been transfered to rocket's memory, fesvr causes a MSIP interrupt. This should trigger the core to jump to the location of the bootom, usually at `0x10000`.

<a name="zephyr"></a> Zephyr RTOS
------------------

Applications to be run on a RTOS are usually statically linked with the RTOS
kernel into a single .elf binary.
Therefore, it's easy to run them using fesvr - given that your RTOS comes with a
serial driver that can talk to fesvr.
To go on builing apps using the Zephyr RTOS, check out this repo:

https://github.com/timoML/zephyr-riscv/tree/cow


<a name="all_branches"></a>  Different branches
------------------

In theory, it should be possible to use other branches of fpga-zynq to work
with a rv32 rocket core.
First, make sure that your branch includes the changes commited in fpga-zynq [0829a1](https://github.com/ucb-bar/fpga-zynq/commit/0829a12115d0d10c89091d6ca52221d98f043cdc)
and testchipip [3fe880](https://github.com/ucb-bar/testchipip/commit/3fe880689021006fb24e928dae3b117bf4b049fe). 

Additionally, you have to modify `Configs.scala` to fix a bug in the arm-rocket shared memory interface on 32 bit configurations.
Therefore, mixin the following into your configuration's cake

```scala
class WithEdgeDataBitsRV32() extends Config((site, here, up) => {
    case MemoryBusKey => up(MemoryBusKey, site).copy(beatBytes = 8)
})
```

Most lightweight rv32 configurations will want to disable virtual memory 
(`useVM=false`). Currently, this breaks the bootrom of the rocket core.
As a workaround, simply comment out the following line in common/bootrom/bootrom.S:28

```
//csrw mideleg, zero
```

and re-compile the bootrom by giving in the bootrom folder

    $ make

