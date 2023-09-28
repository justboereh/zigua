const std = @import("std");
const utils = @import("utils.zig");

pub const TokenType = enum {
    InvalidToken,
    Number,
    String,
    Call,
    Variable,
    BinaryOperator,
    ConcatOperator,
    CompareOperator,
    Function,
    Assigment,
    OpenCurlyBrackets,
    CloseCurlyBrackets,
    OpenBrackets,
    CloseBrackets,
    OpenParenthesis,
    CloseParenthesis,
    Comma,
    Colon,
    Local,
    Keyword,
    LessThan,
    GreaterThan,
};

pub const Token = struct {
    type: TokenType,
    text: u8,
};

pub fn parse(source: []const u8, file_name: []const u8) !std.ArrayList(Token) {
    var tokens = std.ArrayList(Token).init(std.heap.page_allocator);
    defer tokens.deinit();

    var inNumber = false;
    _ = inNumber;
    var inString = false;
    _ = inString;
    var string = "";
    _ = string;
    _ = file_name;

    for (source) |char| {
        switch (char) {
            '(' => {
                try tokens.append(Token{
                    .type = TokenType.OpenParenthesis,
                    .text = '(',
                });
            },
            ')' => {
                try tokens.append(Token{
                    .type = TokenType.CloseParenthesis,
                    .text = ')',
                });
            },
            '{' => {
                try tokens.append(Token{
                    .type = TokenType.OpenCurlyBrackets,
                    .text = '{',
                });
            },
            '}' => {
                try tokens.append(Token{
                    .type = TokenType.CloseCurlyBrackets,
                    .text = '}',
                });
            },
            '[' => {
                try tokens.append(Token{
                    .type = TokenType.OpenBrackets,
                    .text = '[',
                });
            },
            ']' => {
                try tokens.append(Token{
                    .type = TokenType.CloseBrackets,
                    .text = '(',
                });
            },
            '*' => {
                try tokens.append(Token{
                    .type = TokenType.BinaryOperator,
                    .text = '*',
                });
            },
            '^' => {
                try tokens.append(Token{
                    .type = TokenType.BinaryOperator,
                    .text = '^',
                });
            },
            '-' => {
                try tokens.append(Token{
                    .type = TokenType.BinaryOperator,
                    .text = '-',
                });
            },
            '=' => {
                try tokens.append(Token{
                    .type = TokenType.Assigment,
                    .text = '=',
                });
            },
            '+' => {
                try tokens.append(Token{
                    .type = TokenType.BinaryOperator,
                    .text = '+',
                });
            },
            '/' => {
                try tokens.append(Token{
                    .type = TokenType.BinaryOperator,
                    .text = '/',
                });
            },
            '>' => {
                try tokens.append(Token{
                    .type = TokenType.GreaterThan,
                    .text = '>',
                });
            },
            '<' => {
                try tokens.append(Token{
                    .type = TokenType.LessThan,
                    .text = '<',
                });
            },
            else => {
                try tokens.append(Token{
                    .type = TokenType.InvalidToken,
                    .text = undefined,
                });
            },
        }

        std.debug.print("{any}\n", .{char});
    }

    return tokens;
}

const ParserErrors = error{
    EndOfFile,
};

pub const Parser = struct {
    source: []u8,
    file_name: []u8,

    cursor: 0,
    column: 0,
    row: 0,

    inString: false,
    inNumber: false,

    fn next(self: *Parser) ParserErrors!void {
        if (self.cursor == self.source.len) {
            return ParserErrors.EndOfFile;
        }
    }
};

