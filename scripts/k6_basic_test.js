import http from "k6/http";
import { check, sleep } from "k6";

// テスト設定
export const options = {
  // 仮想ユーザー数とテスト時間
  stages: [
    { duration: "10s", target: 10 }, // 0秒から10秒で5ユーザーまで増加
    { duration: "20s", target: 50 }, // 10秒から30秒で10ユーザーまで増加
    { duration: "10s", target: 0 }, // 30秒から40秒で0ユーザーまで減少
  ],
  // 閾値（テスト失敗の条件）
  thresholds: {
    http_req_duration: ["p(95)<500"], // 95%のリクエストが500ms以内
    http_req_failed: ["rate<0.1"], // エラー率10%未満
  },
};

// デフォルト関数（各仮想ユーザーが実行）
export default function () {
  // GETリクエスト
  const getResponse = http.get(
    "http://localhost:3000/api/v1/health?message=test",
    {
      headers: {
        Authorization: "Basic YWRtaW46cGFzc3dvcmQ=",
      },
    }
  );

  // レスポンスチェック
  check(getResponse, {
    "GET status is 200": (r) => r.status === 200,
    "GET response time < 100ms": (r) => r.timings.duration < 100,
  });

  // 1秒待機
  sleep(1);
}
