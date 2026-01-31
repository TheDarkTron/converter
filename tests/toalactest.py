#!/usr/bin/env python3

import unittest
import tempfile
import os
import subprocess
import sys
import shutil

# Path to your conversion script
SCRIPT_PATH = "./../toalac.py"

class TestConvertToAlac(unittest.TestCase):

    def setUp(self):
        # Create a temporary directory
        self.test_dir = tempfile.mkdtemp()
        # Root-level WAV file
        self.wav_file = os.path.join(self.test_dir, "test.wav")
        # Subfolder with another WAV file
        self.sub_dir = os.path.join(self.test_dir, "subfolder")
        os.makedirs(self.sub_dir)
        self.sub_wav_file = os.path.join(self.sub_dir, "subtest.wav")

        # Create small silent WAV files using ffmpeg
        for f in [self.wav_file, self.sub_wav_file]:
            subprocess.run([
                "ffmpeg", "-f", "lavfi", "-i", "anullsrc=r=44100:cl=mono",
                "-t", "1", f, "-y"
            ], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    def tearDown(self):
        # Remove temporary directory
        shutil.rmtree(self.test_dir)

    def run_script(self, keep=False):
        cmd = [sys.executable, SCRIPT_PATH, self.wav_file, self.sub_dir]
        if keep:
            cmd.insert(2, "--keep")
        print(cmd)
        subprocess.run(cmd, check=True)

    def test_conversion_removes_source(self):
        self.run_script(keep=False)

        # Root .m4a file exists, original removed
        root_m4a = os.path.join(self.test_dir, "test.m4a")
        self.assertTrue(os.path.exists(root_m4a))
        self.assertFalse(os.path.exists(self.wav_file))

        # Subfolder .m4a file exists, original removed
        sub_m4a = os.path.join(self.sub_dir, "subtest.m4a")
        self.assertTrue(os.path.exists(sub_m4a))
        self.assertFalse(os.path.exists(self.sub_wav_file))

    def test_conversion_keeps_source(self):
        self.run_script(keep=True)

        # Root .m4a file exists, original kept
        root_m4a = os.path.join(self.test_dir, "test.m4a")
        self.assertTrue(os.path.exists(root_m4a))
        self.assertTrue(os.path.exists(self.wav_file))

        # Subfolder .m4a file exists, original kept
        sub_m4a = os.path.join(self.sub_dir, "subtest.m4a")
        self.assertTrue(os.path.exists(sub_m4a))
        self.assertTrue(os.path.exists(self.sub_wav_file))

if __name__ == "__main__":
    unittest.main()

