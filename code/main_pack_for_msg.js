// main workflow - code node "Pack for msg"

// n8n Code node (JavaScript)

function toArray(v) {
  if (Array.isArray(v)) return v;
  if (v === null || v === undefined) return [];
  return [v];
}

function escapeHtml(str = '') {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

function escapeAttr(str = '') {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

const items = $input.all();

let lines = [];
let n = 1;

for (const item of items) {
  const titles = toArray(item.json.youtube_video_title);
  const urls = toArray(item.json.youtube_video_url);

  const len = Math.min(titles.length, urls.length);

  for (let i = 0; i < len; i++) {
    const title = escapeHtml(titles[i]);
    const url = escapeAttr(urls[i]);

    if (!title || !url) continue;

    lines.push(`${n}. <a href="${url}">${title}</a>`);
    n++;
  }
}

const message = lines.join('<br>');

return [{ json: { message } }];

