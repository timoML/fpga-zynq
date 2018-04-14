package zynq

import chisel3._
import freechips.rocketchip.config.{Parameters, Config}
import freechips.rocketchip.coreplex._
import freechips.rocketchip.devices.tilelink.BootROMParams
import freechips.rocketchip.rocket.{RocketCoreParams, MulDivParams, DCacheParams, ICacheParams}
import freechips.rocketchip.system.{BaseConfig, DefaultRV32Config, TinyRV32Config}
import freechips.rocketchip.tile.{RocketTileParams, BuildCore, XLen}
import icenet.{NICKey, NICConfig}
import testchipip._

import sifive.uart._

class WithBootROM extends Config((site, here, up) => {
  case BootROMParams => BootROMParams(
    contentFileName = s"./bootrom/bootrom.rv${site(XLen)}.img")
})

class WithZynqAdapter extends Config((site, here, up) => {
  case SerialFIFODepth => 16
  case ResetCycles => 10
  case ZynqAdapterBase => BigInt(0x43C00000L)
  case ExtMem => up(ExtMem, site).copy(idBits = 6)
  case ExtIn => up(ExtIn, site).copy(beatBytes = 4, idBits = 12)
  case BlockDeviceKey => BlockDeviceConfig(nTrackers = 0) //BlockDeviceConfig(nTrackers = 2)
  //case BlockDeviceFIFODepth => 16
  //case NetworkFIFODepth => 16
  //case NICKey => NICConfig()
})

class WithNMediumCores(n: Int) extends Config((site, here, up) => {
  case RocketTilesKey => {
    val medium = RocketTileParams(
      core = RocketCoreParams(mulDiv = Some(MulDivParams(
        mulUnroll = 8,
        mulEarlyOut = true,
        divEarlyOut = true)),
        fpu = None),
      dcache = Some(DCacheParams(
        rowBits = site(SystemBusKey).beatBytes*8,
        nSets = 64,
        nWays = 1,
        nTLBEntries = 4,
        nMSHRs = 0,
        blockBytes = site(CacheBlockBytes))),
      icache = Some(ICacheParams(
        rowBits = site(SystemBusKey).beatBytes*8,
        nSets = 64,
        nWays = 1,
        nTLBEntries = 4,
        blockBytes = site(CacheBlockBytes))))
    List.fill(n)(medium) ++ up(RocketTilesKey, site)
  }
})


class WithNCustom32Cores(n: Int) extends Config((site, here, up) => {
  case XLen => 32
  //case MemoryBusKey =>  MemoryBusParams(beatBytes = 8, blockBytes = site(CacheBlockBytes))  // interface to arm must stay 64bit
  case RocketTilesKey => {
    val big = RocketTileParams(
      core   = RocketCoreParams(
        nPerfCounters = 2, // to read eg. cache misses
        useVM = false,      // must be false to allow scratchpad
        mulDiv = Some(MulDivParams(
          mulUnroll = 8,
          mulEarlyOut = true,
          divEarlyOut = true))),
      btb = None,     // no dynamic branch prediction 
      dcache = Some(DCacheParams(
        rowBits = site(SystemBusKey).beatBits,
        nSets = 1024, 
        nWays = 1,
        nTLBEntries = 4,
        nMSHRs = 0,
        blockBytes = site(CacheBlockBytes), //)),
        scratch = Some(0x20000000L) )),
      icache = Some(ICacheParams(
        rowBits = site(SystemBusKey).beatBits,
        nSets = 1024, //1024
        nWays = 4,        
        nTLBEntries = 4,
        blockBytes = site(CacheBlockBytes) )))
    List.tabulate(n)(i => big.copy(hartId = i))
  } 
})

// memory bus needs same width as zynq arm S_AXI for correct access
class WithEdgeDataBitsRV32() extends Config((site, here, up) => {
  case MemoryBusKey => up(MemoryBusKey, site).copy(beatBytes = 8)
  
})

class WithSifivePeriphery() extends Config((site, here, up) => {
  case PeripheryUARTKey => List(
    UARTParams(address = 0x10013000),
    UARTParams(address = 0x10023000))
})

class DefaultConfig extends Config(
  new WithBootROM ++ new freechips.rocketchip.system.DefaultConfig)
class DefaultMediumConfig extends Config(
  new WithBootROM ++ new WithNMediumCores(1) ++
  new freechips.rocketchip.system.BaseConfig)
class DefaultSmallConfig extends Config(
  new WithBootROM ++ new freechips.rocketchip.system.DefaultSmallConfig)

class ZynqConfig extends Config(new WithZynqAdapter ++ new DefaultConfig)
// change WithNBigCore to useVM=false in coreplex.config.scala
class ZynqConfigNoVM extends Config(new WithZynqAdapter ++ new DefaultConfig)

// TinyRV32Config not working, address conflict around 0x80000000??
// This ZynqRV32Config is tested and working!
class ZynqRV32Config extends Config(new WithEdgeDataBitsRV32  ++ new WithZynqAdapter ++ new WithBootROM ++ new DefaultRV32Config) 
// use with peripherals invoked in Top
class ZynqRV32ConfigCow extends Config(new WithEdgeDataBitsRV32 ++ new WithZynqAdapter ++ new WithBootROM ++ 
  new WithNCustom32Cores(1) ++ new WithSifivePeriphery ++
  new freechips.rocketchip.coreplex.WithRV32 ++ new freechips.rocketchip.system.BaseConfig) 

class ZynqMediumConfig extends Config(new WithZynqAdapter ++ new DefaultMediumConfig)
class ZynqSmallConfig extends Config(new WithZynqAdapter ++ new DefaultSmallConfig)

class ZynqFPGAConfig extends Config(new WithoutTLMonitors ++ new ZynqConfig)
class ZynqMediumFPGAConfig extends Config(new WithoutTLMonitors ++ new ZynqMediumConfig)
class ZynqSmallFPGAConfig extends Config(new WithoutTLMonitors ++ new ZynqSmallConfig)
