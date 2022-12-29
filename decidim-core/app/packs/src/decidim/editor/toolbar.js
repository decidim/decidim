import iconsUrl from "images/decidim/remixicon.symbol.svg";

const createIcon = (iconName) => {
  return `<svg class="editor-toolbar-icon" role="img" aria-hidden="true">
    <use href="${iconsUrl}#ri-${iconName}" />
  </svg>`;
}

const createEditorToolbarGroup = (_editor, inner) => {
  const group = document.createElement("div");
  group.classList.add("editor-toolbar-group");
  inner(group);

  return group;
}

const createEditorToolbarToggle = (editor, { type, label, icon, action, activatable = true }) => {
  const ctrl = document.createElement("button");
  ctrl.classList.add("editor-toolbar-control");
  ctrl.dataset.editorType = type;
  if (activatable) {
    ctrl.dataset.editorSelectionType = type;
  }
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

const createEditorToolbarSelect = (editor, { type, label, options, action, activatable = true }) => {
  const ctrl = document.createElement("select");
  ctrl.classList.add("editor-toolbar-control");
  ctrl.dataset.editorType = type;
  if (activatable) {
    ctrl.dataset.editorSelectionType = type;
  }
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

  toolbar.appendChild(
    createEditorToolbarGroup(editor, (group) => {
      group.appendChild(
        createEditorToolbarSelect(editor, {
          type: "heading",
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
      );
    })
  );
  toolbar.appendChild(
    createEditorToolbarGroup(editor, (group) => {
      group.appendChild(
        createEditorToolbarToggle(editor, {
          type: "bold",
          icon: "bold",
          label: "Bold",
          action: () => editor.commands.toggleBold()
        })
      );
      group.appendChild(
        createEditorToolbarToggle(editor, {
          type: "italic",
          icon: "italic",
          label: "Italic",
          action: () => editor.commands.toggleItalic()
        })
      );
      group.appendChild(
        createEditorToolbarToggle(editor, {
          type: "underline",
          icon: "underline",
          label: "Underline",
          action: () => editor.commands.toggleUnderline()
        })
      );
      group.appendChild(
        createEditorToolbarToggle(editor, {
          type: "hardBreak",
          icon: "text-wrap",
          label: "Line break",
          activatable: false,
          action: () => editor.commands.setHardBreak()
        })
      );
    })
  );
  toolbar.appendChild(
    createEditorToolbarGroup(editor, (group) => {
      group.appendChild(
        createEditorToolbarToggle(editor, {
          type: "orderedList",
          icon: "list-ordered",
          label: "Ordered list",
          action: () => editor.commands.toggleOrderedList()
        })
      );
      group.appendChild(
        createEditorToolbarToggle(editor, {
          type: "bulletList",
          icon: "list-unordered",
          label: "Unordered list",
          action: () => editor.commands.toggleBulletList()
        })
      );
    })
  );
  toolbar.appendChild(
    createEditorToolbarGroup(editor, (group) => {
      group.appendChild(
        createEditorToolbarToggle(editor, {
          type: "link",
          icon: "link",
          label: "Link",
          action: () => editor.commands.linkModal()
        })
      );
      group.appendChild(
        createEditorToolbarToggle(editor, {
          type: "common:eraseStyles",
          icon: "eraser-line",
          label: "Erase styles",
          activatable: false,
          action: () => editor.chain().focus().clearNodes().unsetAllMarks().run()
        })
      );
    })
  );
  toolbar.appendChild(
    createEditorToolbarGroup(editor, (group) => {
      group.appendChild(
        createEditorToolbarToggle(editor, {
          type: "codeBlock",
          icon: "code-line",
          label: "Code block",
          action: () => editor.commands.toggleCodeBlock()
        })
      );
      group.appendChild(
        createEditorToolbarToggle(editor, {
          type: "blockquote",
          icon: "double-quotes-l",
          label: "Blockquote",
          action: () => editor.commands.toggleBlockquote()
        })
      );
    })
  );
  toolbar.appendChild(
    createEditorToolbarGroup(editor, (group) => {
      group.appendChild(
        createEditorToolbarToggle(editor, {
          type: "indent:indent",
          icon: "indent-increase",
          label: "Indent",
          activatable: false,
          action: () => editor.commands.indent()
        })
      );
      group.appendChild(
        createEditorToolbarToggle(editor, {
          type: "indent:outdent",
          icon: "indent-decrease",
          label: "Outdent",
          activatable: false,
          action: () => editor.commands.outdent()
        })
      );
    })
  );
  toolbar.appendChild(
    createEditorToolbarGroup(editor, (group) => {
      group.appendChild(
        createEditorToolbarToggle(editor, {
          type: "videoEmbed",
          icon: "video-line",
          label: "Video",
          action: () => editor.commands.videoEmbedModal()
        })
      );
      group.appendChild(
        createEditorToolbarToggle(editor, {
          type: "image",
          icon: "image-line",
          label: "Image",
          action: () => editor.commands.imageModal()
        })
      );
    })
  );

  const selectionControls = toolbar.querySelectorAll(".editor-toolbar-control[data-editor-selection-type]");
  const headingSelect = toolbar.querySelector(".editor-toolbar-control[data-editor-type='heading']");
  const selectionUpdated = () => {
    if (editor.isActive("heading")) {
      const { level } = editor.getAttributes("heading");
      headingSelect.value = `${level}`;
    } else {
      headingSelect.value = "normal";
    }

    selectionControls.forEach((ctrl) => {
      if (editor.isActive(ctrl.dataset.editorSelectionType)) {
        ctrl.classList.add("active");
      } else {
        ctrl.classList.remove("active");
      }
    });
  }
  editor.on("update", selectionUpdated);
  editor.on("selectionUpdate", selectionUpdated);

  return toolbar;
}
