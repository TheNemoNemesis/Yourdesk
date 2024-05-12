const std = @import("std");
const string = std.ArrayList(u8);
const calloc = std.heap.c_allocator;
const currentVersion: usize = 0;

const datachunk = struct {
    sizex: usize,
    sizey: usize,
    grid: [][]u8,
};
const memchunk = struct {
    version: usize,
    data: datachunk,
};

fn handleversion(version: usize) void {
    _ = version; // autofix
    return;
}

pub fn loadData(memptr: *([]string), sizex: *usize, sizey: *usize) !void {
    const file = try std.fs.cwd().openFile("resources/config.json", .{ .mode = .read_only });
    defer file.close();
    const data = try calloc.alloc(u8, (try file.stat()).size);
    defer calloc.free(data);
    try file.reader().readNoEof(data);

    // TODO: handle old versions
    const parsed = try std.json.parseFromSlice(memchunk, calloc, data, .{ .allocate = .alloc_always });
    defer parsed.deinit();
    const chunk: memchunk = parsed.value;
    sizex.* = chunk.data.sizex;
    sizey.* = chunk.data.sizey;
    memptr.* = try calloc.alloc(string, chunk.data.grid.len);

    // parse data to current version config
    for (chunk.data.grid, 0..) |list, index| {
        memptr.*[index] = string.init(calloc);
        try memptr.*[index].appendSlice(list);
    }
}
pub fn saveData(memptr: []string, sizex: usize, sizey: usize) !void {
    var chunk: memchunk = undefined;
    chunk.data.grid = try calloc.alloc([]u8, memptr.len);
    defer calloc.free(chunk.data.grid);
    for (memptr, 0..) |list, index| {
        chunk.data.grid[index] = list.items;
    }
    chunk.data.sizex = sizex;
    chunk.data.sizey = sizey;
    chunk.version = currentVersion;

    const data = try std.json.stringifyAlloc(calloc, chunk, .{ .whitespace = .indent_4 });
    defer calloc.free(data);
    const file = try std.fs.cwd().openFile("resources/config.json", .{ .mode = .write_only });
    defer file.close();
    _ = try file.write(data);
}
