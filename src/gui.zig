const std = @import("std");
const generator = @import("randomgen.zig");
const allocator = std.heap.page_allocator;
const string = std.ArrayList(u8);
const ray = @cImport({
    @cInclude("raylib.h");
    @cDefine("RAYGUI_IMPLEMENTATION", "");
    @cInclude("raygui.h");
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
    // classroomTexture: ray.RenderTexture2D = undefined,
    // actionsTexture: ray.RenderTexture2D = undefined,
    buttonlinesActive: bool = false,
    slideValue: f32 = 0.0,
    colorpickvalue: ray.Color,
    spinnervalue: c_int,
    spinnermode: bool,
    linenumbervalue: c_int,
    linenumbermode: bool,

    currentphase: uiphase = uiphase.default,

    var prng: std.rand.DefaultPrng = undefined;
    var rand: std.Random = undefined;

    fn resizegrid(self: gui, size: usize) !void {
        const oldsize = self.displaygrid.len;
        // TODO: fix deinit if newsize < oldisize
        try allocator.realloc(self.displaygrid, size);
        // TODO: fix init if newsize > oldisize
        _ = oldsize; // autofix
    }

    pub fn compose(self: gui, grid: []generator.person) !void {
        for (grid) |e| {
            self.displaygrid[e.gridpos] = try e.name.clone();
        }
    }
    
    pub fn init(self: *gui) !void {
        _ = self; // autofix
        ray.SetTraceLogLevel(ray.LOG_NONE);
        ray.InitWindow(1056, 616, "Yourdesk");
        ray.SetExitKey(ray.KEY_NULL);
        ray.SetTargetFPS(60);
    }
    pub fn deinit() !void {
        ray.CloseWindow();
    }
    pub fn run(self: *gui) !void {
        while (!ray.WindowShouldClose()) {
            ray.BeginDrawing();
            ray.ClearBackground(ray.GetColor(ray.GuiGetStyle(ray.DEFAULT, ray.BACKGROUND_COLOR))); 

            ray.GuiGroupBox(ray.Rectangle{ .x = 40, .y = 40, .width = 1040, .height = 504 }, "CLASS");
            ray.GuiDummyRec(ray.Rectangle{ .x = 80, .y = 72, .width = 136, .height = 40 }, "PERSON");

            if (ray.GuiButton(ray.Rectangle{ .x = 80, .y = 568, .width = 136, .height = 48 }, "ADD") > 0) {}
            if (ray.GuiButton(ray.Rectangle{ .x = 240, .y = 568, .width = 136, .height = 48 }, "REMOVE") > 0) {}
            if (ray.GuiButton(ray.Rectangle{ .x = 400, .y = 568, .width = 136, .height = 48 }, "RENAME") > 0) {}
            ray.GuiToggle(ray.Rectangle{ .x = 560, .y = 568, .width = 136, .height = 48 }, "SET LINES", &self.buttonlinesActive);
            if (self.buttonlinesActive) {self.currentphase = uiphase.setup;}
            if (ray.GuiButton(ray.Rectangle{ .x = 824, .y = 560, .width = 176, .height = 64 }, "START") > 0) {}

            switch (self.currentphase) {
                uiphase.running => {
                    ray.GuiPanel(ray.Rectangle{ .x = 320, .y = 480, .width = 512, .height = 48 }, ray.NULL);
                    ray.GuiProgressBar(ray.Rectangle{ .x = 336, .y = 496, .width = 480, .height = 16 }, ray.NULL, ray.NULL, &self.slideValue, 0, 1);
                },
                uiphase.setup => {
                    ray.GuiPanel(ray.Rectangle{ .x = 472, .y = 480, .width = 208, .height = 48 }, ray.NULL);
                    if (ray.GuiSpinner(ray.Rectangle{ .x = 488, .y = 488, .width = 176, .height = 32 }, ray.NULL, &self.spinnervalue, 0, 100, self.spinnermode) > 0) { self.spinnermode = !self.spinnermode; }
                    ray.GuiPanel(ray.Rectangle{ .x = 864, .y = 152, .width = 200, .height = 264 }, ray.NULL);
                    ray.GuiColorPicker(ray.Rectangle{ .x = 880, .y = 176, .width = 144, .height = 136 }, ray.NULL, &self.colorpickvalue);
                    ray.DrawRectangleRec(ray.Rectangle{ .x = 880, .y = 320, .width = 168, .height = 16 }, self.colorpickvalue);
                    if (ray.GuiValueBox(ray.Rectangle{ .x = 880, .y = 352, .width = 112, .height = 40 }, ray.NULL, &self.linenumbervalue, 0, 100, self.linenumbermode) > 0) { self.linenumbermode = !self.linenumbermode; }
                    if (ray.GuiButton(ray.Rectangle{ .x = 1000, .y = 352, .width = 48, .height = 40 }, "ADD") > 0) {}
                },
                else => {}
            }


            ray.EndDrawing();
        }
    }

    // fn initrand() !void {
    //     prng = std.rand.DefaultPrng.init(blk: {
    //         var seed: u64 = undefined;
    //         try std.posix.getrandom(std.mem.asBytes(&seed));
    //         break :blk seed;
    //     });
    //     rand = prng.random();
    // }
    // pub fn init(self: *gui) !void {
    //     ray.SetTraceLogLevel(ray.LOG_NONE);
    //     ray.InitWindow(1200, 800, "YourDesk");
    //     ray.SetExitKey(ray.KEY_NULL);
    //     ray.SetTargetFPS(60);
    //
    //     self.classroomTexture = ray.LoadRenderTexture(1200, 700);
    //     self.actionsTexture = ray.LoadRenderTexture(1200, 100);
    //     try initrand();
    // }
    // pub fn run(self: *gui) void {
    //     ray.BeginTextureMode(self.classroomTexture);
    //     ray.ClearBackground(ray.BLUE);
    //     ray.EndTextureMode();
    //     ray.BeginTextureMode(self.actionsTexture);
    //     ray.ClearBackground(ray.GREEN);
    //     ray.EndTextureMode();
    //     while (!ray.WindowShouldClose()) {
    //         // update
    //         // render
    //         if (self.update()) |u| {
    //             self.render(u);
    //         }
    //
    //         ray.BeginDrawing();
    //         ray.ClearBackground(ray.RAYWHITE);
    //         ray.DrawTexture(self.classroomTexture.texture, 0, 0, ray.WHITE);
    //         ray.DrawTexture(self.actionsTexture.texture, 0, 700, ray.WHITE);
    //         ray.DrawRectangle(5, 5, 100, 30, ray.RAYWHITE);
    //         ray.DrawFPS(10, 10);
    //         ray.EndDrawing();
    //     }
    // }
    // pub fn deinit(self: *gui) void {
    //     ray.UnloadRenderTexture(self.classroomTexture);
    //     ray.UnloadRenderTexture(self.actionsTexture);
    //     ray.CloseWindow();
    // }
    //
    // fn update(self: *gui) ?renderopt {
    //     const mpoint = ray.GetMousePosition();
    //     _ = mpoint; // autofix
    //     switch (self.currentphase) {
    //         .default => {},
    //         .running => {
    //             std.mem.swap(string, &self.displaygrid[rand.int(usize) % self.displaygrid.len], &self.displaygrid[rand.int(usize) % self.displaygrid.len]);
    //         },
    //         .pause => {},
    //         .stop => {},
    //         .setup => {},
    //     }
    //     return null;
    // }
    // fn render(self: *gui, options: renderopt) void {
    //     switch (options) {
    //         .actions => {},
    //         .classroom => {},
    //         .both => {},
    //     }
    //     _ = self; // autofix
    // }
};
