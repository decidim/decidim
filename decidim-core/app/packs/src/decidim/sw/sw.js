import {
  imageCache,
  staticResourceCache,
  offlineFallback
} from "workbox-recipes";
import { registerRoute } from "workbox-routing";
import { NetworkFirst } from "workbox-strategies";
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

const cacheName = "pages";
const matchCallback = ({ request }) => request.mode === "navigate";
const networkTimeoutSeconds = 3;
const maxAgeSeconds = 60 * 60;

// https://developers.google.com/web/tools/workbox/modules/workbox-recipes#pattern_3
registerRoute(
  matchCallback,
  new NetworkFirst({
    networkTimeoutSeconds,
    cacheName,
    plugins: [
      new CacheableResponsePlugin({
        statuses: [0, 200]
      }),
      new ExpirationPlugin({
        maxAgeSeconds
      })
    ]
  }),
);

// common recipes
staticResourceCache();

imageCache();

offlineFallback({ pageFallback: "/offline" });
