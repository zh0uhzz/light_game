#!/usr/bin/env python3
"""重建 levels_pack_01.json：ch1–4 保留并规范化；ch5–10 开阔盘面、少障碍、重算最优盏数（少占目标格）。"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
import verify_cross_pack as V  # noqa: E402

DATA = ROOT / "LightGame" / "Data" / "levels_pack_01.json"

TITLES: dict[str, str] = {}
for i, t in enumerate(
    "晨光初绽 十字流金 角隅补白 径深寻光 独焰照台 五星连珠 回廊叠影 八方来宵 稳收余芒".split(),
    start=1,
):
    TITLES[f"ch1_l{i}"] = t
for i, t in enumerate(
    "双灯衡势 三辉并立 四角巡礼 中轴明辨 外环点灯 内需省盏 斜势借辉 八纹织夜 归位收波".split(),
    start=1,
):
    TITLES[f"ch2_l{i}"] = t
for i, t in enumerate(
    "镜启微芒 斜辉引路 蛇行折耀 双镜对语 镜阵叠嶂 轻刃破障 幽廊返照 复式回光 压心终焰".split(),
    start=1,
):
    TITLES[f"ch3_l{i}"] = t
for i, t in enumerate(
    "初镜明心 单折试刃 破局寻隙 回字藏灯 镜语长篇 简映一隅 双轴谐振 偏轴续章 收官留芒".split(),
    start=1,
):
    TITLES[f"ch4_l{i}"] = t


def P(r, c):
    return {"row": r, "col": c}


def M(r, c, d):
    return {"row": r, "col": c, "direction": d}


def finalize_open(
    lid: str,
    cid: str,
    title: str,
    n: int,
    blocked: list[tuple[int, int]],
    targets: list[tuple[int, int]],
    mirrors: list[tuple[int, int, str]],
    slits: list[tuple[int, int]],
    rank: int,
) -> dict:
    assert len(title) == 4, title
    lv = {
        "id": lid,
        "chapterId": cid,
        "title": title,
        "gridSize": n,
        "radiusSet": [1.0],
        "blockedCells": [P(r, c) for r, c in blocked],
        "targetMask": [P(r, c) for r, c in targets],
        "mirrorCells": [M(r, c, d) for r, c, d in mirrors],
        "slitMirrorCells": [P(r, c) for r, c in slits],
    }
    mk, _ = V.find_minimum_bulbs(lv)
    if mk is None:
        raise RuntimeError(f"unsolvable: {lid}")
    cand_n = len(V.bulb_candidates(lv))
    if cand_n > 26:
        print("WARN", lid, "candidates", cand_n, file=sys.stderr)
    lv["optimalBulbs"] = mk
    lv["maxBulbs"] = mk
    lv["parScore"] = mk
    lv["difficultyRank"] = rank
    return lv


def corners_tiny(n: int) -> list[tuple[int, int]]:
    return [(0, 0), (0, n - 1), (n - 1, 0), (n - 1, n - 1)]


def normalize_ch1_to_4(level: dict, rank: int) -> dict:
    lv = copy.deepcopy(level)
    lv.pop("glassCells", None)
    tid = lv.get("id", "")
    if tid in TITLES:
        lv["title"] = TITLES[tid]
    lv["difficultyRank"] = rank
    return lv


def chapters_5_to_10() -> list[dict]:
    """开阔关：少量障碍；每章 9 关，第十章仅 1 关终章。"""
    rank0 = 37
    out: list[dict] = []

    # ch5 折射为主（缝镜），n=7，四角障碍或全空
    ch5 = [
        ("缝光初晓", 7, corners_tiny(7), [(3, 2), (3, 4)], [], [(3, 3)]),
        ("双侧借辉", 7, [], [(2, 1), (2, 5), (4, 1), (4, 5)], [], [(3, 3)]),
        ("廊角微明", 7, [(0, 3), (6, 3)], [(1, 1), (5, 5)], [], [(3, 3)]),
        ("折射换向", 7, [], [(3, 0), (3, 6), (1, 3)], [], [(3, 2)]),
        ("窄门通光", 7, [(1, 1), (1, 5)], [(2, 3), (4, 3), (3, 0)], [], [(3, 4)]),
        ("断续明线", 7, [], [(3, 1), (3, 5), (1, 4)], [], [(3, 3)]),
        ("边缝引渡", 7, corners_tiny(7), [(3, 1), (5, 5)], [], [(3, 2)]),
        ("浅滩分流", 7, [], [(2, 2), (2, 4), (4, 3)], [], [(3, 3)]),
        ("收束微光", 7, [], [(0, 2), (6, 4), (3, 6)], [], [(3, 3)]),
    ]
    for i, (tit, n, blk, tgt, mir, sl) in enumerate(ch5, start=1):
        out.append(finalize_open(f"ch5_l{i}", "ch5", tit, n, blk, tgt, mir, sl, rank0 + i - 1))

    ch6 = [
        ("镜缝合鸣", 7, [(1, 1)], [(2, 4), (4, 2)], [(3, 3, "up")], [(3, 2)]),
        ("折缝并进", 7, [], [(1, 3), (5, 3), (3, 5)], [(2, 2, "right")], [(3, 3)]),
        ("斜晖穿缝", 7, corners_tiny(7), [(2, 4), (4, 4)], [(4, 3, "left")], [(3, 3)]),
        ("回波借缝", 7, [], [(1, 1), (5, 5), (3, 0)], [(3, 4, "down")], [(3, 2)]),
        ("双边镜缝", 7, [], [(2, 0), (2, 6), (4, 3)], [(3, 1, "up"), (3, 5, "up")], [(3, 3)]),
        ("幽角叠照", 7, [(0, 0), (6, 6)], [(1, 4), (4, 1)], [(2, 3, "right")], [(3, 3)]),
        ("镜语透水", 7, [], [(0, 3), (6, 3), (3, 6)], [(3, 1, "right")], [(3, 4)]),
        ("远端借辉", 7, [], [(2, 2), (4, 2), (3, 5)], [(3, 2, "down")], [(3, 4)]),
        ("镜缝小歇", 7, [], [(1, 2), (5, 4), (2, 5)], [(4, 2, "left")], [(3, 3)]),
    ]
    for i, (tit, n, blk, tgt, mir, sl) in enumerate(ch6, start=1):
        out.append(finalize_open(f"ch6_l{i}", "ch6", tit, n, blk, tgt, mir, sl, rank0 + 9 + i - 1))

    ch7 = [
        ("迷宫浅影", 8, [(2, 2), (1, 5)], [(0, 3), (7, 4), (4, 7), (3, 0)], [(5, 3, "up")], [(3, 4)]),
        ("三缝叠序", 8, [], [(2, 2), (2, 5), (5, 5)], [], [(4, 3), (4, 4)]),
        ("镜阵微开", 8, [(0, 0)], [(3, 2), (5, 6), (7, 3)], [(2, 4, "right"), (6, 4, "left")], [(4, 3)]),
        ("边灯下注", 8, corners_tiny(8), [(1, 1), (6, 6), (4, 4)], [(3, 3, "down")], [(4, 4)]),
        ("隙光长跑", 8, [], [(1, 4), (6, 2), (3, 7)], [(4, 4, "up")], [(4, 2)]),
        ("十字镜缝", 8, [(3, 3)], [(2, 6), (5, 1), (0, 4)], [(3, 5, "right")], [(4, 4)]),
        ("暗桩反光", 8, [], [(2, 3), (5, 5), (6, 0)], [(1, 4, "left"), (4, 2, "up")], [(3, 4)]),
        ("浮城折线", 8, [(1, 6)], [(0, 2), (7, 5), (3, 3)], [(5, 4, "down")], [(4, 3)]),
        ("迷宫尾声", 8, [], [(2, 1), (5, 6), (4, 0), (3, 7)], [(3, 2, "right")], [(4, 4)]),
    ]
    for i, (tit, n, blk, tgt, mir, sl) in enumerate(ch7, start=1):
        out.append(finalize_open(f"ch7_l{i}", "ch7", tit, n, blk, tgt, mir, sl, rank0 + 18 + i - 1))

    ch8 = [
        ("星云初布", 8, [], [(1, 1), (2, 6), (6, 2), (5, 5)], [], [(4, 3)]),
        ("广域一缝", 8, corners_tiny(8), [(2, 2), (2, 5), (5, 3), (6, 6)], [(3, 3, "up")], [(4, 4)]),
        ("双镜护航", 8, [(4, 4)], [(0, 4), (7, 3), (3, 0)], [(2, 3, "right"), (5, 4, "left")], [(4, 3)]),
        ("遥角点灯", 8, [], [(0, 0), (0, 7), (7, 0), (4, 4)], [(3, 5, "down")], [(4, 2)]),
        ("深空折返", 8, [(2, 4), (5, 2)], [(1, 2), (6, 5), (3, 7)], [(4, 3, "up")], [(3, 4)]),
        ("疏星长卷", 8, [], [(1, 3), (3, 6), (5, 1), (6, 4), (0, 6)], [(2, 2, "left")], [(4, 4)]),
        ("光楔穿心", 8, [(3, 2)], [(2, 7), (5, 0), (7, 4)], [(4, 4, "right")], [(4, 5)]),
        ("域外回风", 8, corners_tiny(8), [(2, 4), (4, 6), (5, 3)], [(1, 4, "right"), (6, 3, "left")], [(4, 4)]),
        ("星潮散尽", 8, [], [(2, 1), (5, 6), (3, 3), (1, 7), (6, 0)], [(4, 2, "down")], [(4, 5)]),
    ]
    for i, (tit, n, blk, tgt, mir, sl) in enumerate(ch8, start=1):
        out.append(finalize_open(f"ch8_l{i}", "ch8", tit, n, blk, tgt, mir, sl, rank0 + 27 + i - 1))

    ch9 = [
        ("极轨试炼", 8, [(3, 3), (4, 4)], [(0, 2), (7, 5), (2, 7), (5, 0)], [(2, 4, "up")], [(4, 3)]),
        ("镂光迷宫", 8, [], [(1, 2), (2, 5), (5, 4), (6, 1), (4, 7)], [(3, 4, "right")], [(4, 4)]),
        ("双缝竞速", 8, [], [(2, 3), (5, 5), (3, 0), (4, 7)], [], [(3, 4), (4, 3)]),
        ("镜渊倒影", 8, corners_tiny(8), [(2, 2), (5, 5), (0, 5), (7, 2)], [(3, 5, "left"), (4, 2, "right")], [(3, 3)]),
        ("寂夜将曙", 8, [(1, 4)], [(0, 0), (7, 7), (3, 6), (4, 1), (2, 2)], [(5, 3, "down")], [(3, 4)]),
        ("终点前奏", 8, [], [(1, 6), (6, 1), (4, 0), (3, 7), (0, 4)], [(2, 3, "right"), (5, 4, "left")], [(4, 4)]),
        ("碎镜拼图", 8, [(2, 6), (5, 1)], [(2, 1), (5, 6), (0, 3), (7, 4)], [(3, 3, "up")], [(4, 4)]),
        ("朔光余响", 8, [], [(2, 4), (4, 2), (5, 7), (3, 1), (6, 5)], [(1, 3, "left")], [(4, 3)]),
        ("冕光自许", 8, [], [(1, 1), (1, 6), (6, 1), (6, 6), (4, 4)], [(3, 2, "right")], [(4, 5)]),
    ]
    for i, (tit, n, blk, tgt, mir, sl) in enumerate(ch9, start=1):
        out.append(finalize_open(f"ch9_l{i}", "ch9", tit, n, blk, tgt, mir, sl, rank0 + 36 + i - 1))

    ch10 = finalize_open(
        "ch10_l1",
        "ch10",
        "话唠小灯",
        8,
        [(2, 2), (2, 5), (5, 2), (5, 5)],
        [(4, 4)],
        [(3, 4, "right"), (4, 3, "up")],
        [(3, 3)],
        rank0 + 45,
    )
    out.append(ch10)
    return out


def main():
    data = json.loads(DATA.read_text())
    new_chapters = []
    r = 1
    for ch in data["chapters"]:
        cid = ch["id"]
        if cid in ("ch1", "ch2", "ch3", "ch4"):
            levels = [normalize_ch1_to_4(l, r + i) for i, l in enumerate(ch["levels"])]
            r += len(levels)
            new_chapters.append({"id": cid, "title": ch["title"], "levels": levels})
        elif cid == "ch5":
            rest = chapters_5_to_10()
            new_chapters.append({"id": "ch5", "title": ch["title"], "levels": rest[:9]})
            new_chapters.append({"id": "ch6", "title": "第六章 镜缝", "levels": rest[9:18]})
            new_chapters.append({"id": "ch7", "title": "第七章 迷宫", "levels": rest[18:27]})
            new_chapters.append({"id": "ch8", "title": "第八章 星野无际", "levels": rest[27:36]})
            new_chapters.append({"id": "ch9", "title": "第九章 幽渊试刃", "levels": rest[36:45]})
            new_chapters.append({"id": "ch10", "title": "第十章 心门", "levels": [rest[45]]})
            break
        else:
            continue

    out = {"chapters": new_chapters}
    DATA.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    print("Wrote", DATA, "chapters", len(new_chapters))


if __name__ == "__main__":
    main()
