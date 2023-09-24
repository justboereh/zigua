const std = @import("std");
const cli = @import("zig-cli");
const String = @import("zig-string").String;
const parser = @import("parser.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var analyze = cli.Option{
    .long_name = "analyze",
    .help = "analyze the code without running it",
    .value = cli.OptionValue{ .bool = false },
};

const app = &cli.App{
    .name = "luapp",
    .description = "A Lua compiler",
    .options = &.{&analyze},
    .action = run,
};

pub fn main() !void {
    return cli.run(app, allocator);
}

fn run(args: []const []const u8) !void {
    if (args.len < 1) {
        std.debug.print("{s}", .{"Lua file is required"});

        std.process.exit(0);
    }

    var tokens = parser.tokenize(args[0]);

    std.debug.print("{any}", .{tokens});
}
