const std = @import("std");
const c_alloc = std.heap.c_allocator;
const string = std.ArrayList(u8);
const math = std.math;
const swap = std.mem.swap;

var max: u64 = 0;
var ro: f64 = 0;

// random
var prng: std.rand.DefaultPrng = undefined;
var rand: std.Random = undefined;
extern "C" fn generatenumber() c_ulonglong;

const vec2 = struct {
    x: usize,
    y: usize,
};
pub fn inSlice(haystack: []const vec2, needle: vec2) bool {
    for (haystack) |thing| {
        if ((thing.x == needle.x) and (thing.y == needle.y)) {
            return true;
        }
    }
    return false;
}

pub const position = struct {
    pos: usize,
    gridpos: usize,
    force: u128,
    active: bool,
};

pub const person = struct {
    name: string,
    gridpos: usize,

    pub fn init(self: *person) !void {
        self.name = string.init(c_alloc);
    }
    pub fn deinit(self: *person) void {
        self.name.deinit();
    }
};

pub const generator = struct {
    grid: []person,
    bufgrid: []position,
    locked: []vec2,
    sx: usize,
    sy: usize,

    pub fn init(self: *generator, size: usize, sizex: usize, sizey: usize) !void {
        prng = std.rand.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            try std.posix.getrandom(std.mem.asBytes(&seed));
            break :blk seed;
        });
        rand = prng.random();
        self.grid = try c_alloc.alloc(person, size);
        for (self.grid) |*e| {
            try e.init();
        }
        self.bufgrid = try c_alloc.alloc(position, size * size);
        self.sx = sizex;
        self.sy = sizey;
        self.locked.len = 0;
        max = if (sizex < sizey) sizey else sizex;
        ro = 1.0 / (@as(f64, @floatFromInt(max)) * math.sqrt(2 * math.pi));
    }
    pub fn deinit(self: *generator) void {
        for (self.grid) |*e| {
            e.deinit();
        }
        c_alloc.free(self.grid);
        c_alloc.free(self.bufgrid);
        if (self.locked.len > 0) {
            c_alloc.free(self.locked);
        }
    }

    pub fn resizegrid(self: *generator, size: usize, sizex: usize, sizey: usize, lkd: []vec2) !void {
        // TODO: fix deinit if newsize < oldisize
        if (self.grid.len > size) {
            for (size..self.grid.len) |index| {
                self.grid[index].deinit();
            }
        }
        const oldlen = self.grid.len;
        try c_alloc.realloc(self.grid, size);
        try c_alloc.realloc(self.bufgrid, size * size);
        // TODO: fix init if newsize > oldisize
        if (oldlen < size) {
            for (oldlen..size) |index| {
                self.grid[index].init();
            }
        }
        self.sx = sizex;
        self.sy = sizey;
        self.locked = lkd;
        max = if (sizex < sizey) sizey else sizex;
        ro = 1.0 / (@as(f64, @floatFromInt(max)) * math.sqrt(2 * math.pi));
    }
    pub fn findlocked(self: *generator) !void {
        var lockedbuf = std.ArrayList(vec2).init(c_alloc);
        for (self.grid) |entry| {
            if (std.mem.eql(u8, entry.name.items, "")) {
                try lockedbuf.append(vec2{ .x = (entry.gridpos % self.sx), .y = (entry.gridpos / self.sx) });
            }
        }
        if (lockedbuf.items.len > 0) {
            self.locked = lockedbuf.items;
        }
    }

    pub fn generate(self: *generator) !void {
        self.genmap();
        self.collide();
    }
    fn reversequicksort(list: []position) void {
        if (list.len < 2) {
            return;
        } else if (list.len == 2) {
            if (list[0].force <= list[1].force) {
                swap(position, &list[0], &list[1]);
            }
            return;
        }
        // select pivot
        const pivot = list[0];
        // slice <= pivot
        var endlist = for (1..list.len) |i| {
            if (list[i].force < pivot.force) {
                break i;
            }
        } else list.len;
        // slice > pivot
        if (endlist != list.len) {
            for ((endlist + 1)..list.len) |i| {
                if (list[i].force > pivot.force) {
                    swap(position, &list[i], &list[endlist]);
                    endlist += 1;
                }
            }
        }
        if (endlist > 1) {
            // swap pivot
            swap(position, &list[0], &list[endlist - 1]);
            // left quicksort
            reversequicksort(list[0..(endlist - 1)]);
        }
        if (endlist < list.len) {
            // right quicksort
            reversequicksort(list[endlist..list.len]);
        }
    }
    fn genmap(self: *generator) void {
        for (self.bufgrid, 0..) |*e, i| {
            e.pos = (i / self.grid.len);
            e.gridpos = (i % self.grid.len);
            if (!inSlice(self.locked, vec2{ .x = (e.pos % self.sx), .y = (e.pos / self.sx) }) and !inSlice(self.locked, vec2{ .x = (e.gridpos % self.sx), .y = (e.gridpos / self.sx) })) {
                e.active = true;
                e.force = @intFromFloat(1.0 / (ro * math.sqrt(2.0 * math.pi * math.pow(f64, math.e, (@as(f64, @floatFromInt(((e.pos % self.sx) * (e.pos % self.sx)) + ((e.pos / self.sx) * (e.pos / self.sx)))) / (@as(f64, @floatFromInt(max)) * ro))))));
                e.force += generatenumber();
            } else {
                e.active = false;
            }
        }
        reversequicksort(self.bufgrid);
    }
    fn collide(self: *generator) void {
        for (self.bufgrid, 0..) |e, i| {
            if (e.active) {
                for ((i + 1)..self.bufgrid.len) |index2| {
                    if (self.bufgrid[index2].active and ((self.bufgrid[index2].gridpos == e.gridpos) or (self.bufgrid[index2].pos == e.pos))) {
                        self.bufgrid[index2].active = false;
                    }
                }
            }
        }
        for (self.bufgrid) |e| {
            if (e.active) {
                self.grid[e.pos].gridpos = e.gridpos;
            }
        }
    }
};
