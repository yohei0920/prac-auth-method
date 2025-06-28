# Rails API実装強者へのロードマップ 🚀

## 📚 学習目標
- 各種API認証方式の理解と実装
- セキュアで拡張性のあるAPI設計
- 実践的なAPI開発スキルの習得
- 本番運用まで見据えた実践的スキル

## 🔐 API認証方式の違い

### 1. Basic認証 ✅ 完了
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

### 2. Token認証 ✅ 完了
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

### 3. JWT (JSON Web Token) ✅ 完了
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

### 4. OAuth 2.0 🔄 学習予定
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

### 5. Cookie認証 🔄 学習予定（フルモードプロジェクト）
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

## 🛣️ 学習ロードマップ（更新版）

### ✅ Phase 1: 基礎固め (完了)
- [x] HTTPの基礎理解
  - [x] HTTPメソッド (GET, POST, PUT, DELETE, PATCH)
  - [x] ステータスコード (200, 201, 400, 401, 403, 404, 500)
  - [x] ヘッダーの役割
  - [x] CORSの理解
- [x] JSONの扱い
  - [x] JSON構造の理解
  - [x] パースとバリデーション
  - [x] JSON Schema
- [x] Rails API基礎
  - [x] Rails APIモード
  - [x] コントローラーの書き方
  - [x] ルーティング
  - [x] レスポンス形式

### ✅ Phase 2: 認証実装 (完了)
- [x] Basic認証の実装
- [x] Token認証の実装
- [x] JWT認証の実装
- [ ] OAuth 2.0の実装 🔄 学習予定
- [ ] Cookie認証の実装 🔄 学習予定（フルモードプロジェクト）
- [x] 各認証方式の比較・使い分け

### 🔄 Phase 3: API設計・開発効率 (現在進行中)
- [ ] 共通親クラス設計
- [ ] OpenAPI/Swagger
- [ ] エラーハンドリング
- [ ] JSON Schema
- [ ] レート制限 (rack-attack)

### 🔄 Phase 4: パフォーマンス・スケーラビリティ (学習予定)
- [ ] キャッシュ戦略 (Redis)
- [ ] 非同期処理 (Sidekiq)
- [ ] パフォーマンス最適化
- [ ] データベース最適化

### 🔄 Phase 5: 監視・運用 (学習予定)
- [ ] APM監視 (Sentry/Datadog)
- [ ] Prometheus + Grafana
- [ ] アラート設定
- [ ] ログ管理

### 🔄 Phase 6: フルモードプロジェクト (新規作成予定)
- [ ] Devise gemによるCookie認証
- [ ] セッション管理
- [ ] CSRF対策
- [ ] フロントエンド連携
- [ ] ユーザー管理画面

### 🔄 Phase 7: マイクロサービス (新規作成予定)
- [ ] サービス間通信
- [ ] サービスディスカバリ
- [ ] データベース設計（サービスごと）
- [ ] メッセージキュー
- [ ] 分散トレーシング

## 🏗️ プロジェクト構成

### 1. **現在のAPIモードプロジェクト** (継続)
**テーマ: 本格的なAPIサービス**
- Phase 3: API設計・開発効率
- Phase 4: パフォーマンス・スケーラビリティ
- Phase 5: 監視・運用
- OAuth 2.0実装

### 2. **フルモードプロジェクト** (新規作成)
**テーマ: Webアプリケーション**
- Phase 6: Devise gem、セッション管理、フロントエンド連携

### 3. **マイクロサービスプロジェクト** (新規作成)
**テーマ: 分散システム**
- Phase 7: サービス間通信、分散トレーシング

## 🛠️ 技術スタック

### 必須技術
- **Rails 7+** (APIモード + フルモード)
- **Ruby 3+**
- **PostgreSQL** (本格的なDB)
- **RSpec** (テスト)
- **JWT** gem ✅ 完了
- **Doorkeeper** gem (OAuth) 🔄 学習予定
- **Devise** gem (認証基盤) 🔄 学習予定

### 推奨技術
- **Redis** (キャッシュ・セッション) 🔄 学習予定
- **Sidekiq** (非同期処理) 🔄 学習予定
- **Swagger/OpenAPI** (ドキュメント) 🔄 学習予定
- **Docker** (コンテナ化)
- **GitHub Actions** (CI/CD)
- **Sentry/Datadog** (APM監視) 🔄 学習予定
- **Prometheus + Grafana** (監視) 🔄 学習予定

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

### ✅ 初級レベル (達成済み)
- [x] 基本的なCRUD APIの実装
- [x] 単一認証方式の実装
- [x] 基本的なテストの作成

### 🔄 中級レベル (現在進行中)
- [x] 複数認証方式の使い分け
- [ ] セキュリティ対策の実装
- [ ] 適切なエラーハンドリング

### 🎯 上級レベル (目標)
- [ ] スケーラブルな設計
- [ ] 本番環境での運用
- [ ] チーム開発での指導

## 🚀 次のステップ

### 短期目標 (1-2ヶ月)
1. 現在のAPIプロジェクトで共通親クラス設計を実装
2. OpenAPI/Swaggerでドキュメント化
3. エラーハンドリングとレート制限を実装

### 中期目標 (3-4ヶ月)
1. キャッシュ戦略と非同期処理を実装
2. APM監視とPrometheus + Grafanaを導入
3. フルモードプロジェクトでDevise gemを学習

### 長期目標 (6ヶ月)
1. OAuth 2.0を実装
2. マイクロサービスアーキテクチャを学習
3. 本番環境での運用経験を積む

---

**目標**: セキュアで拡張性のあるAPIを設計・実装し、本番運用までできるエンジニア 🚀 