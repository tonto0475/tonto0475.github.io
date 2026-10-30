#!/usr/bin/env bash
# ======= 작업 패키지 설치 — 지금 폴더 아래 kit/ 에 풀기만 한다 =======
# 대회 IDE 터미널에서: cd <과제 폴더> && curl -sL tonto0475.github.io/k | bash
# 이 파일을 GitHub Pages 저장소(tonto0475.github.io)에 «k» 라는 이름으로 복사해 둔다
# 대회 파일은 건드리지 않는다 — 어느 문서를 어디에 둘지는 Codex 세션과 정한 뒤 직접 옮긴다
set -eu

# ======= 설정 — 환경변수로 바꿀 수 있다(시험할 때 KIT_URL 에 file:// 주소) =======
REPO="tonto0475/Personal_kit"
BRANCH="main"
DEST="${KIT_DIR:-kit}"
URL="${KIT_URL:-https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz}"

# ======= 이미 있으면 멈춘다 — 손댄 kit 을 덮어쓰지 않기 위해 =======
if [ -e "$DEST" ]; then
    echo "중단: $PWD/$DEST 가 이미 있음 (덮어쓰지 않음)"
    exit 1
fi

# ======= 임시 폴더에 받아 푼 뒤 한 번에 옮긴다 — 실패해도 반쯤 풀린 폴더가 남지 않게 =======
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if ! curl -fsSL --connect-timeout 15 "$URL" -o "$TMP/kit.tar.gz"; then
    echo "받기 실패: $URL (네트워크 차단 · 저장소 비공개 · 주소 오타 확인)"
    exit 1
fi

mkdir "$TMP/x"
# 압축판 맨 위 폴더(Personal_kit-main/)를 벗겨 kit/ 바로 아래에 파일이 오게 한다
if ! tar xzf "$TMP/kit.tar.gz" -C "$TMP/x" --strip-components=1; then
    echo "압축 풀기 실패: $URL"
    exit 1
fi

mv "$TMP/x" "$DEST"
echo "설치 위치: $PWD/$DEST · 파일 $(find "$DEST" -type f | wc -l)개"

# ======= 키트 = 작업 폴더 — Codex 를 키트에서 띄우면 키트 AGENTS · .agents/skills 가 실린다(0.163 실측) =======
# 그래서 스킬을 ~/.codex/skills 로 복사하지 않는다(같은 이름이 두 곳에 있으면 «$이름» 이 옛 사본을 부를 수 있다)
# 유저는 예전처럼 codex 만 친다 — ~/.bashrc 의 codex 함수가 «-C 키트 --add-dir 루트» 를 붙인다(resume · fork 도 · 그 밖 하위 명령은 그대로)
K="$PWD/$DEST"; R="$PWD"
if ! grep -q "# >>> 키트 codex" "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<BLOCK
# >>> 키트 codex — codex 를 치면 키트(작업 폴더)에서 띄우고 루트에도 쓰게(설치 한 줄이 넣음)
codex() {
  case "\${1:-}" in
    resume|fork) local s="\$1"; shift; command codex "\$s" -C "$K" --add-dir "$R" "\$@" ;;
    exec|e|review|login|logout|mcp|plugin|app-server|remote-control|completion|update|doctor|sandbox|debug|apply|a|queue|archive|delete|migrate-rollouts|unarchive|cloud|exec-server|features|help|agents) command codex "\$@" ;;
    *) command codex -C "$K" --add-dir "$R" "\$@" ;;
  esac
}
# <<< 키트 codex
BLOCK
    echo "codex 함수 등록 → ~/.bashrc (새 탭부터 · 키트에서 뜨고 루트에도 씀)"
else
    echo "codex 함수 이미 있음(~/.bashrc · 키트 경로가 바뀌었으면 그 블록을 지우고 다시 설치)"
fi
echo "다음: 새 터미널 탭에서 codex → \$ready-start  ← 환경 세팅 · git 등록 + MAIN 재시작 · INSP · 2ND 띄우기 명령"
