#!/bin/bash
set -e

# 필수 환경변수 확인
REPO_URL="${REPO_URL:?REPO_URL 환경변수가 필요합니다}"
DEV_BRANCH_NAME="${DEV_BRANCH_NAME:?DEV_BRANCH_NAME 환경변수가 필요합니다}"
DEV_LOCAL_DIR="${DEV_LOCAL_DIR:?DEV_LOCAL_DIR 환경변수가 필요합니다}"

BASE_IOS_ENV_FILE="../../../.ios.env"
BASE_ANDROID_ENV_FILE="../../../.android.env"
IOS_ENV_FILE="$DEV_LOCAL_DIR/ios/fastlane/.env"
ANDROID_ENV_FILE="$DEV_LOCAL_DIR/android/fastlane/.env"

echo "🚀 Deploying branch: $DEV_BRANCH_NAME"

# Git clone (최초 1회)
if [ ! -d "$DEV_LOCAL_DIR" ]; then
    echo "📦 Cloning repo..."
    git clone "$REPO_URL" "$DEV_LOCAL_DIR"
fi

# 해당 디렉토리로 이동
cd "$DEV_LOCAL_DIR" || exit 1

# 최신 상태로 만들기
echo "🔄 Fetching and checking out branch..."
git fetch origin
git checkout "$DEV_BRANCH_NAME" || git checkout -b "$DEV_BRANCH_NAME" "origin/$DEV_BRANCH_NAME"
git pull origin "$DEV_BRANCH_NAME"

# .env 파일 복사 (entrypoint에서 mount된 파일 사용)
echo "🛠️ Setting env [iOS]..."
if [ ! -f "$IOS_ENV_FILE" ] && [ -f "$BASE_IOS_ENV_FILE" ]; then
    mkdir -p $(dirname "$IOS_ENV_FILE")
    cp "$BASE_IOS_ENV_FILE" "$IOS_ENV_FILE"
fi

echo "🛠️ Setting env [Android]..."
if [ ! -f "$ANDROID_ENV_FILE" ] && [ -f "$BASE_ANDROID_ENV_FILE" ]; then
    mkdir -p $(dirname "$ANDROID_ENV_FILE")
    cp "$BASE_ANDROID_ENV_FILE" "$ANDROID_ENV_FILE"
fi

# Flutter SDK가 이미 설정되어 있다고 가정
echo "🚧 Running flutter pub get ..."
flutter pub get

echo "✅ Setup success for branch: $DEV_BRANCH_NAME"
