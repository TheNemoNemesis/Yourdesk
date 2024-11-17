const std = @import("std");
const generator = @import("randomgen.zig");
const allocator = std.heap.page_allocator;
const string = std.ArrayList(u8);
const ray = @cImport({
    @cInclude("raylib.h");
    @cInclude("raygui.h");
});

const uiphase = enum {
    default,
    running,
    pause,
    stop,
    setup,
};
const rendephase = enum {
    none,
    camera,
    class,
};

pub const gui = struct {
    selected: ?[]const u8,
    buttonlinesActive: bool,
    slideValue: f32,
    colorpickvalue: ray.Color,
    spinnervalue: c_int,
    spinnermode: bool,
    numoflines: c_int,
    backgroundcolor: ray.Color,
    foregroundcolor: ray.Color,
    bordercolor: ray.Color,
    currentphase: uiphase,
    rendermode: rendephase,
    classtexture: ray.RenderTexture2D,
    deskstexture: ray.RenderTexture2D,
    classcamera: ray.Camera2D,
    genThread: std.Thread,
    
    pub fn init() gui {
        ray.SetTraceLogLevel(ray.LOG_NONE);
        ray.InitWindow(1056, 616, "Yourdesk");
        ray.SetExitKey(ray.KEY_NULL);
        ray.SetTargetFPS(60);
        return gui{
            .selected = null,
            .buttonlinesActive = false,
            .slideValue = 0.0,
            .colorpickvalue = ray.BLACK,
            .spinnervalue = 0,
            .spinnermode = false,
            .numoflines = 0,
            .backgroundcolor = ray.GetColor(@bitCast(ray.GuiGetStyle(ray.DEFAULT, ray.BACKGROUND_COLOR))),
            .foregroundcolor = ray.GetColor(@bitCast(ray.GuiGetStyle(ray.DEFAULT, ray.BASE_COLOR_NORMAL))),
            .bordercolor = ray.GetColor(@bitCast(ray.GuiGetStyle(ray.DEFAULT, ray.TEXT_COLOR_NORMAL))),
            .currentphase = uiphase.default,
            .rendermode = rendephase.class,
            .classtexture = ray.LoadRenderTexture(1030, 494),
            .deskstexture = ray.LoadRenderTexture(1030, 494),
            .classcamera = ray.Camera2D{.zoom = 1.0, .offset = .{ .x = 0, .y = 0 }, .target = .{ .x = 0, .y = 0 }, .rotation = 0.0},
            .genThread = undefined,
        };
    }

    pub fn deinit(self: *gui) void {
        ray.UnloadRenderTexture(self.deskstexture);
        ray.UnloadRenderTexture(self.classtexture);
        ray.CloseWindow();
    }

    pub fn run(self: *gui, gen: *generator.generator) !void {
        while (!ray.WindowShouldClose()) {
            self.update(gen);
            self.updatetextures(gen);

            ray.BeginDrawing();
            ray.ClearBackground(self.backgroundcolor);

            _ = ray.GuiGroupBox(ray.Rectangle{ .x = 8, .y = 16, .width = 1040, .height = 504 }, "CLASS");
            ray.DrawTextureRec(self.classtexture.texture, ray.Rectangle{.x = 0, .y = 0, .width = 1030, .height = -494}, .{.x = 13, .y = 21}, ray.WHITE);

            if (ray.GuiButton(ray.Rectangle{ .x = 48, .y = 544, .width = 136, .height = 48 }, "ADD") > 0) {}
            if (ray.GuiButton(ray.Rectangle{ .x = (240 - 32), .y = 544, .width = 136, .height = 48 }, "REMOVE") > 0) {
                if (self.selected) |selectedDesk| {
                    if (gen.class.remove(selectedDesk)) {
                        self.selected = null;
                    }
                }
            }
            if (ray.GuiButton(ray.Rectangle{ .x = 368, .y = 544, .width = 136, .height = 48 }, "RENAME") > 0) {}
            if (ray.GuiButton(ray.Rectangle{ .x = 528, .y = 544, .width = 136, .height = 48 }, "SET LINES") > 0) {
                self.buttonlinesActive = !self.buttonlinesActive;
                self.currentphase = if (self.buttonlinesActive) uiphase.setup else uiphase.default;
            }
            if (ray.GuiButton(ray.Rectangle{ .x = (824 - 32), .y = (560 - 24), .width = 176, .height = 64 }, "START") > 0) {
                self.genThread = std.Thread.spawn(.{}, gen.newDisposition, .{&self.slideValue});
                self.genThread.detach();
            }

            switch (self.currentphase) {
                uiphase.running => {
                    _ = ray.GuiPanel(ray.Rectangle{ .x = (320 - 32), .y = (480 - 24), .width = 512, .height = 48 }, "");
                    _ = ray.GuiProgressBar(ray.Rectangle{ .x = (336 - 32), .y = (496 - 24), .width = 480, .height = 16 }, "", "", &self.slideValue, 0, 1);
                    if (self.slideValue >= 1.0) {
                        self.currentphase = uiphase.default;
                        self.slideValue = 0.0;
                    }
                },
                uiphase.setup => {
                    ray.DrawRectangleRec(ray.Rectangle{ .x = (472 - 32), .y = (480 - 24), .width = 208, .height = 48 }, self.backgroundcolor);
                    ray.DrawRectangleLinesEx(ray.Rectangle{ .x = (472 - 32), .y = (480 - 24), .width = 208, .height = 48 }, 2.0, self.bordercolor);
                    if (ray.GuiSpinner(ray.Rectangle{ .x = (488 - 32), .y = (488 - 24), .width = 176, .height = 32 }, "", &self.spinnervalue, 0, self.numoflines, self.spinnermode) > 0) { self.spinnermode = !self.spinnermode; }

                    ray.DrawRectangleRec(ray.Rectangle{ .x = (864 - 32), .y = (152 - 24), .width = 200, .height = 264 }, self.backgroundcolor);
                    ray.DrawRectangleLinesEx(ray.Rectangle{ .x = (864 - 32), .y = (152 - 24), .width = 200, .height = 264 }, 2.0, self.bordercolor);
                    _ = ray.GuiColorPicker(ray.Rectangle{ .x = (880 - 32), .y = (176 - 24), .width = 144, .height = 136 }, "", &self.colorpickvalue);
                    ray.DrawRectangleRec(ray.Rectangle{ .x = (880 - 32), .y = (320 - 24), .width = 168, .height = 16 }, self.colorpickvalue);
                    if (ray.GuiButton(ray.Rectangle{ .x = (880 - 32), .y = (352 - 24), .width = 168, .height = 40 }, "ADD") > 0) {
                        self.numoflines += 1;
                    }
                },
                else => {}
            }


            ray.EndDrawing();
        }
    }

    pub fn updatetextures(self: *gui, gen: *generator.generator) void {
        switch (self.rendermode) {
            rendephase.camera => {
                ray.BeginTextureMode(self.classtexture);
                ray.ClearBackground(self.backgroundcolor);
                ray.BeginMode2D(self.classcamera);
                ray.DrawTextureRec(self.deskstexture.texture, ray.Rectangle{.x = 0, .y = 0, .width = 1030, .height = -494}, .{.x = 0, .y = 0}, ray.WHITE);
                ray.EndMode2D();
                ray.EndTextureMode();
            },
            rendephase.class => {
                ray.BeginTextureMode(self.deskstexture);
                ray.ClearBackground(self.backgroundcolor);
                if (gen.class.count() > 0) {
                    var iter = gen.class.iterator();
                    while (iter.next()) |entry| {
                        _ = ray.GuiDummyRec(ray.Rectangle{ .x = entry.value_ptr.newPosition.x, .y = entry.value_ptr.newPosition.y, .width = 136, .height = 40 }, @ptrCast(@alignCast(entry.key_ptr.*)));
                        if (self.selected) |selectedDesk| {
                            if (std.mem.eql(u8, selectedDesk, entry.key_ptr.*)) {
                                ray.DrawRectangleLinesEx(ray.Rectangle{ .x = entry.value_ptr.newPosition.x, .y = entry.value_ptr.newPosition.y, .width = 136, .height = 40 }, 3.0, ray.BLUE);
                            }
                        }
                    }
                }
                ray.EndTextureMode();
                ray.BeginTextureMode(self.classtexture);
                ray.ClearBackground(self.backgroundcolor);
                ray.BeginMode2D(self.classcamera);
                ray.DrawTextureRec(self.deskstexture.texture, ray.Rectangle{.x = 0, .y = 0, .width = 1030, .height = -494}, .{.x = 0, .y = 0}, ray.WHITE);
                ray.EndMode2D();
                ray.EndTextureMode();
            },
            else => {},
        }
    }

    pub fn update(self: *gui, gen: *generator.generator) void {
        if (ray.IsMouseButtonPressed(ray.MOUSE_LEFT_BUTTON)) {
            const position = ray.GetMousePosition();
            var iter = gen.class.iterator();
            self.selected = while (iter.next()) |entry| {
                if (ray.CheckCollisionPointRec(ray.GetScreenToWorld2D(position, self.classcamera), ray.Rectangle{.x = entry.value_ptr.newPosition.x, .y = entry.value_ptr.newPosition.y, .width = 136, .height = 40})) {
                    self.rendermode = rendephase.class;
                    break entry.key_ptr.*;
                }
            } else null;
        }
    }
};
