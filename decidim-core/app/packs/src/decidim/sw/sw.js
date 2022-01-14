import {
  pageCache,
  imageCache,
  staticResourceCache,
  offlineFallback
} from "workbox-recipes";
import { setDefaultHandler } from "workbox-routing";
import { NetworkOnly } from "workbox-strategies";

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

pageCache()

staticResourceCache();

imageCache();

setDefaultHandler(
  new NetworkOnly()
);

offlineFallback({ pageFallback: "/offline" });
