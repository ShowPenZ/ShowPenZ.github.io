const https = require('https');
const path = require('path');
const fs = require('fs');

https.get('https://api.github.com/repos/theme-next/hexo-theme-next/releases', {
  headers: {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36'
  }
}, res => {
  let data = '';
  res.on('data', chunk => {
    data += chunk;
  });
  res.on('end', () => {
    if (res.statusCode === 200) {
      parse(data);
    }
  });
}).on('error', err => {
  console.error('Failded to download release messages.');
  console.log(err);
});

function parse(data) {
  JSON.parse(data).forEach(release => {
    let version = release.html_url.replace('https://github.com/theme-next/hexo-theme-next/releases/tag/v', '');
    console.log('Processing version %s', version);
    let filename = path.join(__dirname, `source/_posts/next-${version.split('.').join('-')}-released.md`);
    if (fs.existsSync(filename)) return;
    let time = release.published_at.replace('T', ' ').replace('Z', '');
    let body = release.body
      .replace(/#(\d{1,4})/g, '[#$1](https://github.com/theme-next/hexo-theme-next/pull/$1)')
      .replace(/([0-9a-f]{7})([0-9a-f]{33})/g, '[$1](http://github.com/theme-next/hexo-theme-next/commit/$1$2)')
      .replace(/\r\n/g, '\n');
    let content = `---
title: NexT ${version} Released
date: ${time}
---

${body}

[Detailed changes for NexT v${version}](https://github.com/theme-next/hexo-theme-next/releases/tag/v${version})
`;
    fs.writeFileSync(filename, content);
  });
}
