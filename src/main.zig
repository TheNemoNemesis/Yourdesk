const std = @import("std");
const randomgen = @import("randomgen.zig");
const gui = @import("gui.zig");
const memmanager = @import("memmanager.zig");

pub fn main() !void {
    var gen = try randomgen.generator.init();
    defer gen.deinit();
    try memmanager.loadData(&gen.class);
    var ui = gui.gui.init();
    defer ui.deinit();
    try ui.run(&gen);
    try memmanager.saveData(&gen.class);
}

// pub fn main() !void {
//     var gen: randomgen.generator = undefined;
//     var sx: usize = undefined;
//     var sy: usize = undefined;
//     var ui: gui.gui = undefined;
//     try memmanager.loadData(&ui.displaygrid, &sx, &sy);
//     try gen.init(sx * sy, sx, sy);
//     defer gen.deinit();
//
//     for (ui.displaygrid, 0..) |entry, index| {
//         gen.grid[index].name = try entry.clone();
//         gen.grid[index].gridpos = index;
//     }
//
//     // Display
//     std.debug.print("Starting disposition:\n", .{});
//     for (0..gen.sy) |y| {
//         std.debug.print("|", .{});
//         for (0..gen.sx) |x| {
//             std.debug.print(" {s} |", .{if (!std.mem.eql(u8, ui.displaygrid[((y * gen.sx) + x)].items, "")) ui.displaygrid[((y * gen.sx) + x)].items else "          "});
//         }
//         std.debug.print("\n", .{});
//     }
//     std.debug.print("\n\n", .{});
//
//     try gen.findlocked();
//     try gen.generate();
//     try ui.compose(gen.grid);
//
//     // Display
//     std.debug.print("Generated disposition:\n", .{});
//     for (0..gen.sy) |y| {
//         std.debug.print("|", .{});
//         for (0..gen.sx) |x| {
//             std.debug.print(" {s} |", .{if (!std.mem.eql(u8, ui.displaygrid[((y * gen.sx) + x)].items, "")) ui.displaygrid[((y * gen.sx) + x)].items else "          "});
//         }
//         std.debug.print("\n", .{});
//     }
//     try memmanager.saveData(ui.displaygrid, sx, sy);
// }
