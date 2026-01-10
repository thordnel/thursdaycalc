const CACHE_NAME = 'thursday-finder-v7';
const ASSETS = [
  './',
  './index.html',
  './pyodide/pyodide.js',
  './pyodide/pyodide.asm.js',
  './pyodide/pyodide.asm.wasm',
  './pyodide/pyodide.asm.data',
  './pyodide/repodata.json',
  './pyodide/pyodide_py.tar',
  './pyodide/distutils.tar',
  './manifest.json',
  './icon.png'
];

self.addEventListener('install', (e) => {
  e.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS);
    })
  );
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys().then((keyList) => {
      return Promise.all(keyList.map((key) => {
        if (key !== CACHE_NAME) {
          return caches.delete(key);
        }
      }));
    })
  );
});

self.addEventListener('fetch', (e) => {
  e.respondWith(
    caches.match(e.request).then((response) => {
      return response || fetch(e.request);
    })
  );
});
