// import { registerRoute, NavigationRoute } from "workbox-routing";
// import { NetworkFirst, CacheFirst, NetworkOnly } from "workbox-strategies";
import { CacheableResponsePlugin } from "workbox-cacheable-response";
import { ExpirationPlugin } from "workbox-expiration";
// import * as navigationPreload from 'workbox-navigation-preload';
import {
  pageCache,
  imageCache,
  staticResourceCache,
  offlineFallback
} from "workbox-recipes";
import { setDefaultHandler, registerRoute } from "workbox-routing";
import { NetworkOnly, NetworkFirst } from "workbox-strategies";


const log = (...logs) =>
  console.log(`${"=".repeat(100)}

${logs.map((x) => JSON.stringify(x, null, 2)).join("\n")}

${"=".repeat(100)}`)

log(`version: ${new Date().toLocaleTimeString()}`);

// pageCache({
//   matchCallback: ({ request }) => {
//     log("DEPURAÇAO", request);

//     return request.destination === "document" || (
//       request.destination === "" &&
//       request.mode === "cors" &&
//       request.headers.get("Turbolinks-Referrer") !== null
//     )
//   }
// })

// staticResourceCache();

// imageCache();

setDefaultHandler(
  new NetworkOnly()
);

offlineFallback();
// offlineFallback({ pageFallback: "/offline" });

// Loading pages (and turbolinks requests), checks the network first
// registerRoute(
//   ({ request }) => {
//     console.log(1, request);
//     log("DEPURAÇAO", request);

//     return request.destination === "document" || (
//       request.destination === "" &&
//       request.mode === "cors" &&
//       request.headers.get("Turbolinks-Referrer") !== null
//     )
//   },
//   new NetworkFirst({
//     cacheName: "documents",
//     plugins: [
//       new ExpirationPlugin({
//         maxEntries: 5,
//         // 5 minutes
//         maxAgeSeconds: 5 * 60
//       }),
//       new CacheableResponsePlugin({
//         statuses: [0, 200]
//       })
//     ]
//   })
// );

// // images
// registerRoute(
//   ({request}) => request.destination === "image",
//   new CacheFirst({
//     cacheName: "images",
//     plugins: [
//       new ExpirationPlugin({
//         maxEntries: 60,
//         // 30 Days
//         maxAgeSeconds: 30 * 24 * 60 * 60
//       })
//     ]
//   })
// );

// // Load CSS & JS from the Cache
// registerRoute(
//   ({request}) => request.destination === "script" ||
//   request.destination === "style",
//   new CacheFirst({
//     cacheName: "assets-styles-and-scripts",
//     plugins: [
//       new ExpirationPlugin({
//         maxEntries: 10,
//         // 30 Days
//         maxAgeSeconds: 60 * 60 * 24 * 30
//       }),
//       new CacheableResponsePlugin({
//         statuses: [0, 200]
//       })
//     ]
//   })
// );
