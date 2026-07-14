import { Controller } from "@hotwired/stimulus";

// 予定フロー: サーバーからPresigned URL取得 → ブラウザからR2へ直接PUT → サーバーへ完了通知
export default class extends Controller {
  static targets = ["file", "message"];

  async start() {
    const file = this.fileTarget.files[0];
    if (!file) {
      this.messageTarget.textContent = "ファイルを選択してください";
      return;
    }

    try {
      this.messageTarget.textContent = "アップロード準備中...";
      const res = await fetch("/admin/videos", {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
      });
      if (!res.ok) throw new Error(`URL発行に失敗 (${res.status})`);
      const { video_id, upload_url } = await res.json();

      this.messageTarget.textContent = "アップロード中...";
      const put = await fetch(upload_url, { method: "PUT", body: file });
      if (!put.ok) throw new Error(`R2へのPUTに失敗 (${put.status})`);

      this.messageTarget.textContent = "完了";
      // TODO: video_id で完了通知（次のステップ）
    } catch (e) {
      this.messageTarget.textContent = `失敗: ${e.message}`;
    }
  }
}
