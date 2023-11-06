import { Node, nodePasteRule, mergeAttributes } from "@tiptap/core";
import { Plugin } from "prosemirror-state";

import { getDictionary } from "src/decidim/i18n";
import InputDialog from "src/decidim/editor/common/input_dialog";

const YOUTUBE_REGEX = /^(https?:\/\/)?(www\.|music\.)?(youtube\.com|youtu\.be)(.+)?$/;
const YOUTUBE_REGEX_GLOBAL = /^(https?:\/\/)?(www\.|music\.)?(youtube\.com|youtu\.be)(.+)?$/g;
const VIMEO_REGEX = /^(https?:\/\/)?(www\.|player\.)?(vimeo\.com)(.+)?$/;
const VIMEO_REGEX_GLOBAL = /^(https?:\/\/)?(www\.|player\.)?(vimeo\.com)(.+)?$/g;

const isValidYoutubeUrl = (url) => {
  return url.match(YOUTUBE_REGEX);
}

const isValidVimeoUrl = (url) => {
  return url.match(VIMEO_REGEX);
};

const getEmbedUrlFromYoutubeUrl = (options) => {
  const embedUrl = "https://www.youtube-nocookie.com/embed/";

  const { url } = options;

  // if is already an embed url, return it
  if (url.includes("/embed/")) {
    return url;
  }

  // if is a youtu.be url, get the id after the /
  if (url.includes("youtu.be")) {
    const id = url.split("/").pop();

    if (!id) {
      return null;
    }
    return `${embedUrl}${id}`;
  }

  const videoIdRegex = /v=([-\w]+)/gm;
  const matches = videoIdRegex.exec(url);

  if (!matches || !matches[1]) {
    return null;
  }

  let outputUrl = `${embedUrl}${matches[1]}`;

  const params = {
    ccLoadPolicy: 1,
    modestbranding: 1
  };

  const urlParams = {};
  Object.keys(params).forEach((key) => {
    const urlKey = key.replace(/[A-Z]/g, (char) => `_${char.toLowerCase()}`);
    urlParams[urlKey] = params[key];
  });

  return `${outputUrl}?${new URLSearchParams(urlParams)}`;
}

const getEmbedUrlFromVimeoUrl = (options) => {
  const embedUrl = "https://player.vimeo.com/video/";

  const { url } = options;

  const cleanUrl = url.split("?").shift();
  const id = cleanUrl.split("/").pop();

  return `${embedUrl}${id}`;
}

const getEmbedUrlFromVideoUrl = (options) => {
  const { url } = options;

  if (isValidYoutubeUrl(url)) {
    return getEmbedUrlFromYoutubeUrl(options);
  } else if (isValidVimeoUrl(url)) {
    return getEmbedUrlFromVimeoUrl(options);
  }

  return url;
}

/**
 * Video embed extension for the Tiptap editor.
 *
 * Based on the original `@tiptap/extension-youtube` extension with support to
 * other embedding services than only YouTube.
 */
export default Node.create({
  name: "videoEmbed",
  draggable: true,

  addOptions() {
    return {
      height: null,
      width: null,
      inline: false
    }
  },

  inline() {
    return this.options.inline;
  },

  group() {
    if (this.options.inline) {
      return "inline";
    }
    return "block";
  },

  addAttributes() {
    return {
      src: {
        default: null,
        parseHTML: (element) => {
          const wrapper = element?.parentElement?.parentElement;
          const embedUrl = wrapper?.dataset?.videoEmbed;
          if (embedUrl && embedUrl.length > 0) {
            return embedUrl;
          }
          return element.src;
        }
      },
      title: { default: null },
      width: { default: this.options.width },
      height: { default: this.options.height },
      frameborder: { default: 0 },
      allowfullscreen: { default: true }
    };
  },

  parseHTML() {
    return [{ tag: "div[data-video-embed] div iframe" }];
  },

  addCommands() {
    const i18n = getDictionary("editor.extensions.videoEmbed");

    return {
      setVideo: (options) => ({ commands }) => {
        return commands.insertContent({
          type: this.name,
          attrs: options
        });
      },

      videoEmbedDialog: () => async ({ dispatch }) => {
        if (dispatch) {
          const videoDialog = new InputDialog(this.editor, {
            inputs: {
              src: { type: "text", label: i18n.urlLabel },
              title: { type: "text", label: i18n.titleLabel }
            }
          });
          let { src, title } = this.editor.getAttributes("videoEmbed");

          const dialogState = await videoDialog.toggle({ src, title });
          if (dialogState !== "save") {
            return false;
          }

          src = videoDialog.getValue("src");
          title = videoDialog.getValue("title");
          if (!src || src.length < 1) {
            this.editor.commands.focus(null, { scrollIntoView: false });
            return false;
          }

          return this.editor.chain().setVideo({ src, title }).focus(null, { scrollIntoView: false }).run();
        }

        return true;
      }
    }
  },

  addPasteRules() {
    return [
      nodePasteRule({
        find: YOUTUBE_REGEX_GLOBAL,
        type: this.type,
        getAttributes: (match) => {
          return { src: match.input, title: "" };
        }
      }),
      nodePasteRule({
        find: VIMEO_REGEX_GLOBAL,
        type: this.type,
        getAttributes: (match) => {
          return { src: match.input, title: "" };
        }
      })
    ];
  },

  renderHTML({ HTMLAttributes }) {
    const { src } = HTMLAttributes;
    HTMLAttributes.src = getEmbedUrlFromVideoUrl({ url: src  });

    return [
      "div",
      { "class": "editor-content-videoEmbed", "data-video-embed": src },
      [
        "div",
        {},
        [
          "iframe",
          mergeAttributes(
            {
              width: this.options.width,
              height: this.options.height
            },
            HTMLAttributes
          )
        ]
      ]
    ];
  },

  addProseMirrorPlugins() {
    const editor = this.editor;

    return [
      new Plugin({
        props: {
          handleDoubleClick() {
            if (!editor.isActive("videoEmbed")) {
              return false;
            }

            editor.chain().focus().videoEmbedDialog().run();
            return true;
          }
        }
      })
    ];
  }
})
