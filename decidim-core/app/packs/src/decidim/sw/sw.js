import {
  imageCache,
  staticResourceCache,
  offlineFallback
} from "workbox-recipes";
import { registerRoute } from "workbox-routing";
import { NetworkFirst, NetworkOnly } from "workbox-strategies";
import { CacheableResponsePlugin } from "workbox-cacheable-response";
import { ExpirationPlugin } from "workbox-expiration";


// https://developers.google.com/web/tools/workbox/guides/troubleshoot-and-debug#debugging_workbox
self.__WB_DISABLE_DEV_LOGS = true

/**
 * This is a workaround to bypass a webpack compilation error
 *
 * The InjectManifest function requires the __WB_MANIFEST somewhere in this file,
 * however, we cannot add precacheAndRoute as the issue suggests,
 * as the other workbox-recipes won't work properly
 *
 * See more: https://github.com/GoogleChrome/workbox/issues/2519#issuecomment-634164566
 */
// eslint-disable-next-line no-unused-vars
const dummy = self.__WB_MANIFEST;

// avoid caching admin or users paths
registerRoute(
  ({ url }) => ["/admin/", "/users/"].some((path) => url.pathname.startsWith(path)),
  new NetworkOnly()
);

// https://developers.google.com/web/tools/workbox/modules/workbox-recipes#pattern_3
registerRoute(
  ({ request }) => request.mode === "navigate",
  new NetworkFirst({
    networkTimeoutSeconds: 3,
    cacheName: "pages",
    plugins: [
      new CacheableResponsePlugin({
        statuses: [0, 200]
      }),
      new ExpirationPlugin({
        maxAgeSeconds: 60 * 60
      })
    ]
  }),
);

// common recipes
staticResourceCache();

imageCache();

offlineFallback({ pageFallback: "/offline" });
