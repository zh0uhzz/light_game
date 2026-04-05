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


def extend_7_board_to_8(
    blocked: list[tuple[int, int]],
    targets: list[tuple[int, int]],
    mirrors: list[tuple[int, int, str]],
    slits: list[tuple[int, int]],
) -> tuple[int, list[tuple[int, int]], list[tuple[int, int]], list[tuple[int, int, str]], list[tuple[int, int]]]:
    """在 7×7 盘面下方与右侧收紧一口，升成 8×8（与原先第六章尺度衔接）。"""
    extra = {(7, c) for c in range(8) if c != 3} | {(r, 7) for r in range(7)}
    blocked2 = list(dict.fromkeys(list(blocked) + sorted(extra)))
    return 8, blocked2, targets, mirrors, slits


def flip_h_7(
    blocked: list[tuple[int, int]],
    targets: list[tuple[int, int]],
    mirrors: list[tuple[int, int, str]],
    slits: list[tuple[int, int]],
) -> tuple[list[tuple[int, int]], list[tuple[int, int]], list[tuple[int, int, str]], list[tuple[int, int]]]:
    """水平翻转 7×7 内坐标：c' = 6 − c；镜面左右互换。"""
    w = 6

    def fc(c: int) -> int:
        return w - c

    dh = {"left": "right", "right": "left", "up": "up", "down": "down"}
    return (
        [(r, fc(c)) for r, c in blocked],
        [(r, fc(c)) for r, c in targets],
        [(r, fc(c), dh[d]) for r, c, d in mirrors],
        [(r, fc(c)) for r, c in slits],
    )


def flip_v_7(
    blocked: list[tuple[int, int]],
    targets: list[tuple[int, int]],
    mirrors: list[tuple[int, int, str]],
    slits: list[tuple[int, int]],
) -> tuple[list[tuple[int, int]], list[tuple[int, int]], list[tuple[int, int, str]], list[tuple[int, int]]]:
    """垂直翻转 7×7：r' = 6 − r；镜面上下互换。"""
    h = 6

    def fr(r: int) -> int:
        return h - r

    dv = {"up": "down", "down": "up", "left": "left", "right": "right"}
    return (
        [(fr(r), c) for r, c in blocked],
        [(fr(r), c) for r, c in targets],
        [(fr(r), c, dv[d]) for r, c, d in mirrors],
        [(fr(r), c) for r, c in slits],
    )


def flip_h_coords(coords: list[tuple[int, int]]) -> list[tuple[int, int]]:
    w = 6
    return [(r, w - c) for r, c in coords]


def flip_v_coords(coords: list[tuple[int, int]]) -> list[tuple[int, int]]:
    h = 6
    return [(h - r, c) for r, c in coords]


def thin_blocks_ch789(blocked: list[tuple[int, int]]) -> list[tuple[int, int]]:
    """约去掉 80% 障碍：排序后每 5 格留 1 格（确定性）；至少保留 1 格（若有墙）。"""
    if not blocked:
        return blocked
    s = sorted(set(blocked))
    kept = s[::5]
    return kept if kept else [s[0]]


def assert_ch789_coop(lv: dict, lid: str) -> None:
    """第 7–9 章：须同时有镜与缝；且去掉缝侧传后最优盏数严格变大（与第六章缝断言一致）。"""
    cid = lv["chapterId"]
    if cid not in ("ch7", "ch8", "ch9"):
        return
    if not lv.get("mirrorCells"):
        raise RuntimeError(f"{lid}: ch7–9 需要镜面格")
    if not lv.get("slitMirrorCells"):
        raise RuntimeError(f"{lid}: ch7–9 需要折射缝格")
    mk, _ = V.find_minimum_bulbs(lv)
    lv_ns = copy.deepcopy(lv)
    lv_ns["slitMirrorCells"] = []
    mk_ns, _ = V.find_minimum_bulbs(lv_ns)
    if mk_ns is not None and mk_ns <= mk:
        raise RuntimeError(f"{lid}: ch7–9 折射必须压低最优盏数 with_slit={mk} no_slit={mk_ns}")


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
    if cid == "ch6" and lv.get("slitMirrorCells"):
        lv_ns = copy.deepcopy(lv)
        lv_ns["slitMirrorCells"] = []
        mk_ns, _ = V.find_minimum_bulbs(lv_ns)
        if mk_ns is not None and mk_ns <= mk:
            raise RuntimeError(f"ch6 slit must strictly lower min bulbs: {lid} with_slit={mk} no_slit={mk_ns}")
    assert_ch789_coop(lv, lid)
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


def frame7_edge(inner: list[tuple[int, int]]) -> list[tuple[int, int]]:
    """7×7 整圈外墙障碍 + 内部障碍（用于收窄可走区域、突出缝传播）。"""
    perim = [(r, c) for r in range(7) for c in range(7) if r in (0, 6) or c in (0, 6)]
    return perim + list(inner)


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

    # 第六章：优解盏数在「去掉缝传播」后严格变大，保证必须理解缝的侧向传递；后三关最小盏数更高。
    ch6 = [
        ("缝框借穿", 7, frame7_edge([(1, 1), (1, 3), (1, 4), (1, 5)]), [(1, 2), (2, 1), (3, 2), (3, 4), (4, 2)], [], [(3, 3)]),
        # 与 l1 同迷宫框 + 单镜；单侧反射下折射仍严格省盏（旧版 l2 在镜门放宽后不再满足缝断言）
        (
            "单镜渡隙",
            7,
            frame7_edge([(1, 1), (1, 3), (1, 4), (1, 5)]),
            [(1, 2), (2, 1), (3, 2), (3, 4), (4, 2)],
            [(5, 4, "left")],
            [(3, 3)],
        ),
        ("双镜分辉", 7, [(2, 2), (4, 2)], [(1, 5), (3, 1), (3, 5), (4, 3)], [(1, 3, "up"), (5, 1, "down")], [(3, 2)]),
        ("三镜联防", 7, [(1, 2), (1, 5), (3, 3), (4, 1), (5, 3)], [(1, 3), (2, 1), (2, 4), (4, 5), (5, 5)], [(4, 3, "left"), (5, 1, "left"), (3, 2, "left")], [(2, 2)]),
        # 原「四镜」布局在镜门放宽后缝不再严格必需；改为同框双镜关并更名（高难度版仍见第七章 MS_L5）
        (
            "双镜借缝",
            7,
            frame7_edge([(1, 1), (1, 3), (1, 4), (1, 5)]),
            [(1, 2), (2, 1), (3, 2), (3, 4), (4, 2)],
            [(4, 2, "down"), (2, 5, "left")],
            [(3, 3)],
        ),
        ("狭缝深演", 7, [(1, 1), (2, 1), (3, 3), (3, 4), (3, 5), (5, 5)], [(1, 5), (3, 2), (4, 4), (5, 2)], [], [(4, 3)]),
        ("三灯穿缝", 7, [(1, 1), (2, 4), (4, 4)], [(3, 1), (3, 4), (5, 2), (5, 3), (5, 5)], [(1, 3, "down"), (2, 3, "up"), (4, 1, "down"), (4, 2, "left")], [(5, 4)]),
        ("镜缝交响", 7, [(1, 3), (2, 1), (2, 3), (4, 1), (5, 3)], [(3, 1), (3, 5), (4, 3), (5, 1)], [(1, 1, "left"), (2, 2, "down")], [(3, 4)]),
        ("终试冕光", 7, [(1, 4), (2, 4), (3, 2), (3, 3), (3, 4), (4, 1), (4, 3)], [(2, 2), (3, 5), (4, 4), (5, 1), (5, 4)], [(1, 1, "down")], [(5, 2)]),
    ]
    for i, (tit, n, blk, tgt, mir, sl) in enumerate(ch6, start=1):
        out.append(finalize_open(f"ch6_l{i}", "ch6", tit, n, blk, tgt, mir, sl, rank0 + 9 + i - 1))

    # 第六章中含「镜 + 缝」的母版；升 8×8 后用于 7–9 章（更高障碍与多镜配合）。
    # MS_L2 与现 ch6_l2 一致（迷宫框 + 单镜），升维后仍满足「去缝则最优盏数严格变大」。
    MS_L2 = (
        frame7_edge([(1, 1), (1, 3), (1, 4), (1, 5)]),
        [(1, 2), (2, 1), (3, 2), (3, 4), (4, 2)],
        [(5, 4, "left")],
        [(3, 3)],
    )
    MS_L3 = (
        [(2, 2), (4, 2)],
        [(1, 5), (3, 1), (3, 5), (4, 3)],
        [(1, 3, "up"), (5, 1, "down")],
        [(3, 2)],
    )
    MS_L4 = (
        [(1, 2), (1, 5), (3, 3), (4, 1), (5, 3)],
        [(1, 3), (2, 1), (2, 4), (4, 5), (5, 5)],
        [(4, 3, "left"), (5, 1, "left"), (3, 2, "left")],
        [(2, 2)],
    )
    # 与现 ch6_l5 一致（迷宫框 + 双镜）；旧四镜母版在镜门放宽后去缝仍同优，已弃用。
    MS_L5 = (
        frame7_edge([(1, 1), (1, 3), (1, 4), (1, 5)]),
        [(1, 2), (2, 1), (3, 2), (3, 4), (4, 2)],
        [(4, 2, "down"), (2, 5, "left")],
        [(3, 3)],
    )
    MS_L7 = (
        [(1, 1), (2, 4), (4, 4)],
        [(3, 1), (3, 4), (5, 2), (5, 3), (5, 5)],
        [(1, 3, "down"), (2, 3, "up"), (4, 1, "down"), (4, 2, "left")],
        [(5, 4)],
    )
    MS_L8 = (
        [(1, 3), (2, 1), (2, 3), (4, 1), (5, 3)],
        [(3, 1), (3, 5), (4, 3), (5, 1)],
        [(1, 1, "left"), (2, 2, "down")],
        [(3, 4)],
    )
    MS_L9 = (
        [(1, 4), (2, 4), (3, 2), (3, 3), (3, 4), (4, 1), (4, 3)],
        [(2, 2), (3, 5), (4, 4), (5, 1), (5, 4)],
        [(1, 1, "down")],
        [(5, 2)],
    )

    # 加障后在 8×8 上仍保持「去缝则最优盏数严格变大」（旧版加障曾出现 4/4 持平）
    L8_HARD_EXTRA = [(6, 4), (1, 2), (4, 5), (6, 0), (0, 4)]
    L5_HARD_EXTRA = [(2, 2), (0, 6), (6, 2), (2, 0), (0, 4), (0, 2)]
    L9_HARD_EXTRA = [(4, 6), (6, 2), (2, 5), (5, 0), (6, 6)]

    ch7_plan: list[tuple[str, tuple, list[tuple[int, int]] | None]] = [
        ("迁镜渡缝", MS_L2, None),
        ("双折偕行", MS_L3, None),
        ("三镜再演", MS_L4, None),
        ("四折深阱", MS_L5, None),
        ("三灯长缝", MS_L7, None),
        ("交响续章", MS_L8, None),
        ("冕光迁格", MS_L9, None),
        ("叠障穿心", MS_L8, L8_HARD_EXTRA),
        ("碎阱多镜", MS_L5, L5_HARD_EXTRA),
    ]

    def emit_chapter(
        cid: str, plan: list[tuple[str, tuple, list[tuple[int, int]] | None]], rank_base: int, xform
    ) -> None:
        for i, (tit, core, extra) in enumerate(plan, start=1):
            blk, tg, mir, sl = xform(core)
            if extra is not None:
                blk = list(dict.fromkeys(list(blk) + list(extra)))
            n, blk, tg, mir, sl = extend_7_board_to_8(blk, tg, mir, sl)
            blk = thin_blocks_ch789(blk)
            out.append(finalize_open(f"{cid}_l{i}", cid, tit, n, blk, tg, mir, sl, rank_base + i - 1))

    emit_chapter("ch7", ch7_plan, rank0 + 18, lambda core: core)

    ch8_plan: list[tuple[str, tuple, list[tuple[int, int]] | None]] = [
        ("影廊迁镜", MS_L2, None),
        ("双线偕辉", MS_L3, None),
        ("墙阵镜迂", MS_L4, None),
        ("迂回深阱", MS_L5, None),
        ("长缝三引", MS_L7, None),
        ("变奏交响", MS_L8, None),
        ("侧移冕光", MS_L9, None),
        ("穿心高墙", MS_L8, flip_h_coords(L8_HARD_EXTRA)),
        ("碎光争鸣", MS_L5, flip_h_coords(L5_HARD_EXTRA)),
    ]

    def xf_h(core: tuple) -> tuple:
        return flip_h_7(*core)

    emit_chapter("ch8", ch8_plan, rank0 + 27, xf_h)

    ch9_plan: list[tuple[str, tuple, list[tuple[int, int]] | None]] = [
        ("渊折镜渡", MS_L2, None),
        ("偕行缝引", MS_L3, None),
        ("镜阱重布", MS_L4, None),
        ("四折深底", MS_L5, None),
        ("三引缝潮", MS_L7, None),
        ("交响变盘", MS_L8, None),
        ("冕环旁照", MS_L9, None),
        ("叠幕连心", MS_L8, flip_v_coords(L8_HARD_EXTRA)),
        ("镜脊分流", MS_L9, flip_v_coords(L9_HARD_EXTRA)),
    ]

    def xf_v(core: tuple) -> tuple:
        return flip_v_7(*core)

    emit_chapter("ch9", ch9_plan, rank0 + 36, xf_v)

    ch10 = finalize_open(
        "ch10_l1",
        "ch10",
        "话唠小灯",
        5,
        [],
        [(2, 2)],
        [],
        [],
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
            new_chapters.append({"id": "ch6", "title": "第六章 折射与反射", "levels": rest[9:18]})
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
