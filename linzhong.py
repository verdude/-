import argparse
import ctypes
import logging
import platform

logging.basicConfig(level=logging.INFO, handlers=[logging.StreamHandler()])
for handler in logging.getLogger().handlers:
    handler.setLevel(logging.INFO)
    handler.flush = lambda: None


def parse_args():
    parser = argparse.ArgumentParser(description="獲取一個TOTP碼")
    parser.add_argument("-f", "--fuwu", type=str, help="服務命名")
    return parser.parse_args()


def set_argtypes(object_path: str) -> ctypes.CDLL:
    lib = ctypes.CDLL(object_path)
    lib.get_totp.restype = ctypes.c_char_p
    lib.get_totp.argtypes = [
        ctypes.c_char_p,
        ctypes.c_size_t,
    ]
    return lib


def main():
    args = parse_args()

    if not args.fuwu:
        logging.error("服務命名不能為空")
        exit(1)

    system = platform.system()
    if system == "Linux":
        lib = set_argtypes("./zig-out/lib/lib臨終.so")
    elif system == "Darwin":
        lib = set_argtypes("./zig-out/lib/lib臨終.dylib")
    else:
        logging.error("不支持的操作系統")
        exit(1)

    fuwu_bytes = args.fuwu.encode("utf-8")
    fuwu_len = len(fuwu_bytes)

    totp_code = lib.get_totp(fuwu_bytes, fuwu_len)

    print(str(totp_code))


if __name__ == "__main__":
    main()
