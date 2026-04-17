import EmojiController from "src/decidim/controllers/emoji/controller";

window.addEventListener("DOMContentLoaded", () => {
  window.Stimulus.register("emoji", EmojiController);
})
