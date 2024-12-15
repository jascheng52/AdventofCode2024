const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "d4",
        .root_source_file = b.path("d4.zig"),
        .target = b.host,
    });

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    run_exe.addArg("input.ignore");

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);

}