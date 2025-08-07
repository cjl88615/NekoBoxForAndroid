#!/bin/bash
# 自动查找可用的 Android NDK。先尝试预设版本，如果不存在则遍历 sdk 目录。

# 如果未设置 ANDROID_HOME，则尝试从常见路径推断
if [ -z "$ANDROID_HOME" ]; then
  if [ -d "$HOME/Android/Sdk" ]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
  elif [ -d "$HOME/.local/lib/android/sdk" ]; then
    export ANDROID_HOME="$HOME/.local/lib/android/sdk"
  elif [ -d "$HOME/Library/Android/sdk" ]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
  fi
fi

# 尝试使用预设版本 25.0.8775105，如果不存在则尝试环境变量提供的路径
_NDK="$ANDROID_HOME/ndk/25.0.8775105"
[ -f "$_NDK/source.properties" ] || _NDK="$ANDROID_NDK_HOME"
[ -f "$_NDK/source.properties" ] || _NDK="$NDK"
[ -f "$_NDK/source.properties" ] || _NDK="$ANDROID_HOME/ndk-bundle"

# 如果仍旧找不到，遍历 $ANDROID_HOME/ndk 目录，选择第一个包含 source.properties 的目录
if [ ! -f "$_NDK/source.properties" ] && [ -d "$ANDROID_HOME/ndk" ]; then
  for candidate in "$ANDROID_HOME"/ndk/*; do
    if [ -f "$candidate/source.properties" ]; then
      _NDK="$candidate"
      break
    fi
  done
fi

# 若仍未找到有效的 NDK，则报错并退出
if [ ! -f "$_NDK/source.properties" ]; then
  echo "Error: NDK not found. Please install an Android NDK and set ANDROID_NDK_HOME or NDK."
  exit 1
fi

# 导出环境变量供后续脚本使用
export ANDROID_NDK_HOME="$_NDK"
export NDK="$_NDK"
