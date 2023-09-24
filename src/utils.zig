const std = @import("std");
const String = @import("zig-string").String;

pub fn fileOf(path: []const u8) !std.fs.File {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    path = try std.fs.realpath(path, &path_buffer);

    var source = std.fs.openFileAbsolute(path, .{}) catch |err| {
        if (err != error.IsDir) {
            std.debug.print("{s}", .{"Lua file doesn't exists"});

            std.process.exit(0);
        }

        var pathForMain = String.init(allocator);
        defer pathForMain.deinit();

        try pathForMain.concat(path);
        try pathForMain.concat("/main.lua");

        var dirSource = std.fs.cwd().openFile(pathForMain.str(), .{}) catch {
            std.debug.print("{s}", .{"Main Lua file doesn't exists"});

            std.process.exit(0);
        };

        defer dirSource.close();

        return dirSource;
    };

    defer source.close();

    return source;
}

pub fn sizeOf(path: []const u8) u64 {
    _ = path;
    return std.fs.Dir(.{});
}

pub fn contentsOf(path: []const u8) ![]u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    path = try std.fs.realpath(path, &path_buffer);

    const file = std.fs.openFileAbsolute(path, .{ .read = true }) catch |err| {
        _ = err;
    };
    defer file.close();

    const file_buffer = try file.readToEndAlloc(allocator, file.stat().size);
    defer allocator.free(file_buffer);

    return file_buffer;
}
