#!/usr/bin/env python3
"""Check the random walk against the exact MSD for this transition model."""
import csv
import io
import subprocess
import sys

if len(sys.argv) < 2:
    raise SystemExit('Usage: python3 tests/check.py BEND_COMMAND [BEND_ARGS...]')
result = subprocess.run([*sys.argv[1:], 'main.bend'], check=True, text=True, capture_output=True)
rows = list(csv.DictReader(io.StringIO(result.stdout)))
assert [int(row['steps']) for row in rows] == [0, 25, 50, 100, 200]
for row in rows:
    steps = int(row['steps'])
    msd = float(row['msd_lattice2'])
    # Each attempt moves with probability 0.40; independent zero-mean steps
    # give E[r²] = 0.40 * steps. Allow finite-ensemble sampling error.
    assert abs(msd - 0.40 * steps) <= max(0.01, 0.12 * 0.40 * steps), (steps, msd)
print('PASS: 1024 walks, MSD at five times agrees with 3D random-walk expectation')
