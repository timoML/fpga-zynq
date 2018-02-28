/**
WARNING: 
- KEEP IN SYNC WITH VERSION IN SIFIVE ARTY FREEOM VERSION OF ROCKET
- HasAsyncExtInterrupts fails requirement in diplomacy/Nodes.scala::504, introduced in e489c4226e67b1d3
-> now HasSyncExtInterrupts, effects still untested
*/

package zynq


import chisel3._
import chisel3.util._
import freechips.rocketchip.coreplex.HasPeripheryBus
import freechips.rocketchip.coreplex.{HasAsyncExtInterrupts, HasSyncExtInterrupts}
import freechips.rocketchip.config.{Parameters, Field}
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.regmapper.{HasRegMap, RegField}
import freechips.rocketchip.tilelink._
import freechips.rocketchip.util.UIntIsOneOf




// Class derived from ucbbar/project-template 
case class IRQPeripheralParams(address: BigInt, beatBytes: Int)

class IRQPeripheralBase(w: Int) extends Module {
  // w: 
  val io = IO(new Bundle {
    /** Global Input for all DPSs */
    val enable = Input(Bool())

    /** DSP Block IRQ0 */
    /** Input */ 
    val value_0 = Input(UInt(w.W))  
    val fire_0 = Input(Bool())

    /** Output */ 
    val irqout_0 = Output(Bool())
    val status_0 = Output(UInt(w.W)) // 0: idle, 1: irq fired, dev now blocked
    val perval_0 = Output(UInt(w.W)) // peripheral value, output

    /** DSP Block IRQ1_SM_RESET */
    /** Input */ 
    val fire_1 = Input(Bool()) // must be reset by software asap
    val period_1 = Input(UInt(w.W))
    val num_rep_1 = Input(UInt(w.W))
    val clear_1 = Input(Bool()) // must be reset by software asap
    /** Output */ 
    val irqout_1 = Output(Bool())
    val status_1 = Output(UInt(w.W))
 
    /** DSP Block IRQ2_VAL_UPDATE_1 */
    /** Input */ 
    val fire_2 = Input(Bool())
    val period_2 = Input(UInt(w.W))
    val num_rep_2 = Input(UInt(w.W))
    val clear_2 = Input(Bool())
    /** Output */ 
    val irqout_2 = Output(Bool())
    val status_2 = Output(UInt(w.W))

    /** DSP Block DSP3 */
    /** Input */ 
    val value_3 = Input(UInt(w.W))  
    val delay_3 = Input(UInt(w.W))
    val period_3 = Input(UInt(w.W))
    val duty_3 = Input(UInt(w.W))
    val num_rep_3 = Input(UInt(w.W))
    val clear_id_3 = Input(UInt(w.W))
    val reset_3 = Input(Bool())
    /** Output */ 
    val perval_3 = Output(UInt(w.W)) // peripheral value, output
    val status_3 = Output(UInt(w.W))
    val id_counter_3 = Output(UInt(w.W))
    val ready_3 = Output(Bool())
    
 
  })

  /** DSP Block IRQ0 */
  /** Logic */
  // counting register if fire set, such that output irqout_0 is fire only once 
  val block_counter_0 = RegInit(0.U(2.W))

  // only ouput irq once
  // count if fire_0 set
  when(~io.fire_0){
    // reset
    block_counter_0 := 0.U
  }.elsewhen(io.fire_0 && (block_counter_0 < 2.U)){ 
    // block when reaching 2 and wait for reset 
    block_counter_0 := block_counter_0 + 1.U
  }

  io.irqout_0 := io.enable && (block_counter_0 === 1.U)
  io.status_0 := block_counter_0    // debug

  when(io.enable){
    io.perval_0 := io.value_0
  }. otherwise{
    io.perval_0 := 0.U
  }
  // old, more compilicated status
  //when(block_counter_0 === 2.U){
   //   io.status_0 := 1.U
  //}.otherwise{
  //    io.status_0 := 0.U
  //}

  /** DSP Block IRQ1_SM_RESET */
  /** Logic */

  // counting register for irq_1
  // works pwm-like (duty=1): fire output once if period reached
  val counter_1 = RegInit(0.U(w.W))
  val counter_reps_1 = RegInit(0.U(w.W))
  // to store status of clear input
  val clear_reg_1 = RegInit(false.B)
  // to store if fire was given
  val fire_reg_1 = RegInit(false.B)
  // count of missed clears in time
  val num_missed_1 = RegInit(0.U(w.W))
  
  io.status_1 := num_missed_1 // no error


  when(fire_reg_1 && (counter_1 >= (io.period_1 - 1.U))) {
    // END of 1 repetition of counting
    counter_1 := 0.U  // NOW is fired (if all other conditions true)

    // count num of repetitions if limit not yet reached
    when(counter_reps_1 < io.num_rep_1){
      // END of 1 repetition with firing
      counter_reps_1 := counter_reps_1 + 1.U

      // increase number of errors, if clear hasn't been received in time
      when(~clear_reg_1){
        num_missed_1 := num_missed_1 + 1.U
      }.otherwise{  
        // reset for next repetition with firing
        clear_reg_1 := false.B
      }

    }.elsewhen(counter_reps_1 >= io.num_rep_1){
      // END of all repetitions
      // max(counter_reps_1) == io.num_rep_1
      // reset fire_reg
      fire_reg_1 := false.B
      // reset repetition number
      // breaks counter_reps cycle, because fire_reg is also reset 
      counter_reps_1 := 0.U
  
    }


  }.elsewhen(fire_reg_1) {
    counter_1 := counter_1 + 1.U
  }

  // set clear register for current repetition
  when(io.clear_1){
    clear_reg_1 := true.B
  } // reset for reg is done at END of 1 repetition with fire

  // set fire register for current repetition
  when(io.fire_1){
    fire_reg_1 := true.B
  } // reset for reg is done at END of all period

  // fire once in counter cycle, only if number of repetitions not reached yets
  io.irqout_1 := io.enable && 
                (counter_1 < 1.U) && fire_reg_1 && 
                (counter_reps_1 < io.num_rep_1)
  
  
  /** DSP Block IRQ2_UPDATE_VAL */
  /** Logic */
  // Duplicate of IRQ1
  // counting register for irq_2
  // works pwm-like (duty=1): fire output once if period reached
  val counter_2 = RegInit(0.U(w.W))
  val counter_reps_2 = RegInit(0.U(w.W))
  // to store status of clear input
  val clear_reg_2 = RegInit(false.B)
  // to store if fire was given
  val fire_reg_2 = RegInit(false.B)
  // count of missed clears in time
  val num_missed_2 = RegInit(0.U(w.W))
  
  io.status_2 := num_missed_2 // no error

  when(counter_2 >= (io.period_2 - 1.U)) {
    // END of 1 repetition of counting

    // count num of repetitions if limit not yet reached
    when((counter_reps_2 < io.num_rep_2) && fire_reg_2){
      // END of 1 repetition with firing
      counter_reps_2 := counter_reps_2 + 1.U

      // increase number of errors, if clear hasn't been received in time
      when(~clear_reg_2){
        num_missed_2 := num_missed_2 + 1.U
      }.otherwise{  
        // reset for next repetition with firing
        clear_reg_2 := false.B
      }

    }.elsewhen(counter_reps_2 >= io.num_rep_2){
      // END of all repetitions
      // max(counter_reps_2) == io.num_rep_2
      // reset fire_reg
      fire_reg_2 := false.B
      // reset repetition number
      // breaks counter_reps cycle, because fire_reg is also reset 
      counter_reps_2 := 0.U
  
    }

    counter_2 := 0.U

  }.elsewhen(fire_reg_2) {
    counter_2 := counter_2 + 1.U
  }

  // set clear register for current repetition
  when(io.clear_2){
    clear_reg_2 := true.B
  } // reset for reg is done at END of 1 repetition with fire

  // set fire register for current repetition
  when(io.fire_2){
    fire_reg_2 := true.B
  } // reset for reg is done at END of all period

  // fire once in counter cycle, only if number of repetitions not reached yets
  io.irqout_2 := io.enable && 
                (counter_2 < 1.U) && fire_reg_2 && 
                (counter_reps_2 < io.num_rep_2)

  /** DSP Block DSP3_POLL_VAL */
  /** Logic */
  when(io.enable){
    io.perval_3 := io.value_3
  }.otherwise{
    io.perval_3 := 0.U
  }

  // counting register for dsp_3
  // works pwm-like (duty=1): fire output once if period reached
  val counter_3 = RegInit(0.U(w.W))
  // count down delay from fire_2 after which DSP3 starts 
  val counter_delay_3 = RegInit(0.U(w.W))
  val counter_reps_3 = RegInit(0.U(w.W))

  // to store if fire was given
  val fire_reg_3 = RegInit(false.B)
  // count of missed clears in time
  val num_missed_3 = RegInit(0.U(w.W))
  
  io.status_3 := num_missed_3 // no error
  io.id_counter_3 := counter_reps_3

  when(fire_reg_1 && counter_delay_3 >= (io.delay_3 - 1.U)){  
     counter_delay_3 := 0.U // reset delay counter
     when(counter_reps_3 <= io.num_rep_3 && io.delay_3 > 0.U){   // stop if fire_3 limit already reached, but still fire_reg_1
        // do nothing for delay_3 == 0
        fire_reg_3 := true.B   // dsp3 firing start, reset done at END of all period 
	counter_reps_3 := 1.U  // clear_id 0 is reserved, first clear_id is 1
	}  
  }.elsewhen(fire_reg_1){
     counter_delay_3 := counter_delay_3 + 1.U
  }


  when(fire_reg_3 && (counter_3 >= (io.period_3 - 1.U))) {
    // END of 1 repetition of counting
    counter_3 := 0.U  // NOW is fired (if all other conditions true)

    // count num of repetitions if limit not yet reached
    when(counter_reps_3 <= io.num_rep_3){
      // END of 1 repetition with firing
      counter_reps_3 := counter_reps_3 + 1.U

      // increase number of errors, if clear hasn't been received in time
      when(~(io.clear_id_3 === counter_reps_3)){   
         num_missed_3 := num_missed_3 + 1.U
      }

     
      

    }.elsewhen(counter_reps_3 > io.num_rep_3){
      // END of all repetitions
      // max(counter_reps_1) == io.num_rep_1
      // reset fire_reg
      fire_reg_3 := false.B
      // reset repetition number
      // breaks counter_reps cycle, because fire_reg is also reset 
      counter_reps_3 := 0.U
  
    }


  }.elsewhen(fire_reg_3) {
    // "PWM" like counter, only if firing 
    counter_3 := counter_3 + 1.U
  }

  io.ready_3 := io.enable && 
                (counter_3 < io.duty_3) && fire_reg_3 && 
                (counter_reps_3 <= io.num_rep_3)
  
  when(io.reset_3){
     num_missed_3 := 0.U // resets status
     counter_reps_3 := 0.U
     counter_3 := 0.U
     fire_reg_3 := false.B
  }
 

}

trait IRQPeripheralTLBundle extends Bundle {
  def params: IRQPeripheralParams
  val w = params.beatBytes * 8  // what is beatbytes? RV32 vs RV64?

  /** DSP Block IRQ0 */
  val irqout_0 = Output(Bool())
  val perval_0 = Output(UInt(w.W))
  val status_0 = Output(UInt(w.W))

  /** DSP Block IRQ1 */
  val irqout_1 = Output(Bool())
  val status_1 = Output(UInt(w.W))

  /** DSP Block IRQ2 */
  val irqout_2 = Output(Bool())
  val status_2 = Output(UInt(w.W))

  /** DSP Block DSP3 */
  val perval_3 = Output(UInt(w.W))
  val status_3 = Output(UInt(w.W))
  val id_counter_3 = Output(UInt(w.W))
  val ready_3 = Output(Bool())
}

// define all required input and output registers which need to register to TL
// no logic here
trait IRQPeripheralTLModule extends HasRegMap {
  val io: IRQPeripheralTLBundle
  implicit val p: Parameters
  def params: IRQPeripheralParams

  val w = params.beatBytes * 8  // what is beatbytes? RV32 vs RV64?
  require(w <= 32)

  /** DSP Block IRQ0 */
  // Inputs
  // Signal to fire_0 IRQ and reset blocked device
  val fire_0 = RegInit(false.B)
  //val fire_rst = RegInit(false.B)
  // input for memory to be readout by ISR
  val value_0 = Reg(UInt(w.W))
  // Is the IRQPeripheral even running at all?
  val enable = RegInit(false.B)
  
  // Outputs
  val status_0 = Reg(UInt(w.W)) // 0: idle, 1: irq fired, dev now blocked
  // Memory to be readout by ISR
  val perval_0 = Reg(UInt(w.W))

  /** DSP Block IRQ1 */
  // Input
  val fire_1 = RegInit(false.B) 
  val period_1 = Reg(UInt(w.W))
  val num_rep_1 = Reg(UInt(w.W))
  val clear_1 =  RegInit(false.B) 
  // Output
  val status_1 = Reg(UInt(w.W))


  /** DSP Block IRQ2 */
  // Input
  val fire_2 = RegInit(false.B) 
  val period_2 = Reg(UInt(w.W))
  val num_rep_2 = Reg(UInt(w.W))
  val clear_2 =  RegInit(false.B) 
  // Output
  val status_2 = Reg(UInt(w.W))
  
  /** DSP Block IRQ3 */
  // Input
  val period_3 = Reg(UInt(w.W))
  val duty_3 = Reg(UInt(w.W))
  val num_rep_3 = Reg(UInt(w.W))
  val delay_3 = Reg(UInt(w.W))
  val value_3 = Reg(UInt(w.W))
  val clear_id_3 = Reg(UInt(w.W))
  val reset_3 =  RegInit(false.B) 
  // Output
  val status_3 = Reg(UInt(w.W)) 
  val perval_3 = Reg(UInt(w.W))
  val id_counter_3 = Reg(UInt(w.W))
  val ready_3 = RegInit(false.B) 


  val base = Module(new IRQPeripheralBase(w))
  // TL connected to device (base) in/outputs
  // input: regs right
  // outputs: regs left
  /** DSP Block IRQ0 */
  perval_0 := base.io.perval_0 
  status_0 := base.io.status_0
  base.io.value_0 := value_0
  base.io.enable := enable
  base.io.fire_0 := fire_0 

  /** DSP Block IRQ1 */
  status_1 := base.io.status_1
  base.io.fire_1 := fire_1
  base.io.period_1 := period_1
  base.io.num_rep_1 := num_rep_1 
  base.io.clear_1 := clear_1 

  /** DSP Block IRQ2 */
  status_2 := base.io.status_2
  base.io.fire_2 := fire_2
  base.io.period_2 := period_2
  base.io.num_rep_2 := num_rep_2 
  base.io.clear_2 := clear_2 

  /** DSP Block DSP3 */
  status_3 := base.io.status_3
  perval_3 := base.io.perval_3
  id_counter_3 := base.io.id_counter_3
  ready_3 := base.io.ready_3
  base.io.period_3 := period_3
  base.io.duty_3 := duty_3
  base.io.num_rep_3 := num_rep_3
  base.io.delay_3 := delay_3
  base.io.value_3 := value_3
  base.io.clear_id_3 := clear_id_3
  base.io.reset_3 := reset_3
  

  
  // registers to drive io regmap
  // one register address [0x0-0x1) byte = bits [0-8). At least 1 byte.
  // mind alignment (-> do w wide values first)
  regmap(   
    0x00 -> Seq(
      RegField(w, value_0)),
    0x04 -> Seq(
      RegField(w, perval_0)),
    0x08 -> Seq(
      RegField(w, status_0)),
    0x0C -> Seq(
      RegField(1, fire_0)),
    0x0D -> Seq(
      RegField(1, enable)),  
    // ends at byte [13-14), bits [104-112)
    // align to next word (rv32: 32 bit wide), [128-
    0x10 -> Seq(
      RegField(w, period_1)),
    0x14 -> Seq(
      RegField(w, num_rep_1)),
    0x18 -> Seq(
      RegField(w, status_1)),
    0x1C -> Seq(
      RegField(1, clear_1)),
    0x1D -> Seq(
      RegField(1, fire_1)),
    // align to next word
    0x20 -> Seq(
      RegField(w, period_2)),
    0x24 -> Seq(
      RegField(w, num_rep_2)),
    0x28 -> Seq(
      RegField(w, status_2)),
    0x2C -> Seq(
      RegField(1, clear_2)),
    0x2D -> Seq(
      RegField(1, fire_2)),
    // align to next word
    0x30 -> Seq(
      RegField(w, period_3)),
    0x34 -> Seq(
      RegField(w, duty_3)),
    0x38 -> Seq(
      RegField(w, num_rep_3)),
    0x3C -> Seq(
      RegField(w, delay_3)),
    0x40 -> Seq(
      RegField(w, value_3)),
    0x44 -> Seq(
      RegField(w, clear_id_3)),
    0x48 -> Seq(
      RegField(w, status_3)), 
    0x4C -> Seq(
      RegField(w, perval_3)),
    0x50 -> Seq(
      RegField(w, id_counter_3)),
    0x54 -> Seq(
      RegField(1, reset_3)),
    0x55 -> Seq(
      RegField(1, ready_3))
  )

  interrupts(0) := base.io.irqout_0
  interrupts(1) := base.io.irqout_1
  interrupts(2) := base.io.irqout_2

}

class IRQPeripheralTL(c: IRQPeripheralParams)(implicit p: Parameters)
  extends TLRegisterRouter(
    c.address, "IRQPeripheral", Seq("ucbbar,IRQPeripheral"),
    beatBytes = c.beatBytes, interrupts = 3)(
      new TLRegBundle(c, _) with IRQPeripheralTLBundle)(
      new TLRegModule(c, _, _) with IRQPeripheralTLModule)

// Lazy module trait for setup
// this connect to the TL for MMIO (-> device tree) and to the interrupt bus
// todo: can this.node be connected to ibus AND pbus?
// only output must be connected to interrupt bus, maybe only in implementation
trait HasPeripheryIRQPeripheral extends HasPeripheryBus with HasSyncExtInterrupts{
  implicit val p: Parameters

  private val address = 0x2000    // can this be static?

  val irqperipheral = LazyModule(new IRQPeripheralTL(
    IRQPeripheralParams(address, pbus.beatBytes))(p))

  // ibus / pbus defined in rocket/coreplex/
  // connect to pbus, node inherited from TLRegisterRouter
  irqperipheral.node := pbus.toVariableWidthSlaves

  // connect to ibus
  ibus.fromSync := irqperipheral.intnode

}



// implementation, instantiate IRQPeripheral module and connect output to SoC
trait HasPeripheryIRQPeripheralModuleImp extends LazyModuleImp{
  implicit val p: Parameters
  val outer: HasPeripheryIRQPeripheral

  // todo: fix parameter passing for w
  //def params: IRQPeripheralParams
  val w = 32 //params.beatBytes * 8 

  val irqout_0 = IO(Output(Bool()))
  val perval_0 = IO(Output(UInt(w.W)))
  val status_0 = IO(Output(UInt(w.W)))

  val irqout_1 = IO(Output(Bool()))
  val status_1 = IO(Output(UInt(w.W)))

  val irqout_2 = IO(Output(Bool()))
  val status_2 = IO(Output(UInt(w.W)))

}

