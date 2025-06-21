# Rails API実装強者へのロードマップ 🚀

## 📚 学習目標
- 各種API認証方式の理解と実装
- セキュアで拡張性のあるAPI設計
- 実践的なAPI開発スキルの習得

## 🔐 API認証方式の違い

### 1. Basic認証
```ruby
# Rails実装例
class Api::V1::UsersController < ApplicationController
  http_basic_authenticate_with name: "admin", password: "secret"
  
  def index
    @users = User.all
    render json: @users
  end
end
```
**特徴**: シンプル、HTTPS必須、パスワードが平文で送信

### 2. Token認証
```ruby
# Rails実装例
class User < ApplicationRecord
  has_secure_token :api_token
end

class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user_from_token!
  
  private
  
  def authenticate_user_from_token!
    token = request.headers['Authorization']&.split(' ')&.last
    @current_user = User.find_by(api_token: token)
    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end
end
```
**特徴**: ステートレス、シンプル、カスタマイズ可能

### 3. JWT (JSON Web Token)
```ruby
# Rails実装例
class Api::V1::AuthController < ApplicationController
  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JWT.encode({ user_id: user.id }, Rails.application.secrets.secret_key_base)
      render json: { token: token }
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end
end
```
**特徴**: ステートレス、自己完結型、クライアント側でデコード可能

### 4. OAuth 2.0
```ruby
# Rails実装例 (Doorkeeper使用)
class Api::V1::OauthController < ApplicationController
  def authorize
    # OAuth認可フロー
  end
  
  def token
    # アクセストークン発行
  end
end
```
**特徴**: サードパーティ認証、スコープ管理、業界標準

### 5. Cookie認証
```ruby
# Rails実装例
class Api::V1::SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      render json: { message: 'Logged in successfully' }
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end
end
```
**特徴**: ブラウザ向け、CSRF対策必要、セッション管理

## 🛣️ 学習ロードマップ

### Phase 1: 基礎固め (2-3週間)
- [ ] HTTPの基礎理解
  - [ ] HTTPメソッド (GET, POST, PUT, DELETE, PATCH)
  - [ ] ステータスコード (200, 201, 400, 401, 403, 404, 500)
  - [ ] ヘッダーの役割
  - [ ] CORSの理解
- [ ] JSONの扱い
  - [ ] JSON構造の理解
  - [ ] パースとバリデーション
  - [ ] JSON Schema
- [ ] Rails API基礎
  - [ ] Rails APIモード
  - [ ] コントローラーの書き方
  - [ ] ルーティング
  - [ ] レスポンス形式

### Phase 2: 認証実装 (3-4週間)
- [ ] Basic認証の実装
- [ ] Token認証の実装
- [ ] JWT認証の実装
- [ ] OAuth 2.0の実装
- [ ] Cookie認証の実装
- [ ] 各認証方式の比較・使い分け

### Phase 3: セキュリティ強化 (2-3週間)
- [ ] HTTPS/TLSの理解
- [ ] CSRF対策
- [ ] XSS対策
- [ ] SQLインジェクション対策
- [ ] レート制限
- [ ] 入力値検証
- [ ] ログ出力・監視

### Phase 4: 設計・アーキテクチャ (3-4週間)
- [ ] RESTful API設計
- [ ] バージョニング戦略
- [ ] エラーハンドリング
- [ ] レスポンス形式の統一
- [ ] ドキュメント化 (Swagger/OpenAPI)
- [ ] テスト戦略

### Phase 5: 運用・スケーラビリティ (2-3週間)
- [ ] キャッシュ戦略
- [ ] データベース最適化
- [ ] 非同期処理
- [ ] マイクロサービス
- [ ] 監視・ログ
- [ ] デプロイメント

### Phase 6: 実践プロジェクト (4-6週間)
- [ ] 完全なAPIサービスの構築
- [ ] 複数認証方式の統合
- [ ] フロントエンドとの連携
- [ ] 本番環境での運用

## 🛠️ 技術スタック

### 必須技術
- **Rails 7+** (APIモード)
- **Ruby 3+**
- **PostgreSQL** (本格的なDB)
- **RSpec** (テスト)
- **JWT** gem
- **Doorkeeper** gem (OAuth)
- **Devise** gem (認証基盤)

### 推奨技術
- **Redis** (キャッシュ・セッション)
- **Sidekiq** (非同期処理)
- **Swagger/OpenAPI** (ドキュメント)
- **Docker** (コンテナ化)
- **GitHub Actions** (CI/CD)

## 📖 学習リソース

### 書籍
- 「Rails API デザインパターン」
- 「Web API デザイン」
- 「RESTful Web APIs」

### オンライン
- Rails公式ガイド
- OAuth 2.0仕様書
- JWT公式ドキュメント

### 実践
- GitHub API
- Twitter API
- Stripe API

## 🎯 評価基準

### 初級レベル
- [ ] 基本的なCRUD APIの実装
- [ ] 単一認証方式の実装
- [ ] 基本的なテストの作成

### 中級レベル
- [ ] 複数認証方式の使い分け
- [ ] セキュリティ対策の実装
- [ ] 適切なエラーハンドリング

### 上級レベル
- [ ] スケーラブルな設計
- [ ] 本番環境での運用
- [ ] チーム開発での指導

## 🚀 次のステップ

1. このリポジトリで実践的なAPIプロジェクトを開始
2. 各認証方式の実装例を作成
3. 段階的に機能を追加
4. 本番環境での運用経験を積む

---

**目標**: セキュアで拡張性のあるAPIを設計・実装できるエンジニアになる！ 