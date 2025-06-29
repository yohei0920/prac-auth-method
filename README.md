# Practice API

Rails APIモードで構築された練習用APIプロジェクトです。

## 概要

このプロジェクトは、API開発の学習と実践を目的として作成されています。以下の機能を実装しています：

- Basic認証
- JSON Schemaバリデーション
- 統一されたエラーハンドリング
- メンテナンス性を考慮したコード設計

## 技術スタック

- **Ruby**: 3.x
- **Rails**: 7.x (API mode)
- **PostgreSQL**: データベース
- **Redis**: キャッシュ
- **Docker**: コンテナ化

## セットアップ

### 前提条件
- Docker
- Docker Compose

### インストール

1. リポジトリをクローン
```bash
git clone <repository-url>
cd practice-api
```

2. 環境変数を設定
```bash
cp config/application.yml.example config/application.yml
# config/application.ymlを編集して必要な値を設定
```

3. Dockerコンテナを起動
```bash
docker-compose up -d
```

4. データベースをセットアップ
```bash
docker-compose exec web rails db:create db:migrate
```

5. サーバーを起動
```bash
docker-compose exec web rails server
```

## APIドキュメント

### 仕様書
- [OpenAPI仕様書](https://yhok-bb.github.io/prac-auth-method/) - 詳細なAPI仕様と使用例

### テスト用コマンド
- [curlコマンド集](docs/curl_examples.sh) - APIテスト用のcurlコマンド

### 使用方法
```bash
# 仕様書を表示
cat docs/api_specification.md

# テストコマンドを表示
./docs/curl_examples.sh
```

## テスト

```bash
# テストを実行
bundle exec rspec

# 特定のテストファイルを実行
bundle exec rspec spec/requests/api/v1/health_spec.rb
```

## 開発

### コード品質
```bash
# RuboCopでコードスタイルをチェック
bundle exec rubocop

# Brakemanでセキュリティチェック
bundle exec brakeman
```

### ログ
```bash
# アプリケーションログを確認
docker-compose logs web

# リアルタイムでログを追跡
docker-compose logs -f web
```

## プロジェクト構造

```
practice-api/
├── app/
│   ├── controllers/
│   │   ├── api/v1/
│   │   │   └── health_controller.rb    # Health API
│   │   └── concerns/                   # 共通機能
│   │       ├── api_response_concern.rb
│   │       ├── basic_auth_concern.rb
│   │       ├── error_messages_concern.rb
│   │       └── json_schema_concern.rb
├── docs/                               # ドキュメント
│   ├── api_specification.md
│   └── curl_examples.sh
└── spec/                               # テスト
    └── requests/api/v1/
        └── health_spec.rb
```

## 学習ロードマップ

API開発の学習ロードマップについては、[README_roadmap.md](README_roadmap.md)を参照してください。

## ライセンス

このプロジェクトは学習目的で作成されています。
