# Health API 仕様書

## 概要
Health APIは、システムの健全性を確認するためのエンドポイントを提供します。

## 基本情報
- **ベースURL**: `/api/v1/health`
- **認証**: Basic認証（admin:password）
- **レスポンス形式**: JSON

## エンドポイント一覧

### 1. GET /api/v1/health
システムの健全性を確認します。

#### リクエスト
```bash
curl -X GET "http://localhost:3000/api/v1/health?message=hello" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ="
```

#### パラメータ
| パラメータ | 型 | 必須 | 説明 |
|-----------|----|------|------|
| message | string | ○ | 確認メッセージ |

#### レスポンス
**成功時 (200 OK)**
```json
{
  "success": true,
  "data": {
    "status": "ok",
    "message": "hello"
  },
  "timestamp": "2024-01-01T12:00:00Z",
  "request_id": "req_123456"
}
```

**エラー時 (400 Bad Request)**
```json
{
  "success": false,
  "error": {
    "code": "MISSING_PARAMETER",
    "message": "message parameter is required",
    "details": "Please provide a message parameter in your request",
    "timestamp": "2024-01-01T12:00:00Z",
    "request_id": "req_123456"
  }
}
```

### 2. POST /api/v1/health
新しいヘルスデータを作成します。

#### リクエスト
```bash
curl -X POST "http://localhost:3000/api/v1/health" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -H "Content-Type: application/json" \
  -d '{
    "health": {
      "id": "123",
      "data": "test data",
      "message": "health check",
      "settings": {
        "enabled": true,
        "timeout": 30,
        "retry_count": 3
      },
      "metadata": {
        "version": "1.0.0",
        "created_at": "2024-01-01T12:00:00Z",
        "tags": ["api", "production"]
      },
      "tags": ["critical", "monitoring"],
      "nested_data": [
        {
          "name": "item1",
          "value": 100,
          "sub_items": [
            { "id": 1, "label": "sub1" },
            { "id": 2, "label": "sub2" }
          ]
        }
      ]
    }
  }'
```

#### リクエストボディ
```json
{
  "health": {
    "id": "string",
    "data": "string",
    "message": "string",
    "settings": {
      "enabled": "boolean",
      "timeout": "integer (1-100)",
      "retry_count": "integer (0-10)"
    },
    "metadata": {
      "version": "string (format: x.x.x)",
      "created_at": "string (format: date-time)",
      "tags": ["string"]
    },
    "tags": ["string"],
    "nested_data": [
      {
        "name": "string",
        "value": "integer (>= 0)",
        "sub_items": [
          {
            "id": "integer",
            "label": "string"
          }
        ]
      }
    ]
  }
}
```

#### レスポンス
**成功時 (200 OK)**
```json
{
  "success": true,
  "data": {
    "status": "created",
    "message": "CREATED request received",
    "id": "123",
    "data": "test data",
    "settings": {
      "enabled": true,
      "timeout": 30,
      "retry_count": 3
    },
    "metadata": {
      "version": "1.0.0",
      "created_at": "2024-01-01T12:00:00Z",
      "tags": ["api", "production"]
    },
    "tags": ["critical", "monitoring"],
    "nested_data": [
      {
        "name": "item1",
        "value": 100,
        "sub_items": [
          { "id": 1, "label": "sub1" },
          { "id": 2, "label": "sub2" }
        ]
      }
    ]
  },
  "timestamp": "2024-01-01T12:00:00Z",
  "request_id": "req_123456"
}
```

### 3. PUT /api/v1/health
既存のヘルスデータを更新します。

#### リクエスト
```bash
curl -X PUT "http://localhost:3000/api/v1/health" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -H "Content-Type: application/json" \
  -d '{
    "health": {
      "id": "123",
      "data": "updated data"
    }
  }'
```

#### レスポンス
**成功時 (200 OK)**
```json
{
  "success": true,
  "data": {
    "status": "updated",
    "message": "UPDATED request received",
    "id": "123",
    "data": "updated data"
  },
  "timestamp": "2024-01-01T12:00:00Z",
  "request_id": "req_123456"
}
```

### 4. DELETE /api/v1/health
指定されたIDのヘルスデータを削除します。

#### リクエスト
```bash
curl -X DELETE "http://localhost:3000/api/v1/health?id=123" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ="
```

#### パラメータ
| パラメータ | 型 | 必須 | 説明 |
|-----------|----|------|------|
| id | string | ○ | 削除対象のID |

#### レスポンス
**成功時 (200 OK)**
```json
{
  "success": true,
  "data": {
    "status": "deleted",
    "message": "DELETE request received",
    "id": "123"
  },
  "timestamp": "2024-01-01T12:00:00Z",
  "request_id": "req_123456"
}
```

## エラーレスポンス

### 共通エラーレスポンス形式
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "エラーメッセージ",
    "details": "詳細な説明",
    "timestamp": "2024-01-01T12:00:00Z",
    "request_id": "req_123456"
  }
}
```

### エラーコード一覧
| コード | HTTPステータス | 説明 |
|--------|---------------|------|
| MISSING_PARAMETER | 400 | 必須パラメータが不足 |
| INVALID_JSON | 400 | JSON形式が不正 |
| SCHEMA_VALIDATION_ERROR | 400 | JSONスキーマバリデーションエラー |
| UNAUTHORIZED | 401 | 認証エラー |

## 認証

### Basic認証
```bash
# ユーザー名: admin
# パスワード: password
Authorization: Basic YWRtaW46cGFzc3dvcmQ=
```

## バリデーションルール

### JSONスキーマ
- **id**: 文字列
- **data**: 文字列
- **message**: 文字列
- **settings.enabled**: 真偽値
- **settings.timeout**: 整数（1-100）
- **settings.retry_count**: 整数（0-10）
- **metadata.version**: 文字列（x.x.x形式）
- **metadata.created_at**: 文字列（date-time形式）
- **metadata.tags**: 文字列配列
- **tags**: 文字列配列
- **nested_data[].name**: 文字列
- **nested_data[].value**: 整数（0以上）
- **nested_data[].sub_items[].id**: 整数
- **nested_data[].sub_items[].label**: 文字列

## 使用例

### 基本的なヘルスチェック
```bash
curl -X GET "http://localhost:3000/api/v1/health?message=system_check" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ="
```

### 複雑なデータの作成
```bash
curl -X POST "http://localhost:3000/api/v1/health" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -H "Content-Type: application/json" \
  -d '{
    "health": {
      "id": "monitoring_001",
      "data": "System monitoring data",
      "message": "Daily health check",
      "settings": {
        "enabled": true,
        "timeout": 60,
        "retry_count": 5
      },
      "metadata": {
        "version": "2.1.0",
        "created_at": "2024-01-01T12:00:00Z",
        "tags": ["monitoring", "production"]
      },
      "tags": ["critical", "daily"],
      "nested_data": [
        {
          "name": "cpu_usage",
          "value": 75,
          "sub_items": [
            { "id": 1, "label": "core1" },
            { "id": 2, "label": "core2" }
          ]
        }
      ]
    }
  }'
```

### データの更新
```bash
curl -X PUT "http://localhost:3000/api/v1/health" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -H "Content-Type: application/json" \
  -d '{
    "health": {
      "id": "monitoring_001",
      "data": "Updated monitoring data",
      "settings": {
        "enabled": false,
        "timeout": 30,
        "retry_count": 3
      }
    }
  }'
```

### データの削除
```bash
curl -X DELETE "http://localhost:3000/api/v1/health?id=monitoring_001" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ="
``` 