#!/bin/bash
set -euo pipefail

# 检测中文翻译(zh.json)与英文(en.json)的 key 差异。
# 用于跟随上游更新后同步翻译，或 CI 中校验翻译完整性。
#
# 用法: ./scripts/check-zh-locale.sh
# 退出码:
#   0 = zh.json 与 en.json 完全一致
#   1 = 存在缺失或多余的 key
#   2 = 找不到语言文件

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
EN_FILE="$PROJECT_DIR/dashboard/messages/en.json"
ZH_FILE="$PROJECT_DIR/dashboard/messages/zh.json"

if [ ! -f "$EN_FILE" ] || [ ! -f "$ZH_FILE" ]; then
  echo "[ERROR] 找不到语言文件: $EN_FILE 或 $ZH_FILE" >&2
  exit 2
fi

python3 - "$EN_FILE" "$ZH_FILE" <<'PYEOF'
import json
import sys


def flat(d, prefix=""):
    out = {}
    for k, v in d.items():
        if isinstance(v, dict):
            out.update(flat(v, prefix + k + "."))
        else:
            out[prefix + k] = v
    return out


en = flat(json.load(open(sys.argv[1], encoding="utf-8")))
zh = flat(json.load(open(sys.argv[2], encoding="utf-8")))

missing = [k for k in en if k not in zh]
extra = [k for k in zh if k not in en]

print(f"en keys: {len(en)}, zh keys: {len(zh)}")

if missing:
    print(f"[WARN] zh.json 缺失 {len(missing)} 个 key:")
    for k in missing:
        print(f"  - {k}")
if extra:
    print(f"[WARN] zh.json 多余 {len(extra)} 个 key:")
    for k in extra:
        print(f"  - {k}")

if not missing and not extra:
    print("[OK] zh.json 与 en.json 完全一致")
    sys.exit(0)

print("[FAIL] 存在 key 差异，请同步更新 zh.json")
sys.exit(1)
PYEOF
