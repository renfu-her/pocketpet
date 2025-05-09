# 電子烏龜寵物 PocketPet

這是一個 Flutter 製作的可愛電子寵物小遊戲，主角是一隻會移動、會睡覺、會撒嬌的烏龜！

## 主要功能
- 烏龜會在畫面上自動左右移動，並根據方向切換不同圖片
- 烏龜有三大狀態：飢餓程度（紅色）、體力（藍色）、心情（粉紅色），以橫條圖顯示
- 飢餓、體力、心情會隨時間自動變化
- 可以餵食、陪玩，提升烏龜心情與體力
- 烏龜會根據狀態顯示不同的對話框（肚子餓、睡覺等）
- 烏龜體力低時會自動進入睡眠，睡覺時會恢復體力與心情，並停止移動
- 睡覺時烏龜會顯示睡覺專用圖片，並顯示「我先睡覺，以恢復體力」對話框

## 安裝與執行
1. 請先安裝 [Flutter](https://flutter.dev/docs/get-started/install)
2. 下載本專案後，於專案根目錄執行：
   ```bash
   flutter pub get
   flutter run
   ```
3. 請確認 `assets/images/` 目錄下有以下圖片：
   - tortoise.png
   - tortoise-left.png
   - tortoise-right.png
   - tortoise-sleep.png

## 主要畫面說明
- **烏龜主體**：會自動左右移動，睡覺時靜止
- **心情圖示**：根據心情顯示愛心、微笑、難過等
- **對話框**：烏龜肚子餓或睡覺時會顯示對話
- **狀態條**：紅色（飢餓）、藍色（體力）、粉紅色（心情）
- **互動按鈕**：餵食、陪玩（睡覺時無法互動）

## 資產與授權
- 烏龜圖片需放置於 `assets/images/` 目錄下
- 本專案僅供學習、個人或非商業用途

---

如有任何問題或建議，歡迎提出！
