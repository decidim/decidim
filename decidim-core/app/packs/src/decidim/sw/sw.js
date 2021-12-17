import {
  pageCache,
  imageCache,
  staticResourceCache,
  offlineFallback
} from "workbox-recipes";
import { setDefaultHandler } from "workbox-routing";
import { NetworkOnly } from "workbox-strategies";

pageCache()
// pageCache({
//   matchCallback: ({ request }) => request.destination === "document" || (
//     request.destination === "" &&
//     request.mode === "cors" &&
//     request.headers.get("Turbolinks-Referrer") !== null
//   )
// })

staticResourceCache();

imageCache();

setDefaultHandler(
  new NetworkOnly()
);

offlineFallback({ pageFallback: "/offline" });
