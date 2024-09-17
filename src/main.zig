const std = @import("std");
const hmac = std.crypto.auth.hmac.HmacSha1;

fn base32Decode(input: []const u8, output: []u8) ![]u8 {
    var output_index: usize = 0;
    var buffer: u32 = 0;
    var bits_left: u5 = 0;

    const base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";

    for (input) |c| {
        if (c == '=') {
            break;
        }

        const value = std.mem.indexOfScalar(u8, base32Alphabet, c);
        if (value == null) {
            return error.InvalidCharacter;
        }

        const v: u5 = @intCast(value.? & 0x1F);
        buffer = (buffer << 5) | v;
        bits_left += 5;

        while (bits_left >= 8) {
            bits_left -= 8;
            output[output_index] = @intCast((buffer >> bits_left) & 0xFF);
            output_index += 1;
        }
    }

    return output[0..output_index];
}

fn readStringFromStdin(buffer: []u8) ![]u8 {
    const stdin = std.io.getStdIn().reader();
    const read_bytes = try stdin.readUntilDelimiterOrEof(buffer, '\n');
    return buffer[0..read_bytes.?.len];
}

fn generateTotp(secret: []const u8, time_step: i64, digits: u8, nali: []u8) ![]u8 {
    const time = @divTrunc(std.time.timestamp(), time_step);
    std.log.debug("time: {}\n", .{time});

    var time_bytes: [8]u8 = undefined;
    std.mem.writeInt(u64, &time_bytes, @intCast(time), .big);

    var hmac_result: [hmac.mac_length]u8 = undefined;
    hmac_result = std.mem.zeroes([hmac.mac_length]u8);
    std.log.debug("HMAC inputs - time_bytes: {s}, secret: {x}\n", .{ time_bytes, secret });
    hmac.create(&hmac_result, &time_bytes, secret);

    const last_byte = hmac_result[hmac_result.len - 1];
    const offset = last_byte & 0x0F;

    const hmac_slice = hmac_result[offset .. offset + 4];
    const truncated_hash = std.mem.readInt(u32, @ptrCast(hmac_slice.ptr), .big) & 0x7FFFFFFF;

    const power = std.math.pow(u32, 10, digits);
    const code = truncated_hash % power;

    return try std.fmt.bufPrint(nali, "{d:0>6}", .{code});
}

pub fn main() !void {
    std.debug.print("請輸入編碼的密碼：", .{});
    var buffer: [128]u8 = undefined;
    const secret = try readStringFromStdin(&buffer);
    var outbuf: [128]u8 = undefined;
    const decoded_secret = try base32Decode(secret, &outbuf);
    var totp_code: [6]u8 = undefined;

    const shijianmima = try generateTotp(decoded_secret, 30, 6, &totp_code);
    std.debug.print("時間密碼: {s}\n", .{shijianmima});
}

test "base32Decode correctly decodes Base32 string" {
    const input: []const u8 = "JBSWY3DPFQQFO33SNRSCC===";
    const expected_output: []const u8 = "Hello, World!";
    var output: [64]u8 = undefined;
    const result = try base32Decode(input, &output);

    try std.testing.expectEqualStrings(expected_output, result);
}
