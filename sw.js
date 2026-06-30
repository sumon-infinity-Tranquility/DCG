const CACHE_NAME = "dcg-app-v2";
const APP_ASSETS = ["./", "./index.html", "./styles.css", "./app.js", "./firebase-config.js", "./manifest.json"];

self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_ASSETS)));
});

self.addEventListener("fetch", (event) => {
  event.respondWith(caches.match(event.request).then((cached) => cached || fetch(event.request)));
});
