#!/usr/bin/env python3
"""每章扩至 9 关：第 6–9 关由本关前 4 关克隆（新 id/标题），难度 rank 按章节内 1–9 与全局递增。"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
import verify_cross_pack as V

# (新 id 后缀, 新标题, 克隆源关卡 id 后缀)
APPEND_PLAN: dict[str, list[tuple[str, str, str]]] = {
    "ch1": [
        ("l6", "十字再练", "l1"),
        ("l7", "纵列再练", "l2"),
        ("l8", "角域再现", "l3"),
        ("l9", "扩建收官", "l4"),
    ],
    "ch2": [
        ("l6", "预算回放", "l1"),
        ("l7", "中线回放", "l2"),
        ("l8", "外圈回放", "l3"),
        ("l9", "菱格回放", "l4"),
    ],
    "ch3": [
        ("l6", "双障再现", "l1"),
        ("l7", "蛇形再现", "l2"),
        ("l8", "斜线再现", "l3"),
        ("l9", "压强再现", "l4"),
    ],
    "ch4": [
        ("l6", "镜面回演", "l1"),
        ("l7", "单镜回演", "l2"),
        ("l8", "双镜回演", "l3"),
        ("l9", "偏轴回演", "l4"),
    ],
}


def main():
    path = ROOT / "LightGame" / "Data" / "levels_pack_01.json"
    data = json.loads(path.read_text())

    for ch in data["chapters"]:
        cid = ch["id"]
        by_id = {lv["id"]: lv for lv in ch["levels"]}
        plan = APPEND_PLAN.get(cid, [])
        for new_suf, new_title, src_suf in plan:
            nid = f"{cid}_{new_suf}"
            sid = f"{cid}_{src_suf}"
            if nid in by_id:
                continue
            src = by_id[sid]
            lv = copy.deepcopy(src)
            lv["id"] = nid
            lv["title"] = new_title
            ch["levels"].append(lv)
            by_id[nid] = lv

    chapter_index = {f"ch{i}": i - 1 for i in range(1, 11)}
    for ch in data["chapters"]:
        ci = chapter_index.get(ch["id"], 0)
        for i, lv in enumerate(ch["levels"]):
            lv["difficultyRank"] = ci * 9 + i + 1
        nlv = len(ch["levels"])
        if ch["id"] == "ch10":
            assert nlv == 1, f"{ch['id']}: {nlv}"
        else:
            assert nlv == 9, f"{ch['id']}: {nlv}"

    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
    print("written", path)

    fail = False
    for ch in data["chapters"]:
        for lv in ch["levels"]:
            sol, k = V.min_solution_bulbs(lv)
            if sol is None:
                print("FAIL", lv["id"])
                fail = True
                continue
            chn = int("".join(c for c in lv["chapterId"] if c.isdigit()) or "1")
            if chn >= 2 and k != lv.get("optimalBulbs"):
                print("FAIL optimal", lv["id"], k, lv.get("optimalBulbs"))
                fail = True
    sys.exit(1 if fail else 0)


if __name__ == "__main__":
    main()
