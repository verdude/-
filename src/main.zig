const std = @import("std");
const crypto = @import("std.crypto");
const base32 = @import("std.base32");

fn readStringFromStdin() ![]u8 {
    const stdin = std.io.getStdIn().reader();
    var buffer: [256]u8 = undefined;
    const read_bytes = try stdin.readUntilDelimiterOrEof(&buffer, '\n');
    return buffer[0..read_bytes];
}

fn generateTotp(secret: []const u8, time_step: u64, digits: u8) ![]u8 {
    const time = std.time.milliTimestamp() / (time_step * 1000);
    var time_bytes: [8]u8 = undefined;
    std.mem.writeInt(u64, &time_bytes, time);

    var hmac = try crypto.hmac(crypto.hash.sha1, secret, &time_bytes);
    const offset = hmac[hmac.len - 1] & 0x0F;
    const code = (std.mem.readInt(u32, hmac[offset .. offset + 4]) & 0x7FFFFFFF) % std.math.pow(10, digits);

    var result: [6]u8 = undefined;
    try std.fmt.bufPrint(&result, "{d:0>6}", .{code});
    return result[0..digits];
}

pub fn main() !void {
    std.debug.print("請輸入編碼的密碼：", .{});
    const secret = try readStringFromStdin();
    const decoded_secret = try base32.decodeAlloc(std.heap.page_allocator, secret);
    defer std.heap.page_allocator.free(decoded_secret);

    const totp_code = try generateTotp(decoded_secret, 30, 6);
    std.debug.print("時間密碼: {s}\n", .{totp_code});
}
