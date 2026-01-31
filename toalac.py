#!/usr/bin/env python3

import argparse
import subprocess
import os
import sys
from multiprocessing import Pool, cpu_count
import shutil

FFMPEG = shutil.which("ffmpeg") or "/opt/homebrew/bin/ffmpeg"

if not FFMPEG:
    print("ffmpeg not found", file=sys.stderr)
    sys.exit(2)

# Supported input audio extensions
AUDIO_EXTENSIONS = ('.wav', '.flac', '.aiff', '.aif')

# Track failures
failures = []

def convert_file(args):
    input_path, keep_source = args
    base, _ = os.path.splitext(input_path)
    output_path = f"{base}.m4a"

    # Skip if output already exists
    if os.path.exists(output_path):
        print(f"Skipping (output exists): {output_path}")
        return

    # ffmpeg command to convert to ALAC while preserving metadata
    cmd = [
        FFMPEG,
        "-i", input_path,
        "-c:a", "alac",
        "-vn",
        output_path
    ]

    print(f"Converting: {input_path} -> {output_path}")
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        print(f"Error converting {input_path}: {e.stderr.decode('utf-8')}", file=sys.stderr)
        failures.append(input_path)
        return

    if not keep_source:
        try:
            os.remove(input_path)
            print(f"Removed source file: {input_path}")
        except OSError as e:
            print(f"Error removing {input_path}: {e}", file=sys.stderr)
            failures.append(input_path)

def gather_files(paths):
    """Recursively gather all supported audio files from a list of paths"""
    files_to_process = []
    for path in paths:
        if os.path.isfile(path) and path.lower().endswith(AUDIO_EXTENSIONS):
            files_to_process.append(path)
        elif os.path.isdir(path):
            for root, _, files in os.walk(path):
                for f in files:
                    full_path = os.path.join(root, f)
                    if full_path.lower().endswith(AUDIO_EXTENSIONS):
                        files_to_process.append(full_path)
        else:
            print(f"Skipping unknown path: {path}")
    return files_to_process

def main():
    parser = argparse.ArgumentParser(description="Convert audio files to ALAC (.m4a) using ffmpeg")
    parser.add_argument("paths", nargs="+", help="Files or directories to process")
    parser.add_argument("-k", "--keep", action="store_true", help="Keep source files after conversion")
    args = parser.parse_args()

    files = gather_files(args.paths)
    if not files:
        print("No audio files found.")
        return

    # Use all available CPUs
    pool = Pool(cpu_count())
    pool.map(convert_file, [(f, args.keep) for f in files])
    pool.close()
    pool.join()

    if failures:
        print(f"\nFinished with {len(failures)} failures.", file=sys.stderr)
        sys.exit(1)
    else:
        print("\nAll files processed successfully.")

if __name__ == "__main__":
    main()

