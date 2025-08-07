#!/bin/bash
# 自动查找可用的 Android NDK 并优先使用 r25 或 r26。

# 如果未设置 ANDROID_HOME，则从常见路径推断
if [ -z "$ANDROID_HOME" ]; then
  if [ -d "$HOME/Android/Sdk" ]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
  elif [ -d "$HOME/.local/lib/android/sdk" ]; then
    export ANDROID_HOME="$HOME/.local/lib/android/sdk"
  elif [ -d "$HOME/Library/Android/sdk" ]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
  fi
fi

# 尝试使用预设的 r25 目录
_NDK="$ANDROID_HOME/ndk/25.0.8775105"
[ -f "$_NDK/source.properties" ] || _NDK="$ANDROID_NDK_HOME"
[ -f "$_NDK/source.properties" ] || _NDK="$NDK"
[ -f "$_NDK/source.properties" ] || _NDK="$ANDROID_HOME/ndk-bundle"

# 如果上述路径不存在，则遍历 $ANDROID_HOME/ndk，优先选 r25 或 r26
if [ ! -f "$_NDK/source.properties" ] && [ -d "$ANDROID_HOME/ndk" ]; then
  preferred=""
  for candidate in "$ANDROID_HOME"/ndk/*; do
    base=$(basename "$candidate")
    if [[ $base == 25.* || $base == 26.* ]]; then
      if [ -f "$candidate/source.properties" ]; then
      preferred="$candidate"
      break
      fi
    fi
  done
  if [ -n "$preferred" ]; then
    _NDK="$preferred"
  else
    # 如果没有 r25/r26，则选第一个存在的版本
    for candidate in "$ANDROID_HOME"/ndk/*; do
      if [ -f "$candidate/source.properties" ]; then
      _NDK="$candidate"
      break
      fi
    done
  fi
fi

# 如果还没找到有效 NDK，报错退出
if [ ! -f "$_NDK/source.properties" ]; then
  echo "Error: NDK not found. Please install an Android NDK and set ANDROID_NDK_HOME or NDK."
  exit 1
fi

# 导出环境变量
export ANDROID_NDK_HOME="$_NDK"
export NDK="$_NDK"
