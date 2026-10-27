# Simplified anisotropic lattice random walk; see README for assumptions.
import Base

def next(seed: U32) -> U32:
  (seed * 1664525 + 1013904223 : U32)

def flag(b: Bool) -> F32:
  match b:
    case True{}:
      1.0
    case False{}:
      0.0

def walk(n: Nat, +seed: U32, +x: F32, +y: F32, +z: F32) -> F32:
  match n:
    case 0n:
      (x * x + y * y + z * z : F32)
    case 1n+p:
      +s = next(seed)
      +r = (U32.shrn(s, 8n) % 1000 : U32)
      dx = (2.0 * flag(U32.is_lt(r, 40)) - flag(U32.is_lt(r, 80)) : F32)
      dy = (2.0 * flag(U32.is_lt(r, 120)) - flag(U32.is_lt(r, 80)) - flag(U32.is_lt(r, 160)) : F32)
      dz = (2.0 * flag(U32.is_lt(r, 280)) - flag(U32.is_lt(r, 160)) - flag(U32.is_lt(r, 400)) : F32)
      walk(p, s, (x + dx : F32), (y + dy : F32), (z + dz : F32))

def ensemble(d: Nat, +start: U32, +steps: Nat) -> F32:
  match d:
    case 0n:
      walk(steps, (start * 747796405 + 2891336453 : U32), 0.0, 0.0, 0.0)
    case 1n++p:
      a b = ensemble(p, start, steps) ensemble(p, (start + U32.shln(1, p) : U32), steps)
      (a + b : F32)

def row(label: String, steps: Nat) -> IO(Unit):
  +msd = (ensemble!(10n, 0, steps) / 1024.0 : F32)
  IO.print(label ++ "," ++ F32.show(msd))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print("steps,msd_lattice2")
    Unit <- row("0", 0n)
    Unit <- row("25", 25n)
    Unit <- row("50", 50n)
    Unit <- row("100", 100n)
    row("200", 200n)
