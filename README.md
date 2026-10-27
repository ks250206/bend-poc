# LGPS を題材にした 3D 拡散 POC

Bend で 1,024 本の独立なランダムウォークを計算し、各時点の平均二乗変位（MSD）を CSV で出力します。硫化物固体電解質 Li₁₀GeP₂S₁₂（LGPS）の拡散を考えるための出発点です。

**材料の定量予測ではありません。** LGPS の結晶構造、サイトの占有、Li-Li 相互作用、欠陥、実測・計算による移動障壁は入っていません。温度依存性もまだありません。以下の確率は動作確認のための仮定であり、LGPS の測定値ではありません。

## モデル

各粒子は原点から始まり、各時間ステップで x と y の各方向に 4%、z の各方向に 12% の確率で 1 格子移動し、それ以外は停止します。z 方向を移動しやすくした仮想的な異方性モデルです。格子は無限で、粒子同士は相互作用しません。疑似乱数のシードは粒子ごとに固定され、実行結果を再現できます。異なる時刻の値は同じシードから再計算しています。

出力の `steps` は試行回数、`msd_lattice2` は平均二乗変位 ⟨x²+y²+z²⟩（格子間隔の二乗単位）です。理論上、各ステップの移動確率が 0.4 なので MSD は約 `0.4 × steps` です。3D の平均拡散係数は `D = MSD × a² / (6 × steps × Δt)` で換算できますが、格子間隔 `a` と時間刻み `Δt` は実材料に合わせて別途決める必要があります。軌跡、温度掃引、実単位の拡散係数はまだ出力しません。

## セットアップ

Linux x86-64、Node.js と npm、Git、Python 3 が必要です。以下は本 POC で検証した Bend 2.0.39 のソースと Bun 1.4.4 を使う方法です。Bend は開発中のためバージョンを固定します。`/workspace` は作業場所に読み替えてください。ネットワークとディスク容量が必要です。

```bash
# このリポジトリの外にツールを置く
mkdir -p /workspace/bend-tools
npm install --prefix /workspace/bend-tools --cache /tmp/bend-npm-cache bun@1.4.4
git clone https://github.com/HigherOrderCO/Bend.git /workspace/bend-tools/Bend
git -C /workspace/bend-tools/Bend checkout cf0935dcacf67c47cc46f0bd37ea2e731a33c299
```

既にディレクトリがある場合は上書きせず、内容とコミットを確認してください。公式のインストーラーと詳しい言語ガイドは [Bend 公式リポジトリ](https://github.com/HigherOrderCO/Bend) を参照してください。

## 実行と検証

```bash
cd /workspace/bend-poc
BUN=/workspace/bend-tools/node_modules/.bin/bun
BEND=/workspace/bend-tools/Bend/bend2/main.ts
"$BUN" "$BEND" main.bend > msd.csv
cat msd.csv
python3 tests/check.py "$BUN" "$BEND"
```

テストはゼロ時点と 4 時点の MSD を、独立な 3D ランダムウォークの理論値と標本誤差を考慮した幅で比較します。実行には GPU は不要です。`ensemble!` は Bend の並列構文ですが、使用するバックエンドやハードウェアによる速度向上は未測定です。ネイティブ実行ファイルへのコンパイルには別途 clang 14 以上が必要です。

## 次のステップ

実際の LGPS を扱うには、引用可能な結晶構造と Li サイト間の遷移ネットワーク、移動障壁、試行頻度を用意し、温度に依存する遷移速度と物理時間を導入します。サイト占有や相互作用をどう扱うかも、比較したい実験に合わせて決める必要があります。
