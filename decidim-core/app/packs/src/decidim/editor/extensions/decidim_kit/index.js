import { Extension } from "@tiptap/core";

import StarterKit from "@tiptap/starter-kit";
import CodeBlock from "@tiptap/extension-code-block";
import Underline from "@tiptap/extension-underline";

import CharacterCount from "src/decidim/editor/extensions/character_count";
import Bold from "src/decidim/editor/extensions/bold";
import Dialog from "src/decidim/editor/extensions/dialog";
import Heading from "src/decidim/editor/extensions/heading";
import OrderedList from "src/decidim/editor/extensions/ordered_list";
import Image from "src/decidim/editor/extensions/image";
import Indent from "src/decidim/editor/extensions/indent";
import Link from "src/decidim/editor/extensions/link";
import Mention from "src/decidim/editor/extensions/mention";
import MentionResource from "src/decidim/editor/extensions/mention_resource";
import VideoEmbed from "src/decidim/editor/extensions/video_embed";
import Emoji from "src/decidim/editor/extensions/emoji";

export default Extension.create({
  name: "decidimKit",

  addOptions() {
    return {
      characterCount: { limit: null },
      heading: { levels: [2, 3, 4, 5, 6] },
      link: { allowTargetControl: false },
      videoEmbed: false,
      image: {
        uploadDialogSelector: null,
        uploadImagesPath: null,
        contentTypes: /^image\/(jpe?g|png|svg|webp)$/i
      },
      mention: false,
      mentionResource: false,
      emoji: false
    };
  },

  addExtensions() {
    const extensions = [
      StarterKit.configure({
        heading: false,
        bold: false,
        orderedList: false,
        codeBlock: false
      }),
      CharacterCount.configure(this.options.characterCount),
      Link.configure({ openOnClick: false, ...this.options.link }),
      Bold,
      Dialog,
      Indent,
      OrderedList,
      CodeBlock,
      Underline
    ];

    if (this.options.heading !== false) {
      extensions.push(Heading.configure(this.options.heading));
    }

    if (this.options.videoEmbed !== false) {
      extensions.push(VideoEmbed.configure(this.options.videoEmbed));
    }

    if (this.options.image !== false && this.options.image.uploadDialogSelector) {
      extensions.push(Image.configure(this.options.image));
    }

    if (this.options.mention !== false) {
      extensions.push(Mention.configure(this.options.mention));
    }

    if (this.options.mentionResource !== false) {
      extensions.push(MentionResource.configure(this.options.mentionResource));
    }

    if (this.options.emoji !== false) {
      extensions.push(Emoji.configure(this.options.emoji));
    }

    return extensions;
  }
});
