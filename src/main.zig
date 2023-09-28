const std = @import("std");
const clap = @import("libs/zig-clap/clap.zig");
const String = @import("libs/zig-string/zig-string.zig").String;
const parser = @import("parser.zig");
const utils = @import("utils.zig");

fn toNullTerminated(allocator: std.mem.Allocator, string: []const u8) ![:0]u8 {
    return allocator.dupeZ(u8, string);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    var allocator = gpa.allocator();

    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Show help and exit
        \\-v, --version          Print version and exit
        \\<str>...
        \\
    );

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
    }) catch |err| {
        // Report useful error and exit
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.version == 1) {
        std.debug.print(
            "zigua Copyright (C) 2023-present justboereh \nBuilt with Zig \n",
            .{},
        );

        std.os.exit(0);
    }

    if (res.args.help == 1 or res.positionals.len == 0) {
        std.debug.print("zigua is a Lua compiler that is I don't know what it is \n\nUsage: zigua ", .{});

        try clap.usage(std.io.getStdErr().writer(), clap.Help, &params);

        std.debug.print("\n\n", .{});

        try clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{
            .description_on_new_line = false,
            .description_indent = 4,
            .spacing_between_parameters = 0,
        });

        std.os.exit(0);
    }

    var positionals = std.ArrayList([:0]u8).init(allocator);
    for (res.positionals) |pos| {
        try positionals.append(try toNullTerminated(allocator, pos));
    }
    defer {
        for (positionals.items) |pos| {
            allocator.free(pos);
        }
        positionals.deinit();
    }

    runFile(allocator, res.positionals[0], positionals.items[1..]) catch {
        std.debug.print("Error running file", .{});

        std.os.exit(1);
    };

    std.os.exit(0);
}

fn runFile(allocator: std.mem.Allocator, file_name: []const u8, args: [][:0]u8) !void {
    _ = args;

    var file = (if (std.fs.path.isAbsolute(file_name))
        std.fs.openFileAbsolute(file_name, .{})
    else
        std.fs.cwd().openFile(file_name, .{})) catch {
        std.debug.print("File not found", .{});

        return;
    };
    defer file.close();

    const source = try allocator.alloc(u8, (try file.stat()).size);
    defer allocator.free(source);

    _ = try file.readAll(source);

    _ = try parser.parse(source, file_name);
}
