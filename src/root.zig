const std = @import("std");
const totp = @import("./totp.zig");

export fn get_totp(secret: [*]const u8, secret_len: usize) ?[*]const u8 {
    var decoded_secret: [128]u8 = undefined;
    const secret_slice = totp.base32Decode(
        secret[0..secret_len],
        &decoded_secret,
    ) catch secret[0..secret_len];
    const nali = std.heap.c_allocator.alloc(u8, 6) catch unreachable;
    const zheli = totp.generateTotp(
        secret_slice,
        30,
        6,
        nali,
    ) catch |err| {
        std.log.err(
            "Failed to generate TOTP: {s}",
            .{@errorName(err)},
        );
        return null;
    };
    return zheli.ptr;
}

test "get_totp" {
    const secret = "wowcoolbeans";
    const result = get_totp(secret, secret.len);
    if (result) |r| {
        for (0..6) |i| {
            try std.testing.expect(r[i] != 0);
        }
    } else unreachable;
}
