import { Node, nodePasteRule, mergeAttributes } from "@tiptap/core";
import { Plugin } from "prosemirror-state";

import InputModal from "src/decidim/editor/input_modal";

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
    return url
  }

  // if is a youtu.be url, get the id after the /
  if (url.includes("youtu.be")) {
    const id = url.split("/").pop();

    if (!id) {
      return null
    }
    return `${embedUrl}${id}`
  }

  const videoIdRegex = /v=([-\w]+)/gm
  const matches = videoIdRegex.exec(url)

  if (!matches || !matches[1]) {
    return null
  }

  let outputUrl = `${embedUrl}${matches[1]}`

  const params = {
    hl: "en",
    ccLangPref: "en",
    ccLoadPolicy: 1,
    modestbranding: 1
  }

  const urlParams = {};
  Object.keys(params).forEach((key) => {
    const urlKey = key.replace(/[A-Z]/g, (char) => `_${char.toLowerCase()}`);
    urlParams[urlKey] = params[key];
  })

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
  name: "video",
  draggable: true,

  addOptions() {
    return {
      height: 360,
      width: 640,
      inline: false
    }
  },

  inline() {
    return this.options.inline
  },

  group() {
    if (this.options.inline) {
      return "inline";
    }
    return "block";
  },

  addAttributes() {
    return {
      src: { default: null },
      width: { default: this.options.width },
      height: { default: this.options.height },
      frameborder: { default: 0 }
    }
  },

  parseHTML() {
    return [{ tag: "div[data-video-embed] iframe" }]
  },

  addCommands() {
    return {
      setVideo: (options) => ({ commands }) => {
        return commands.insertContent({
          type: this.name,
          attrs: options
        });
      },

      videoModal: (node) => async ({ view, dispatch, state, commands }) => {
        if (dispatch) {
          const videoModal = new InputModal({
            inputs: { src: { label: "Please insert the video URL below" } }
          });
          let src = node?.attrs?.src;

          const modalState = await videoModal.toggle({ src });
          if (modalState !== "save") {
            return false;
          }

          src = videoModal.getValue("src");

          // Note that `commands.setVideo(...)` won't work here because
          // apparently TipTap does not understand the async behavior of the
          // command, so we need to manually dispatch the change.
          const position = state.selection.anchor;
          if (node) {
            const transaction = state.tr.setNodeMarkup(position, null, { src });
            view.dispatch(transaction);
          } else {
            const videoNode = state.schema.nodes.video.create({ src });
            const transaction = state.tr.insert(position, videoNode);
            view.dispatch(transaction);
          }

          commands.focus();
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
          return { src: match.input }
        }
      }),
      nodePasteRule({
        find: VIMEO_REGEX_GLOBAL,
        type: this.type,
        getAttributes: (match) => {
          return { src: match.input }
        }
      })
    ];
  },

  renderHTML({ HTMLAttributes }) {
    const embedUrl = getEmbedUrlFromVideoUrl({
      url: HTMLAttributes.src
    });

    HTMLAttributes.src = embedUrl

    return [
      "div",
      { "data-video-embed": "" },
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
  },

  addProseMirrorPlugins() {
    const editor = this.editor;

    return [
      new Plugin({
        props: {
          handleDoubleClick(view) {
            const node = view.state.selection.node;
            if (node.type.name !== "video") {
              return false;
            }

            editor.chain().focus().videoModal(node).run();
            return true;
          }
        }
      })
    ];
  }
})
