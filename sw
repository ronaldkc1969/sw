<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>実習日誌WEBアプリ</title>
  <style>
    body { font-family: system-ui, sans-serif; margin: 20px; }
    h1 { font-size: 20px; }
    label { display: block; margin-top: 8px; }
    input[type="text"], input[type="date"], textarea {
      width: 100%; padding: 6px; box-sizing: border-box;
    }
    textarea { height: 120px; }
    button { margin-top: 10px; padding: 6px 12px; }
    .entry { border: 1px solid #ccc; padding: 8px; margin-top: 8px; }
    .entry-header { display: flex; justify-content: space-between; }
    .small { font-size: 12px; color: #555; }
  </style>
</head>
<body>

<h1>実習日誌入力</h1>

<form id="diary-form">
  <input type="hidden" id="entry-id">
  <label>
    学籍番号（必須）:
    <input type="text" id="student-id" required>
  </label>
  <label>
    日付:
    <input type="date" id="date">
  </label>
  <label>
    実習内容:
    <textarea id="content"></textarea>
  </label>
  <button type="submit" id="save-button">保存</button>
  <button type="button" id="clear-form">新規入力に戻す</button>
</form>

<hr>

<h2>日誌一覧</h2>

<label>
  学籍番号で絞り込み:
  <input type="text" id="filter-student-id" placeholder="例: 2023001">
</label>
<button type="button" id="apply-filter">絞り込み</button>
<button type="button" id="clear-filter">全件表示</button>

<div id="entries"></div>

<script>
  const STORAGE_KEY = "practicum_diary_entries";

  function loadEntries() {
    const json = localStorage.getItem(STORAGE_KEY);
    if (!json) return [];
    try {
      return JSON.parse(json);
    } catch (e) {
      console.error("JSON parse error", e);
      return [];
    }
  }

  function saveEntries(entries) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(entries));
  }

  function renderEntries(filterStudentId = "") {
    const entries = loadEntries();
    const container = document.getElementById("entries");
    container.innerHTML = "";

    const filtered = filterStudentId
      ? entries.filter(e => e.studentId === filterStudentId)
      : entries;

    if (filtered.length === 0) {
      container.textContent = "該当する日誌はありません。";
      return;
    }

    filtered
      .sort((a, b) => (a.date || "").localeCompare(b.date || ""))
      .forEach(entry => {
        const div = document.createElement("div");
        div.className = "entry";

        const header = document.createElement("div");
        header.className = "entry-header";

        const left = document.createElement("div");
        left.innerHTML =
          `<div><strong>${entry.studentId}</strong></div>` +
          `<div class="small">${entry.date || "日付未入力"}</div>`;

        const right = document.createElement("div");
        const editBtn = document.createElement("button");
        editBtn.textContent = "編集";
        editBtn.addEventListener("click", () => loadToForm(entry.id));
        right.appendChild(editBtn);

        header.appendChild(left);
        header.appendChild(right);

        const body = document.createElement("div");
        body.textContent = entry.content || "";

        div.appendChild(header);
        div.appendChild(body);
        container.appendChild(div);
      });
  }

  function loadToForm(id) {
    const entries = loadEntries();
    const target = entries.find(e => e.id === id);
    if (!target) return;

    document.getElementById("entry-id").value = target.id;
    document.getElementById("student-id").value = target.studentId;
    document.getElementById("date").value = target.date || "";
    document.getElementById("content").value = target.content || "";
    document.getElementById("save-button").textContent = "更新";
  }

  function clearForm() {
    document.getElementById("entry-id").value = "";
    document.getElementById("student-id").value = "";
    document.getElementById("date").value = "";
    document.getElementById("content").value = "";
    document.getElementById("save-button").textContent = "保存";
  }

  document.getElementById("diary-form").addEventListener("submit", (e) => {
    e.preventDefault();

    const entryId = document.getElementById("entry-id").value;
    const studentId = document.getElementById("student-id").value.trim();
    const date = document.getElementById("date").value;
    const content = document.getElementById("content").value;

    if (!studentId) {
      alert("学籍番号は必須です。");
      return;
    }

    const entries = loadEntries();

    if (entryId) {
      const index = entries.findIndex(e => e.id === entryId);
      if (index !== -1) {
        entries[index].studentId = studentId;
        entries[index].date = date;
        entries[index].content = content;
      }
    } else {
      const newEntry = {
        id: "id_" + Date.now(),
        studentId,
        date,
        content,
        createdAt: new Date().toISOString()
      };
      entries.push(newEntry);
    }

    saveEntries(entries);
    clearForm();
    const filterId = document.getElementById("filter-student-id").value.trim();
    renderEntries(filterId || undefined);
  });

  document.getElementById("clear-form").addEventListener("click", () => {
    clearForm();
  });

  document.getElementById("apply-filter").addEventListener("click", () => {
    const id = document.getElementById("filter-student-id").value.trim();
    renderEntries(id);
  });

  document.getElementById("clear-filter").addEventListener("click", () => {
    document.getElementById("filter-student-id").value = "";
    renderEntries();
  });

  window.addEventListener("load", () => {
    renderEntries();
  });
</script>

</body>
</html>
