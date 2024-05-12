const std = @import("std");
const generator = @import("randomgen.zig");
const c_alloc = std.heap.c_allocator;
const string = std.ArrayList(u8);
const ray = @cImport({
    @cInclude("raylib.h");
});

const renderopt = enum {
    actions,
    classroom,
    both,
};
const uiphase = enum {
    default,
    running,
    pause,
    stop,
    setup,
};

pub const gui = struct {
    displaygrid: []string,
    classroomTexture: ray.RenderTexture2D = undefined,
    actionsTexture: ray.RenderTexture2D = undefined,
    currentphase: uiphase = uiphase.default,

    var prng: std.rand.DefaultPrng = undefined;
    var rand: std.Random = undefined;

    fn resizegrid(self: gui, size: usize) !void {
        const oldsize = self.displaygrid.len;
        // TODO: fix deinit if newsize < oldisize
        try c_alloc.realloc(self.displaygrid, size);
        // TODO: fix init if newsize > oldisize
        _ = oldsize; // autofix
    }

    pub fn compose(self: gui, grid: []generator.person) !void {
        for (grid) |e| {
            self.displaygrid[e.gridpos] = try e.name.clone();
        }
    }
    fn initrand() !void {
        prng = std.rand.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            try std.posix.getrandom(std.mem.asBytes(&seed));
            break :blk seed;
        });
        rand = prng.random();
    }

    pub fn init(self: *gui) !void {
        ray.SetTraceLogLevel(ray.LOG_NONE);
        ray.InitWindow(1200, 800, "YourDesk");
        ray.SetExitKey(ray.KEY_NULL);
        ray.SetTargetFPS(60);

        self.classroomTexture = ray.LoadRenderTexture(1200, 700);
        self.actionsTexture = ray.LoadRenderTexture(1200, 100);
        try initrand();
    }
    pub fn run(self: *gui) void {
        ray.BeginTextureMode(self.classroomTexture);
        ray.ClearBackground(ray.BLUE);
        ray.EndTextureMode();
        ray.BeginTextureMode(self.actionsTexture);
        ray.ClearBackground(ray.GREEN);
        ray.EndTextureMode();
        while (!ray.WindowShouldClose()) {
            // update
            // render
            if (self.update()) |u| {
                self.render(u);
            }

            ray.BeginDrawing();
            ray.ClearBackground(ray.RAYWHITE);
            ray.DrawTexture(self.classroomTexture.texture, 0, 0, ray.WHITE);
            ray.DrawTexture(self.actionsTexture.texture, 0, 700, ray.WHITE);
            ray.DrawRectangle(5, 5, 100, 30, ray.RAYWHITE);
            ray.DrawFPS(10, 10);
            ray.EndDrawing();
        }
    }
    pub fn deinit(self: *gui) void {
        ray.UnloadRenderTexture(self.classroomTexture);
        ray.UnloadRenderTexture(self.actionsTexture);
        ray.CloseWindow();
    }

    fn update(self: *gui) ?renderopt {
        const mpoint = ray.GetMousePosition();
        _ = mpoint; // autofix
        switch (self.currentphase) {
            .default => {},
            .running => {
                std.mem.swap(string, &self.displaygrid[rand.int(usize) % self.displaygrid.len], &self.displaygrid[rand.int(usize) % self.displaygrid.len]);
            },
            .pause => {},
            .stop => {},
            .setup => {},
        }
        return null;
    }
    fn render(self: *gui, options: renderopt) void {
        switch (options) {
            .actions => {},
            .classroom => {},
            .both => {},
        }
        _ = self; // autofix
    }
};
