import EmojiController from "src/decidim/controllers/emoji/controller";

document.addEventListener("stimulus:load", () => {
  window.Stimulus.register("emoji", EmojiController);
}, { once: true });
