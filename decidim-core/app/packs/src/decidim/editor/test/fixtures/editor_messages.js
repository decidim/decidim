export default {
  extensions: {
    image: {
      altLabel: "Alternative text for the image",
      uploadError: "Uploading the file failed.",
      nodeView: {
        resizer: {
          control: { resize: "Resize image (%position%)" },
          position: {
            bottomLeft: "bottom left corner",
            bottomRight: "bottom right corner",
            topLeft: "top left corner",
            topRight: "top right corner"
          }
        }
      }
    },
    link: {
      bubbleMenu: { edit: "Edit", remove: "Remove", url: "URL" },
      hrefLabel: "Link URL",
      targetLabel: "Target",
      targets: { blank: "New tab", default: "Default (same tab)" }
    },
    videoEmbed: {
      titleLabel: "Title",
      urlLabel: "Video URL"
    }
  },
  inputDialog: {
    buttons: {
      cancel: "Cancel",
      remove: "Remove",
      save: "Save"
    },
    close: "Close modal"
  },
  toolbar: {
    control: {
      blockquote: "Blockquote",
      bold: "Bold",
      bulletList: "Unordered list",
      codeBlock: "Code block",
      common: { eraseStyles: "Erase styles" },
      hardBreak: "Line break",
      heading: "Text style",
      image: "Image",
      indent: { indent: "Indent", outdent: "Outdent" },
      italic: "Italic",
      link: "Link",
      orderedList: "Ordered list",
      underline: "Underline",
      videoEmbed: "Video embed"
    },
    textStyle: { heading: "Heading %level%", normal: "Normal" }
  },
  upload: { uploadedFile: "Uploaded file" }
};
