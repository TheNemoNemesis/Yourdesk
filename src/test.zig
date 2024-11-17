const std = @import("std");
const randomgen = @import("randomgen.zig");
const gui = @import("gui.zig");

test "quicksort" {
    var gen = try randomgen.generator.init();
    defer gen.deinit();
    var list: [5]randomgen.probdesk = .{
        randomgen.probdesk{.force = 10, .nameid = 0, .deskid = 0},
        randomgen.probdesk{.force = 8, .nameid = 0, .deskid = 0},
        randomgen.probdesk{.force = 1, .nameid = 0, .deskid = 0},
        randomgen.probdesk{.force = 14, .nameid = 0, .deskid = 0},
        randomgen.probdesk{.force = 22, .nameid = 0, .deskid = 0},
    };
    randomgen.generator.reversequicksort(list[0..]);
    try std.testing.expectEqual(.{
        randomgen.probdesk{.force = 22, .nameid = 0, .deskid = 0},
        randomgen.probdesk{.force = 14, .nameid = 0, .deskid = 0},
        randomgen.probdesk{.force = 10, .nameid = 0, .deskid = 0},
        randomgen.probdesk{.force = 8, .nameid = 0, .deskid = 0},
        randomgen.probdesk{.force = 1, .nameid = 0, .deskid = 0},
    }, list);
}
