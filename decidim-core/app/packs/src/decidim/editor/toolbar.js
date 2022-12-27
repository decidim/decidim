import InputModal from "src/decidim/editor/input_modal";

import iconsUrl from "images/decidim/remixicon.symbol.svg";

const createIcon = (iconName, options = {}) => {
  const transformations = [];
  if (options.verticalFlip) {
    transformations.push("scaleY(-1)");
  }
  if (options.horizontalFlip) {
    transformations.push("scaleX(-1)");
  }

  let styleAttr = "";
  if (transformations) {
    styleAttr += `transform:${transformations.join(" ")};`;
  }

  return `<svg class="editor-toolbar-icon" role="img" aria-hidden="true" style="${styleAttr}">
    <use href="${iconsUrl}#ri-${iconName}" />
  </svg>`;
}

const createEditorToolbarGroup = (editor, { items }) => {
  const group = document.createElement("div")
  group.classList.add("editor-toolbar-group");
  items.forEach((item) => group.appendChild(item));
  return group;
}

const createEditorToolbarToggle = (editor, { label, icon, action }) => {
  const ctrl = document.createElement("button");
  ctrl.classList.add("editor-toolbar-control");
  ctrl.type = "button";
  ctrl.ariaLabel = label;
  ctrl.title = label;
  if (typeof icon === "function") {
    ctrl.innerHTML = icon();
  } else {
    ctrl.innerHTML = createIcon(icon);
  }
  ctrl.addEventListener("click", (ev) => {
    ev.preventDefault();
    editor.commands.focus();
    action();
  })
  return ctrl;
}

const createEditorToolbarSelect = (editor, { label, options, action }) => {
  const ctrl = document.createElement("select");
  ctrl.classList.add("editor-toolbar-control");
  ctrl.ariaLabel = label;
  ctrl.title = label;
  options.forEach(({ label: optionLabel, value }) => {
    const option = document.createElement("option");
    option.setAttribute("value", value);
    option.innerText = optionLabel;
    ctrl.appendChild(option);
  });
  ctrl.addEventListener("change", () => {
    editor.commands.focus();
    action(ctrl.value);
  });
  return ctrl;
}

/**
 * Creates the editor toolbar for the given editor instance.
 *
 * @param {Editor} editor An instance of the rich text editor.
 * @returns {HTMLElement} The toolbar element
 */
export default function createEditorToolbar(editor) {
  const toolbar = document.createElement("div");
  toolbar.classList.add("editor-toolbar");

  const linkModal = new InputModal({
    inputs: { href: { label: "Please insert the link below" } },
    removeButton: true
  });
  const videoModal = new InputModal({
    inputs: { src: { label: "Please insert the video URL below" } }
  });
  const imageModal = new InputModal({
    inputs: {
      src: { label: "Please insert the image URL below" },
      alt: { label: "Please provide an alternative text for the image" }
    }
  });

  toolbar.appendChild(
    createEditorToolbarGroup(editor, {
      items: [
        createEditorToolbarSelect(editor, {
          label: "Text style",
          options: [
            { value: "normal", label: "Normal" },
            { value: 2, label: "Heading 2" },
            { value: 3, label: "Heading 3" },
            { value: 4, label: "Heading 4" },
            { value: 5, label: "Heading 5" },
            { value: 6, label: "Heading 6" }
          ],
          action: (value) => {
            if (value === "normal") {
              editor.commands.setParagraph();
            } else {
              editor.commands.toggleHeading({ level: parseInt(value, 10) });
            }
          }
        })
      ]
    })
  );
  toolbar.appendChild(
    createEditorToolbarGroup(editor, {
      items: [
        createEditorToolbarToggle(editor, {
          label: "Bold",
          icon: "bold",
          action: () => editor.commands.toggleBold()
        }),
        createEditorToolbarToggle(editor, {
          label: "Italic",
          icon: "italic",
          action: () => editor.commands.toggleItalic()
        }),
        createEditorToolbarToggle(editor, {
          label: "Underline",
          icon: "underline",
          action: () => editor.commands.toggleUnderline()
        }),
        createEditorToolbarToggle(editor, {
          label: "Line break",
          icon: "text-wrap",
          action: () => editor.commands.setHardBreak()
        })
      ]
    })
  );
  toolbar.appendChild(
    createEditorToolbarGroup(editor, {
      items: [
        createEditorToolbarToggle(editor, {
          label: "Ordered list",
          icon: "list-ordered",
          action: () => editor.commands.toggleOrderedList()
        }),
        createEditorToolbarToggle(editor, {
          label: "Unordered list",
          icon: "list-unordered",
          action: () => editor.commands.toggleBulletList()
        })
      ]
    })
  );
  toolbar.appendChild(
    createEditorToolbarGroup(editor, {
      items: [
        createEditorToolbarToggle(editor, {
          label: "Link",
          icon: "link",
          action: () => {
            linkModal.toggle((state) => {
              if (state === "save") {
                editor.commands.setLink({ href: linkModal.getValue("href") })
              } else {
                editor.commands.unsetLink();
              }
            }, { href: editor.getAttributes("link").href });
          }
        }),
        createEditorToolbarToggle(editor, {
          label: "Erase styles",
          icon: "eraser-line",
          action: () => editor.chain().focus().clearNodes().unsetAllMarks().run()
        })
      ]
    })
  );
  toolbar.appendChild(
    createEditorToolbarGroup(editor, {
      items: [
        createEditorToolbarToggle(editor, {
          label: "Code block",
          icon: "code-line",
          action: () => editor.commands.toggleCodeBlock()
        }),
        createEditorToolbarToggle(editor, {
          label: "Blockquote",
          icon: "double-quotes-l",
          action: () => editor.commands.toggleBlockquote()
        })
      ]
    })
  );
  toolbar.appendChild(
    createEditorToolbarGroup(editor, {
      items: [
        createEditorToolbarToggle(editor, {
          label: "Indent",
          icon: "indent-increase",
          action: () => editor.commands.indent()
        }),
        createEditorToolbarToggle(editor, {
          label: "Outdent",
          icon: "indent-decrease",
          action: () => editor.commands.outdent()
        })
      ]
    })
  );
  toolbar.appendChild(
    createEditorToolbarGroup(editor, {
      items: [
        createEditorToolbarToggle(editor, {
          label: "Video",
          icon: "video-line",
          action: () => {
            videoModal.toggle((state) => {
              if (state === "save") {
                editor.commands.setYoutubeVideo({
                  src: videoModal.getValue("src"),
                  width: 640,
                  height: 480
                });
              }
            })
          }
        }),
        createEditorToolbarToggle(editor, {
          label: "Image",
          icon: "image-line",
          action: () => {
            imageModal.toggle((state) => {
              if (state === "save") {
                editor.commands.setImage({
                  src: imageModal.getValue("src"),
                  alt: imageModal.getValue("alt")
                });
              }
            })
          }
        })
      ]
    })
  );

  return toolbar;
}
