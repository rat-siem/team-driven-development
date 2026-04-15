# Team-Driven Development Plugin

## Overview

Lead/Worker/Reviewer/Architect の役割分担でサブエージェントを駆動する実装プラグイン。
Superpowers の `writing-plans` で作成されたプランをチーム構成で実行する。

## Architecture

- **Lead (コントローラー)**: チーム編成・タスク割当・統合・品質判断。コードは書かない。
- **Worker**: Worktree 隔離で実装 + TDD + セルフレビュー。
- **Reviewer**: Sprint Contract に基づくレビュー (static/runtime/browser)。
- **Architect**: 設計判断が必要なタスクのみ召集。

## Design Principles

- Superpowers の Plan 形式をそのまま使う（依存解析は Lead が動的に実行）
- Node.js/Go 非依存（シェルスクリプトのみ）
- Sprint Contract でレビュー基準を事前定義
- Effort Scoring でモデル選択を自動化
- Worktree 隔離 + Cherry-pick で main ブランチを保護
