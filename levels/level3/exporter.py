#!/usr/bin/env python3
"""report-exporter v1.4.0 — generates scheduled PDF exports."""
import os

SCRIPTS_DIR = "/host-scripts"

def main():
    print("[INFO] report-exporter v1.4.0 starting")
    for f in os.listdir(SCRIPTS_DIR):
        path = os.path.join(SCRIPTS_DIR, f)
        stat = os.stat(path)
        print(f"[INFO]   {path} (mode={oct(stat.st_mode)[-3:]})")

if __name__ == "__main__":
    main()
