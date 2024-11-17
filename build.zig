const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "YourDesk",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    // var sources = std.ArrayList([]const u8).init(b.allocator);
    // // Search for all C/C++ files in `src` and add them
    // {
    //     var dir = try std.fs.cwd().openDir("src", .{ .iterate = true });
    //     var walker = try dir.walk(b.allocator);
    //     defer walker.deinit();
    //     while (try walker.next()) |entry| {
    //         const ext = std.fs.path.extension(entry.basename);
    //
    //         if (std.mem.eql(u8, ext, ".c") or std.mem.eql(u8, ext, ".cpp")) {
    //             // we have to clone the path as walker.next() or walker.deinit() will override/kill it
    //             try sources.append(b.dupe(entry.path));
    //         }
    //     }
    // }
    // exe.addCSourceFiles(.{
    //     .root = b.path("src"),
    //     .files = sources.items,
    // });
    // exe.addCSourceFile(.{ .file = b.path("src/rgen.cpp") });
    exe.linkLibCpp();
    exe.linkSystemLibrary("raylib");
    exe.linkSystemLibrary("raygui");
    b.installArtifact(exe);

    // Run
    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Test
    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/test.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    // exe.addCSourceFile(.{ .file = b.path("src/rgen.cpp") });
    unit_tests.linkLibCpp();
    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Test the application");
    test_step.dependOn(&run_unit_tests.step);
}
