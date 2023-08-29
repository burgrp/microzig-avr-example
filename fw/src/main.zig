const microzig = @import("microzig");

const peripherals = microzig.chip.peripherals;
//const peripherals = @import("../deps/microzig-avr/src/chips/ATtiny412.zig").devices.ATtiny412.peripherals;

// ATtiny412 datasheet:
// https://ww1.microchip.com/downloads/aemDocuments/documents/MCU08/ProductDocuments/DataSheets/ATtiny212-214-412-414-416-DataSheet-DS40002287A.pdf

pub const microzig_options = struct {
    pub const interrupts = struct {
        pub fn TCA0_LUNF() void {
            peripherals.PORTA.OUTTGL = 1 << 1;
            peripherals.TCA0.SINGLE.INTFLAGS.modify(.{ .OVF = 1 });
        }
    };
};

pub fn main() void {

    // CPU at 10MHz
    peripherals.CPU.CCP.write_raw(0xD8);
    peripherals.CLKCTRL.MCLKCTRLB.modify(.{ .PDIV = .{ .value = .@"2X" } });

    microzig.cpu.enable_interrupts();

    peripherals.PORTA.DIRSET = 1 << 1;

    peripherals.TCA0.SINGLE.INTCTRL.modify(.{ .OVF = 1 });
    peripherals.TCA0.SINGLE.PER = @floatToInt(u16, 10E6 / 256.0 / 2.0);
    peripherals.TCA0.SINGLE.CTRLA.modify(.{ .ENABLE = 1, .CLKSEL = .{ .value = .DIV256 } });

    peripherals.SLPCTRL.CTRLA.modify(.{ .SMODE = .{ .value = .IDLE }, .SEN = 1 });
    while (true) {
        asm volatile ("sleep");
    }
}
