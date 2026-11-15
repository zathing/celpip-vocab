#!/bin/bash
# 用 macOS 自带的 say 命令，把 1131 个例句生成 m4a 录音，放到 audio/ex/ 目录
# 用法：在仓库根目录运行  bash make_audio.sh            （默认用 Ava 高品质）
#       或指定语音        bash make_audio.sh "Zoe (Premium)"
set -e
VOICE="${1:-Ava (Premium)}"
RATE="${RATE:-170}"   # 语速（每分钟词数），默认 170，想慢一点可以 RATE=150 bash make_audio.sh

if ! say -v '?' | grep -q "^${VOICE} "; then
  echo "找不到语音：${VOICE}"
  echo "已安装的英语语音有："
  say -v '?' | grep -E 'en_(US|CA|GB)' | sed 's/  .*#/  #/'
  echo "请到 系统设置 → 辅助功能 → 朗读内容 → 系统嗓音 → 管理嗓音 下载，或者换一个名字再运行。"
  exit 1
fi

mkdir -p audio/ex
TMP="$(mktemp -t celpip).aiff"
total=$(wc -l < sentences.tsv | tr -d ' ')
n=0; made=0
while IFS=$'\t' read -r slug text; do
  n=$((n+1))
  out="audio/ex/${slug}.m4a"
  if [ -s "$out" ]; then continue; fi
  say -v "$VOICE" -r "$RATE" -o "$TMP" -- "$text"
  afconvert -f m4af -d aac -b 40000 "$TMP" "$out" >/dev/null
  made=$((made+1))
  printf "\r%d / %d" "$n" "$total"
done < sentences.tsv
rm -f "$TMP"
echo
echo "完成：新生成 ${made} 个文件，保存在 audio/ex/ 目录。"
du -sh audio/ex
