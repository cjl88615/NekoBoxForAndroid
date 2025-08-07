#!/bin/bash
# 自动查找可用 Android NDK，优先 r25/r26，找不到就用任何存在的版本。

# ① 解析 ANDROID_HOME（GitHub runner 已预装）
if [ -z "$ANDROID_HOME" ]; then
  for path in "$HOME/Android/Sdk" "$HOME/.local/lib/android/sdk" "$HOME/Library/Android/sdk"; do
    [ -d "$path" ] && export ANDROID_HOME="$path" && break
  done
fi

# ② 按顺序尝试常见路径（先硬编码 r25c）
_NDK="$ANDROID_HOME/ndk/25.2.9519653"      # r25c
[ -f "$_NDK/source.properties" ] || _NDK="$ANDROID_NDK_HOME"
[ -f "$_NDK/source.properties" ] || _NDK="$NDK"
[ -f "$_NDK/source.properties" ] || _NDK="$ANDROID_HOME/ndk-bundle"

# ③ 遍历 $ANDROID_HOME/ndk，优先 r25 / r26
if [ ! -f "$_NDK/source.properties" ] && [ -d "$ANDROID_HOME/ndk" ]; then
  for candidate in "$ANDROID_HOME"/ndk/*; do
    base=$(basename "$candidate")
    if [[ $base == 25.* || $base == 26.* ]] && [ -f "$candidate/source.properties" ]; then
      _NDK="$candidate"
      break
    fi
  done
  # 再找不到就随便挑一个
  if [ ! -f "$_NDK/source.properties" ]; then
    _NDK=$(find "$ANDROID_HOME/ndk" -maxdepth 1 -type d -printf '%P\n' | sort -V | head -n1)
    _NDK="$ANDROID_HOME/ndk/${_NDK}"
  fi
fi

# ④ 仍然失败就报错
if [ ! -f "$_NDK/source.properties" ]; then
  echo "Error: Android NDK not found, please install via sdkmanager."
  exit 1
fi

export ANDROID_NDK_HOME="$_NDK"
export NDK="$_NDK"
echo "Using NDK at $_NDK"
