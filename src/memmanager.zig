const std = @import("std");
const randomgen = @import("randomgen.zig");
const string = std.ArrayList(u8);
const allocator = std.heap.page_allocator;
const ray = @cImport({
    @cInclude("raylib.h");
    @cInclude("raygui.h");
});
const currentVersion: usize = 1;

const person = struct {
    name: []const u8,
    position: ray.Vector2,
};
const memchunk = struct {
    version: usize,
    data: []person,
};

const versionError = error {
    versionTooOld,
    versionTooNew,
    notAVersion,
};
fn handleversion(version: usize) !void {
    switch (version) {
        0 => { return versionError.versionTooOld; }, // old version error
        1 => {}, // current version
        else => { return versionError.versionTooNew; },
    }
}

pub fn loadData(memptr: *randomgen.classroom) !void {
    const file = try std.fs.cwd().openFile("resources/config.json", .{ .mode = .read_only });
    defer file.close();
    const data = try allocator.alloc(u8, (try file.stat()).size);
    defer allocator.free(data);
    try file.reader().readNoEof(data);

    const parsed = try std.json.parseFromSlice(memchunk, allocator, data, .{ .allocate = .alloc_always });
    defer parsed.deinit();
    try handleversion(parsed.value.version);
    for (parsed.value.data) |entry| {
        try memptr.put(try allocator.dupe(u8, entry.name), randomgen.desk{.oldPosition = undefined, .newPosition = entry.position});
    }
}
pub fn saveData(memptr: *randomgen.classroom) !void {
    var chunk: memchunk = undefined;
    chunk.version = currentVersion;
    chunk.data = try allocator.alloc(person, memptr.count());
    defer allocator.free(chunk.data);
    var iter = memptr.iterator();
    var index: usize = 0;
    while (iter.next()) |entry| : (index += 1) {
        chunk.data[index].name = entry.key_ptr.*;
        chunk.data[index].position = entry.value_ptr.newPosition;
    }
    const data = try std.json.stringifyAlloc(allocator, chunk, .{ .whitespace = .indent_4 });
    defer allocator.free(data);
    const file = try std.fs.cwd().openFile("resources/config.json", .{ .mode = .write_only });
    defer file.close();
    try file.writeAll(data);
}
