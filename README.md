# FX Preset Maker by pisukari（grandMA3 用プラグイン）

作者：pisukari　/　バージョン 2.3.1

> [!IMPORTANT]
> **grandMA3 ソフトウェアバージョン 2.4 以降でないと対応していません。**
> 2.3 以前のバージョンでは動きません。動作確認は grandMA3 onPC 2.5.1.1 で行っています。

## ダウンロード

**[FX_Preset_Maker_by_pisukari.zip をダウンロード](https://github.com/pisukarii/fx-preset-maker/releases/latest/download/FX_Preset_Maker_by_pisukari.zip)**

（[Releases](https://github.com/pisukarii/fx-preset-maker/releases) のページからも落とせます）

エフェクトを作る画面「EFFECT MAKER」を、どのショーにも一発で作るプラグインです。
プラグインは **1 つだけ** です。画面づくり、ディマープリセットづくり、走り方ボタンの処理まで、全部この中に入っています。

## 入れ方

1. `images/` の中身を、全部 `<gma3_library>/media/images/` にコピーする。
2. `plugins/` の中身（fx_preset_maker.lua / .xml）を、`<gma3_library>/datapools/plugins/` にコピーする。
   - Mac の場合、`<gma3_library>` は `~/MALightingTechnology/gma3_library` です。
3. 器具をパッチしておく（ディマープリセットは、パッチされている器具から録ります）。
4. onPC（または卓）のコマンドラインで次を実行する。Plugin 番号は空いているところならどこでも構いません。

   ```
   Import Plugin Library "fx_preset_maker.xml" At Plugin 10
   Plugin "FX Preset Maker by pisukari"
   ```

5. 「Which All pool gets the dimmer presets?」と聞かれるので、All 1〜All 4 から選ぶ（All 5 は SAVE FX 専用なので出てきません）。ボタンには、そのプールで今使っている数が出ます。
6. 終わると、作ったプリセットの数、並べた数、レイアウト番号がメッセージで出ます。「EFFECT MAKER」レイアウトを View に置いて使ってください。

**プラグインの名前は変えないでください。** 走り方ボタンのマクロが、この名前でプラグインを呼びます。変えるなら、レイアウトを作る前に変えてください。

## 画面の中身

上から順に、次のブロックが並びます。

| ブロック | ボタン |
|---|---|
| SHAPES | シェイプ 22 種（Sine、Linear、Ramp、Snap、Circle、Eight、Flyout、Wipe など） |
| DIMMER PHASER | ディマーのフェイザープリセット 17 個（下の表） |
| PHASE | PHASE 45 / 90 / 180 / 360 |
| （区切り線） | TAKE SELECTION FROM 3D |
| DIRECTION | 走り方 7 種（LEFT / RIGHT / CENTER OUT / TOP DOWN / BOTTOM UP / DIAG DOWN / DIAG UP） |
| FX CONTROL | PREV STEP / ALL STEPS / NEXT STEP / SAVE FX / SHUFFLE |
| QUICK STOMP | STOMP ALL / STOMP DIM / STOMP POS / STOMP COLOR / STOMP FOCUS / LOCATE |

### ディマープリセット

| Dim Sinus | Chase | Snap Off | Snap On |
|---|---|---|---|
| Dim Sinus | Chase | Snap Off | Snap On |
| Dim Sinus 1/4 | Chase 1/4 | Snap Off 80% | Snap On 80% |
| Dim Sinus 1/3 | Chase 1/3 | Snap Off 60% | Snap On 60% |
| Dim Sinus 1/2 | | Snap Off 40% | Snap On 40% |
| | | Snap Off 20% | Snap On 20% |

- 選んだ All プールの空いている番号に、上から順に書き込みます。
- パッチされている全器具を選んだ状態で録ります（前後にプログラマーを ClearAll します）。Universal 形式なので、どの器具タイプにも効きます。
- 器具が 1 台もパッチされていないショーでは、プリセットは作れません。レイアウトだけ作って、メッセージを出します。パッチしてから、もう一度実行してください。
- 同じ名前のプリセットがプールにすでにあれば、作らずにそれを使います。上書きはしません。
- 別のプールを選んで実行し直すと、レイアウトのディマープリセットのボタンは新しいプールのものに置き換わります。

### 走り方ボタン

ボタンを押した瞬間に、選択グリッドを見て位相を計算し直します。

- グリッドのすき間は無視して、行と列を詰めて数えます。
- 360°を段数で割って、均等にずらします。4 段なら 0°、90°、180°、270° です。最初と最後が重なりません。
- 選択中の器具で走っているフェイザー（2 ステップ以上）すべてに書き込みます。MAtricks の位相と Wings は先にクリアします。

**シェイプを入れたあとに押してください。** 押した時点でフェイザーが無い器具には、何も書き込まれません。

### TAKE SELECTION FROM 3D

今選んでいる器具のセレクショングリッドを、3D ステージ上の位置に並べ直します（`Grid "Planar"`）。

- 3D ビューのラッソ選択の「Planar」と同じ動きで、カメラの向きに左右されません。上から見た配置（左右 = X、奥行き = Y）がグリッドになります。
- このコマンドはマニュアルに載っていません。grandMA3 2.5.1.1 の onPC で動作を確認しました。

走り方ボタンと組み合わせると、ステージ上の実際の並びに沿ってエフェクトを走らせられます。

### LOCATE

選んだ器具の、Control 以外のフィーチャーグループ（Position / Gobo / Color / Beam / Focus / Shapers / Video）をデフォルト値に戻し、Dimmer を 100 にします。1.2 秒後にフェードで元に戻します（KnockOut）。属性名を決め打ちしていないので、どの器具タイプにも効きます。

### SAVE FX

今のプログラマーの内容を、名前を聞いてからプリセットプール 25（= All 5）に保存し、「FX RECALL」レイアウトに並べます。「FX RECALL」が無ければ、空いている番号に作ります。

> [!IMPORTANT]
> **SAVE FX の保存先は、プリセットプール 25（= All 5）です。All 5 のプリセットプールを画面に出しておいてください。**
> 保存したエフェクトがここに溜まっていきます。
>
> - プールの名前を「FX SAVE」などに変えておくと、どこに保存されたか分かりやすくなります。
> - All 5 は SAVE FX 専用なので、ディマープリセットを作るときのプール選択には出てきません。保存したエフェクトとディマープリセットが混ざることはありません。
> - 保存先を変えたいときは、`fx_preset_maker.lua` の先頭の `CFG.SAVE_POOL` を変えてから、画面を作ってください。

## 番号の使い方

既存のものは上書きしません。それぞれのプールの、空いている一番若い番号から使います。

| もの | 数 |
|---|---|
| マクロ / アピアランス / 画像（ボタン用） | 各 45 個 |
| アピアランス / 画像（ディマープリセット用 PFX / PFXM） | 各 17 個 |
| レイアウト | EFFECT MAKER と FX RECALL |

`fx_preset_maker.lua` の先頭の `CFG` で、次を変えられます。

- `LAYOUT_NAME`：作るレイアウトの名前（"EFFECT MAKER"）
- `START`：空き番号を探し始める番号
- `SAVE_POOL`：SAVE FX の保存先プリセットプール（25 = All 5）
- `RECALL_NAME`：SAVE FX の保存先レイアウトの名前
- `RECALL_VIEW`：`15` のように View 番号を入れると、その View に切り替える「FX RECALL」ボタンも置く

## アイコン

ボタンの形に合わせて、縦横比の合う画像を使っています。つぶれません。

| 用途 | ファイル | 大きさ |
|---|---|---|
| シェイプ | shp_1〜22 | 256×256 |
| PHASE | phm_45 / 90 / 180 / 360 | 300×200 |
| 走り方 | dir_1〜7 | 400×200 |
| FX CONTROL / QUICK STOMP | macw_*（locate、stompfocus を含む） | 400×180 |
| TAKE SELECTION FROM 3D | macw_take3d | 940×200 |
| ディマープリセット | fx_1〜17（プール用）、fxm_1〜17（レイアウト用） | 正方形 / 300×200 |

## 注意

- 同じ名前のマクロがすでにあるショーでは、MA3 が自動で名前の末尾を変えます（`SHP Sine#2` など）。ボタンは名前を表示しない設定なので、見た目と動作には影響しません。
- 画面がすでにあるショーで実行すると、ディマープリセットだけを作って並べます。画面を作り直したいときは、EFFECT MAKER レイアウトを消してから実行してください。

## ライセンス

© 2026 pisukari

このプラグインとアイコン画像は、**[CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/deed.ja)**（クリエイティブ・コモンズ 表示 - 改変禁止 4.0 国際）で公開しています。全文は [LICENSE](LICENSE) にあります。

- 無料で使えます。商用の現場で使っても構いません。
- そのままの形なら、再配布してかまいません。配布するときは、作者が pisukari であることと、このライセンスを表示してください。
- **改変したものの配布は禁止**です。
- でも、**自分用にカスタマイズして使うのは大歓迎**です！ボタンの配置やプリセットの中身など、自分の現場に合わせて自由にいじってください（いじったものを人に配らなければ OK です）。
