const std = @import("std");
const totp = @import("./totp.zig");

export fn get_totp(secret: [*]const u8, secret_len: usize, totp_code: [*]u8) ?[*]u8 {
    _ = totp.generateTotp(secret[0..secret_len], 30, 6, totp_code[0..6]) catch {
        return null;
    };
    return totp_code;
}

test "get_totp" {
    const secret = "JBSWY3DPFQQFO33SNRSCC===";
    var totp_code = [1]u8{0} ** 6;
    const result = get_totp(secret, secret.len, &totp_code);
    if (result) |r| {
        //std.debug.print("Generated TOTP: {s}\n", .{result});
        for (0..6) |i| {
            try std.testing.expect(r[i] != 0);
        }
    } else unreachable;
}
