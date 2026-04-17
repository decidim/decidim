import EmojiController from "src/decidim/controllers/emoji/controller";

window.addEventListener("turbo:load", () => {
  window.Stimulus.register("emoji", EmojiController);
})
