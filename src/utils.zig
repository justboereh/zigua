const std = @import("std");
const String = @import("libs/zig-string/zig-string.zig").String;

pub fn fileOf(path: []const u8) !std.fs.File {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("{any}", .{path.len});
    var file = std.fs.openFileAbsolute(path, .{}) catch |err| {
        if (err != error.IsDir) {
            std.debug.print("{s} {!}", .{ "Lua file doesn't exists", err });

            std.process.exit(0);
        }

        var pathForMain = String.init(allocator);
        defer pathForMain.deinit();

        try pathForMain.concat(path);
        try pathForMain.concat("/main.lua");

        var file = std.fs.openFileAbsolute(pathForMain.str(), .{}) catch {
            std.debug.print("{s}", .{"Main Lua file doesn't exists"});

            std.process.exit(0);
        };

        return file;
    };

    return file;
}

pub fn contentsOf(path: []const u8) ![]u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const newpath = try std.fs.realpath(path, &path_buffer);

    const file = fileOf(newpath) catch {
        std.debug.print("{s}", .{"Error getting Lua file"});

        std.process.exit(0);
    };

    defer file.close();

    var buffer: [10240]u8 = undefined;

    const file_buffer = try file.readToEndAlloc(allocator, 10240);
    defer allocator.free(file_buffer);

    return buffer;
}
