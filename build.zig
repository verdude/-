const std = @import("std");
const sdl = @import("sdl");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // Initialize the SDL2 SDK
    const sdk = sdl.init(b, .{});

    const exe = b.addExecutable(.{
        .name = "臨終",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Link SDL2 as a shared library
    sdk.link(exe, .dynamic, sdl.Library.SDL2);

    // Add "sdl2" package that exposes the SDL2 API
    exe.root_module.addImport("sdl2", sdk.getNativeModule());

    exe.linkSystemLibrary("SDL2");

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);
}
