const std = @import("std");
const utils = @import("utils.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn tokenize(path: []const u8) void {
    var file = utils.fileOf(path) catch {
        std.debug.print("{s}", .{"Error getting Lua file"});

        std.process.exit(0);
    };
    _ = file;
}
