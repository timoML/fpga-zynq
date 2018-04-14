package zynq

import chisel3._
import freechips.rocketchip.config.{Parameters, Field}
import freechips.rocketchip.coreplex._
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.diplomacy.{LazyModule, LazyModuleImp}
import freechips.rocketchip.util.DontTouch
import testchipip._
import icenet._
import sifive.uart._
import sifive.pinctrl._
import sifive.gpio._


case object ZynqAdapterBase extends Field[BigInt]

//-------------------------------------------------------------------------
// Sifive PinGen
//-------------------------------------------------------------------------

object PinGen {
  def apply(): BasePin =  {
    val pin = new BasePin()
    pin
  }
}

class Top(implicit val p: Parameters) extends Module {
  val address = p(ZynqAdapterBase)
  val config = p(ExtIn)
  
  //val target = Module(LazyModule(new FPGAZynqTop).module)
  println("Invoking Top with CowPeripherals code.")
  val target = Module(LazyModule(new FPGAZynqTop_CowPeripherals ).module)
  
  
  val adapter = Module(LazyModule(new ZynqAdapter(address, config)).module)

  require(target.mem_axi4.size == 1)

 
 
  val io = IO(new Bundle {
    val ps_axi_slave = Flipped(adapter.axi.cloneType)
    val mem_axi = target.mem_axi4.head.cloneType

    // instead of connecting uart ports, create according IOBUF pins
    // to be wired with rocketchip_wrapper
    //val uart = target.uart.cloneType    // sifive uart block
    
    val iobuf_uart0_rxd = new IOFPin()
    val iobuf_uart0_txd = new IOFPin()
    val iobuf_uart1_rxd = new IOFPin()
    val iobuf_uart1_txd = new IOFPin()
    
  })

  io.mem_axi <> target.mem_axi4.head
  adapter.axi <> io.ps_axi_slave
  adapter.io.serial <> target.serial
  //adapter.io.bdev <> target.bdev
  //adapter.io.net <> target.net

  // translate pins to IOBUF pins
  val sys_uart = target.uart
  val uart_pins = target.outer.uartParams.map { c => Wire(new UARTPins(() => PinGen()))}

  val reset_bool = reset.toBool()
  (uart_pins zip  sys_uart) map {case (p, r) => UARTPinsFromPort(p, r, clock = clock, reset = reset_bool, syncStages = 0)}

  // connect rocket uart_pins to top level iobufs
  // UART0
  BasePinToIOF(uart_pins(0).rxd, io.iobuf_uart0_rxd)
  BasePinToIOF(uart_pins(0).txd, io.iobuf_uart0_txd)
  // UART1
  BasePinToIOF(uart_pins(1).rxd, io.iobuf_uart1_rxd)
  BasePinToIOF(uart_pins(1).txd, io.iobuf_uart1_txd)

  target.debug := DontCare
  target.tieOffInterrupts()
  //target.dontTouchPorts()
  target.reset := adapter.io.sys_reset
}

class FPGAZynqTop(implicit p: Parameters) extends RocketCoreplex
    with HasMasterAXI4MemPort
    with HasSystemErrorSlave
    with HasPeripheryBootROM
    with HasSyncExtInterrupts
    with HasNoDebug
    with HasPeripherySerial
    //with HasPeripheryBlockDevice
    //with HasPeripheryIceNIC 
    {
  override lazy val module = new FPGAZynqTopModule(this)
}

class FPGAZynqTopModule(outer: FPGAZynqTop) extends RocketCoreplexModule(outer)
    with HasRTCModuleImp
    with HasMasterAXI4MemPortModuleImp
    with HasPeripheryBootROMModuleImp
    with HasExtInterruptsModuleImp
    with HasNoDebugModuleImp
    with HasPeripherySerialModuleImp
    //with HasPeripheryBlockDeviceModuleImp
    //with HasPeripheryIceNICModuleImp
    //with DontTouch


/**
  Invoke in TestHarness.scala and here::Top
**/
class FPGAZynqTop_CowPeripherals(implicit p: Parameters) extends RocketCoreplex
    with HasMasterAXI4MemPort
    with HasSystemErrorSlave
    with HasPeripheryBootROM
    with HasSyncExtInterrupts
    with HasNoDebug
    with HasPeripherySerial
    //with HasPeripheryBlockDevice
    with HasPeripheryIRQPeripheral  
    with HasPeripheryUART
    //with HasPeripheryIceNIC
 {
  override lazy val module = new FPGAZynqTopModule_CowPeripherals(this)
}

class FPGAZynqTopModule_CowPeripherals(outer: FPGAZynqTop_CowPeripherals) extends RocketCoreplexModule(outer)
    with HasRTCModuleImp
    with HasMasterAXI4MemPortModuleImp
    with HasPeripheryBootROMModuleImp
    with HasExtInterruptsModuleImp
    with HasNoDebugModuleImp
    with HasPeripherySerialModuleImp
    //with HasPeripheryBlockDeviceModuleImp
    //with HasPeripheryIceNICModuleImp
    with HasPeripheryIRQPeripheralModuleImp 
    with HasPeripheryUARTModuleImp
    //with DontTouch
