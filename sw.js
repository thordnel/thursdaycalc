const CACHE_NAME = 'thursday-finder-v2';
const ASSETS = [
  './',
  './index.html',
  './pyscript.css',
  './pyodide/pyodide.js',
  './pyodide/pyodide.asm.js',
  './pyodide/pyodide.asm.wasm',
  './pyodide/pyodide.asm.data',
  './pyodide/repodata.json',
  './pyodide/pyodide_py.tar'
];

self.addEventListener('install', (e) => {
  e.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS);
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
