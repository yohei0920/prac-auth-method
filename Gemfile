source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"

# Rails API
gem "rails", "~> 7.1.0"
gem "puma", "~> 6.0"

# Database
gem "pg", "~> 1.1"
gem "sqlite3", "~> 1.4", platforms: %i[ mingw mswin x64_mingw jruby ]

# Authentication gems
gem "devise", "~> 4.9"                    # 認証基盤
gem "jwt", "~> 2.7"                       # JWT認証
gem "doorkeeper", "~> 5.6"                # OAuth 2.0
gem "bcrypt", "~> 3.1.7"                  # パスワード暗号化

# API documentation
gem "rswag-api", "~> 2.8"                 # Swagger/OpenAPI
gem "rswag-ui", "~> 2.8"

# Serialization
gem "active_model_serializers", "~> 0.10" # JSON serialization
gem "jbuilder", "~> 2.11"                 # JSON builder
gem "json-schema", "~> 4.0"               # JSON Schema validation

# Security
gem "rack-cors", "~> 3.0"                 # CORS
gem "rack-attack", "~> 6.6"               # Rate limiting

# Background jobs
gem "sidekiq", "~> 7.0"                   # 非同期処理
gem "redis", "~> 5.0"                     # Redis

# Testing
group :development, :test do
  gem "rspec-rails", "~> 6.0"             # RSpec
  gem "factory_bot_rails", "~> 6.4"       # Factory Bot
  gem "faker", "~> 3.2"                   # テストデータ
  gem "shoulda-matchers", "~> 5.1"        # テストヘルパー
  gem "database_cleaner-active_record", "~> 2.1"
end

group :development do
  gem "puma-metrics"                        # Pumaのメトリクス監視
  gem "rack-mini-profiler", "~> 3.0"      # パフォーマンスプロファイラ
  gem "listen", "~> 3.3"                  # ファイル監視
  gem "spring"                            # 開発環境の高速化
  gem "annotate", "~> 3.2"                # モデル注釈
  gem "bullet", "~> 7.0"                  # N+1クエリ検出
  gem "rubocop", "~> 1.50"                # コード品質
  gem "rubocop-rails", "~> 2.19"          # Rails用RuboCop
end

group :test do
  gem "simplecov", "~> 0.22"              # テストカバレッジ
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"
