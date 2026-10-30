const CACHE_NAME = 'peggy-travel-map-v5';
const STATIC_ASSETS = [
  './',
  './index.html',
  './data.js',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  'https://cdn.tailwindcss.com',
  'https://unpkg.com/@phosphor-icons/web'
];

// 安裝時快取關鍵檔案，安裝後立即接管
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS).catch((err) => {
        console.warn('Some assets could not be cached immediately:', err);
      });
    })
  );
  self.skipWaiting();
});

// 啟動時清理舊快取，確保釋放空間
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.map((key) => {
          if (key !== CACHE_NAME) {
            return caches.delete(key);
          }
        })
      );
    })
  );
  self.clients.claim();
});

// 快取優先 (Cache-First) 策略：
// 1. 若本機已有快取，直接自快取回傳，【絕不在背景持續發送網路請求】，節省 iOS 流量與電量
// 2. 僅在快取不存在時才走網路請求，並寫入快取供日後離線使用
self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;

  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      if (cachedResponse) {
        // 直接返回本機快取，完全無背景網路流量
        return cachedResponse;
      }

      // 無快取時才請求網路
      return fetch(event.request).then((networkResponse) => {
        if (networkResponse && networkResponse.status === 200) {
          // 只針對同源或允許的靜態資源進行快取備份
          const url = new URL(event.request.url);
          if (url.origin === location.origin || url.hostname.includes('tailwindcss.com') || url.hostname.includes('unpkg.com')) {
            const responseToCache = networkResponse.clone();
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(event.request, responseToCache);
            });
          }
        }
        return networkResponse;
      }).catch((err) => {
        console.warn('Network request failed, no cache available:', err);
        return null;
      });
    })
  );
});
