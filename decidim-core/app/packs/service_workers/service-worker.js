import { registerRoute } from "workbox-routing";
import { NetworkFirst, CacheFirst } from "workbox-strategies";
import { CacheableResponsePlugin } from "workbox-cacheable-response";
import { ExpirationPlugin } from "workbox-expiration";

// Loading pages (and turbolinks requests), checks the network first
registerRoute(
  ({request}) => request.destination === "document" || (
    request.destination === "" &&
    request.mode === "cors" &&
    request.headers.get("Turbolinks-Referrer") !== null
  ),
  new NetworkFirst({
    cacheName: "documents",
    plugins: [
      new ExpirationPlugin({
        maxEntries: 5,
        // 5 minutes
        maxAgeSeconds: 5 * 60
      }),
      new CacheableResponsePlugin({
        statuses: [0, 200]
      })
    ]
  })
);

// images
registerRoute(
  ({request}) => request.destination === "image",
  new CacheFirst({
    cacheName: "images",
    plugins: [
      new ExpirationPlugin({
        maxEntries: 60,
        // 30 Days
        maxAgeSeconds: 30 * 24 * 60 * 60
      })
    ]
  })
);

// Load CSS & JS from the Cache
registerRoute(
  ({request}) => request.destination === "script" ||
  request.destination === "style",
  new CacheFirst({
    cacheName: "assets-styles-and-scripts",
    plugins: [
      new ExpirationPlugin({
        maxEntries: 10,
        // 30 Days
        maxAgeSeconds: 60 * 60 * 24 * 30
      }),
      new CacheableResponsePlugin({
        statuses: [0, 200]
      })
    ]
  })
);


// PUSH notifications
// self.addEventListener("push", (event) => {
//   console.log("[SW]: push");
//   const { title = "No title", body = "No body", ...opts } = event.data.json();
//   const text = opts.friends > 1
//     ? `You have ${opts.friends} subscriptors!!`
//     : title
//   event.waitUntil(self.registration.showNotification(text, { body, ...opts }));
// });
