const std = @import("std");
const totp = @import("./totp.zig");

fn readStringFromStdin(buffer: []u8) ![]u8 {
    const stdin = std.io.getStdIn().reader();
    const read_bytes = try stdin.readUntilDelimiterOrEof(buffer, '\n');
    return buffer[0..read_bytes.?.len];
}

pub fn main() !void {
    std.debug.print("請輸入編碼的密碼：", .{});
    var buffer: [128]u8 = undefined;
    const secret = try readStringFromStdin(&buffer);
    var outbuf: [128]u8 = undefined;
    const decoded_secret = try totp.base32Decode(secret, &outbuf);
    var totp_code: [6]u8 = undefined;

    const shijianmima = try totp.generateTotp(decoded_secret, 30, 6, &totp_code);
    try std.io.getStdOut().writer().print("{s}", .{shijianmima});
    std.debug.print("\n", .{});
}
