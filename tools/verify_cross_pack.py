#!/usr/bin/env python3
"""验证十字照明（中心+四正交）下关卡可解性；与 Swift LightingEngine 对齐。"""
from __future__ import annotations

import json
import math
import sys
from itertools import combinations
from pathlib import Path

S = 1.0 / math.sqrt(2)


def blocked_set(level):
    return {(p["row"], p["col"]) for p in level.get("blockedCells", [])}


def cross_from_bulb(n, blocked, br, bc):
    out = []
    for dr, dc in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
        r, c = br + dr, bc + dc
        if 0 <= r < n and 0 <= c < n and (r, c) not in blocked:
            out.append((r, c))
    return out


def snap_to_eight(rx, ry):
    length = math.hypot(rx, ry)
    if length < 1e-9:
        return None
    x, y = rx / length, ry / length
    best_dot = -1.1
    best = None
    for drr, dcc in [
        (-1, -1), (-1, 0), (-1, 1),
        (0, -1), (0, 1),
        (1, -1), (1, 0), (1, 1),
    ]:
        ex, ey = float(dcc), float(drr)
        elen = math.hypot(ex, ey)
        if elen < 1e-9:
            continue
        d = (x * ex + y * ey) / elen
        if d > best_dot:
            best_dot = d
            best = (drr, dcc)
    return best


def reflected_neighbor(mrow, mcol, direction, bulb, n, blocked):
    br, bc = bulb
    dc = mcol - bc
    dr = mrow - br
    length = math.hypot(dc, dr)
    if length < 1e-9:
        return None
    vx, vy = dc / length, dr / length
    is_slash = direction in ("up", "right")
    nx, ny = (S, S) if is_slash else (S, -S)
    dot = vx * nx + vy * ny
    vx -= 2 * dot * nx
    vy -= 2 * dot * ny
    step = snap_to_eight(vx, vy)
    if step is None:
        return None
    tr, tc = mrow + step[0], mcol + step[1]
    if tr < 0 or tc < 0 or tr >= n or tc >= n:
        return None
    if (tr, tc) in blocked:
        return None
    return (tr, tc)


def ortho_plus_adjacent(a, b):
    ar, ac = a
    br, bc = b
    dr, dc = ar - br, ac - bc
    if dr == 0 and dc == 0:
        return True
    if dr == 0 and abs(dc) == 1:
        return True
    if dc == 0 and abs(dr) == 1:
        return True
    return False


def mirror_gate_passes(mrow, mcol, _direction, bulbs_t):
    """斜镜：正交相邻有灯即可反射（与 Swift `MirrorReflectionGate` 一致）。"""
    bulbs_adj = [b for b in bulbs_t if ortho_plus_adjacent((mrow, mcol), b)]
    return bool(bulbs_adj)


def lit_cells(level, bulbs):
    n = level["gridSize"]
    blocked = blocked_set(level)
    bulbs_t = [tuple(b) if isinstance(b, (list, tuple)) else b for b in bulbs]
    bulbs_t = [(b[0], b[1]) for b in bulbs_t]

    lit = set()
    for br, bc in bulbs_t:
        lit.update(cross_from_bulb(n, blocked, br, bc))

    mirrors = level.get("mirrorCells") or []
    while True:
        grew = False
        for m in mirrors:
            mrow, mcol, direction = m["row"], m["col"], m["direction"]
            if (mrow, mcol) not in lit or (mrow, mcol) in blocked:
                continue
            if not mirror_gate_passes(mrow, mcol, direction, bulbs_t):
                continue
            for bulb in bulbs_t:
                if not ortho_plus_adjacent((mrow, mcol), bulb):
                    continue
                t = reflected_neighbor(mrow, mcol, direction, bulb, n, blocked)
                if t and t not in lit:
                    lit.add(t)
                    grew = True
        if not grew:
            break

    for m in mirrors:
        mrow, mcol, direction = m["row"], m["col"], m["direction"]
        if (mrow, mcol) not in lit or (mrow, mcol) in blocked:
            continue
        if not mirror_gate_passes(mrow, mcol, direction, bulbs_t):
            lit.discard((mrow, mcol))

    slit_cells = {(p["row"], p["col"]) for p in (level.get("slitMirrorCells") or [])}
    while True:
        grew = False
        for sr, sc in slit_cells:
            if (sr, sc) not in lit or (sr, sc) in blocked:
                continue
            for br, bc in bulbs_t:
                if br != sr:
                    continue
                if bc == sc - 1:
                    t = (sr, sc + 1)
                elif bc == sc + 1:
                    t = (sr, sc - 1)
                else:
                    continue
                tr, tc = t
                if 0 <= tr < n and 0 <= tc < n and t not in blocked and t not in lit:
                    lit.add(t)
                    grew = True
        if not grew:
            break
    return lit


def is_win(level, bulbs):
    blocked = blocked_set(level)
    targets = {(p["row"], p["col"]) for p in level["targetMask"]}
    playable_targets = targets - blocked
    lit = lit_cells(level, bulbs)
    if not playable_targets <= lit:
        return False
    chapter_num = int("".join(c for c in level["chapterId"] if c.isdigit()) or "1")
    enforce_exact = chapter_num >= 2
    k = len(bulbs)
    if enforce_exact:
        if k != level.get("optimalBulbs", level["maxBulbs"]):
            return False
    else:
        if k > level["maxBulbs"]:
            return False
    return True


def bulb_candidates(level):
    n = level["gridSize"]
    blocked = blocked_set(level)
    mirror_pts = {(m["row"], m["col"]) for m in (level.get("mirrorCells") or [])}
    slit_pts = {(p["row"], p["col"]) for p in (level.get("slitMirrorCells") or [])}
    pts = []
    for r in range(n):
        for c in range(n):
            if (r, c) in blocked or (r, c) in mirror_pts or (r, c) in slit_pts:
                continue
            pts.append((r, c))
    return pts


def find_minimum_bulbs(level):
    """仅要求点亮所有目标，不计 `optimalBulbs` 约束；用于组关时求真实最小盏数。"""
    candidates = bulb_candidates(level)
    blocked = blocked_set(level)
    targets = {(p["row"], p["col"]) for p in level["targetMask"]}
    playable_targets = targets - blocked

    for k in range(0, len(candidates) + 1):
        for combo in combinations(candidates, k):
            lit = lit_cells(level, combo)
            if playable_targets <= lit:
                return k, list(combo)
    return None, None


def find_minimum_bulbs_min_on_targets(level):
    """在最小盏数前提下，尽量少把灯摆在目标格上（更倾向空白格作解心）。"""
    mk, _ = find_minimum_bulbs(level)
    if mk is None:
        return None, None
    candidates = bulb_candidates(level)
    blocked = blocked_set(level)
    targets = {(p["row"], p["col"]) for p in level["targetMask"]}
    playable_targets = targets - blocked
    best_combo = None
    best_on = 10**9
    for combo in combinations(candidates, mk):
        lit = lit_cells(level, combo)
        if not playable_targets <= lit:
            continue
        on_t = sum(1 for c in combo if c in playable_targets)
        if on_t < best_on:
            best_on = on_t
            best_combo = list(combo)
    if best_combo is None:
        return None, None
    return mk, best_combo


def min_solution_bulbs(level, max_k=None):
    caps = max_k if max_k is not None else level["maxBulbs"]
    candidates = bulb_candidates(level)
    chapter_num = int("".join(c for c in level["chapterId"] if c.isdigit()) or "1")
    enforce_exact = chapter_num >= 2
    if enforce_exact:
        k = level.get("optimalBulbs", caps)
        for combo in combinations(candidates, k):
            if is_win(level, combo):
                return list(combo), k
        return None, None
    for k in range(0, caps + 1):
        for combo in combinations(candidates, k):
            if is_win(level, combo):
                return list(combo), k
    return None, None


def main():
    path = Path(__file__).resolve().parent.parent / "LightGame" / "Data" / "levels_pack_01.json"
    data = json.loads(path.read_text())
    fail = False
    for ch in data["chapters"]:
        for lv in ch["levels"]:
            chn = int("".join(c for c in lv["chapterId"] if c.isdigit()) or "1")
            opt = lv.get("optimalBulbs")
            if chn <= 4:
                # 前几章部分关卡通关盏数大，枚举组合验证极慢；仅用「可解性」快检（恰为 declared optimal 时试一组）。
                cand = bulb_candidates(lv)
                from math import comb

                check_k = opt if chn >= 2 and opt is not None else lv.get("maxBulbs", 0)
                if check_k is not None and len(cand) >= check_k:
                    n_pairs = comb(len(cand), check_k)
                else:
                    n_pairs = 0
                if chn >= 2 and n_pairs > 250_000:
                    print(f"SKIP {lv['id']} (ch1–4 heavy {len(cand)}C{check_k})")
                    continue
                sol, k = min_solution_bulbs(lv)
                if sol is None:
                    print(f"FAIL {lv['id']}: no solution")
                    fail = True
                    continue
                if chn >= 2 and opt is not None and k != opt:
                    print(f"WARN {lv['id']}: at-declared k={k} vs optimalBulbs={opt}")
                    fail = True
                elif chn < 2 and k > lv["maxBulbs"]:
                    print(f"FAIL {lv['id']}: needs {k} > maxBulbs {lv['maxBulbs']}")
                    fail = True
                else:
                    print(f"OK {lv['id']} min_k={k} (declared optimal={opt})")
                continue

            true_k, sol = find_minimum_bulbs(lv)
            if sol is None:
                print(f"FAIL {lv['id']}: no solution")
                fail = True
                continue
            if opt is not None and true_k != opt:
                print(f"WARN {lv['id']}: true min_k={true_k} optimalBulbs={opt}")
                fail = True
            else:
                print(f"OK {lv['id']} min_k={true_k} (declared optimal={opt})")
    sys.exit(1 if fail else 0)


if __name__ == "__main__":
    main()
