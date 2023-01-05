import { DOMSerializer } from "prosemirror-model";

const createControl = (position) => {
  const el = document.createElement("div");
  el.dataset.imageResizerControl = position;
  return el;
};

/**
 * Wraps the editor element around the resizable element and implements the
 * resizer functionality.
 *
 * @param {Object} self The node extension to create the view for
 * @returns {Function} The custom node view callback to pass on to TipTap
 */
export default (self) => {
  return ({ editor, node }) => {
    const resizer = document.createElement("div");
    resizer.dataset.imageResizerWrapper = "";
    resizer.append(createControl("top-left"));
    resizer.append(createControl("top-right"));
    resizer.append(createControl("bottom-left"));
    resizer.append(createControl("bottom-right"));

    const contentDOM = DOMSerializer.fromSchema(node.type.schema).serializeNode(node);
    resizer.append(contentDOM);

    const img = contentDOM.querySelector("img");
    let activeResizeControl = null,
        currentSrc = node.attrs.src,
        currentWidth = null,
        naturalWidth = img.naturalWidth,
        originalWidth = null,
        resizeStartPosition = null;

    // Used to reliably get the image width so that it is not reported as zero
    // in case the original image element has not finished loading yet.
    const tmpImg = document.createElement("img");
    tmpImg.onload = () => (naturalWidth = tmpImg.naturalWidth);
    tmpImg.src = img.src;

    const handleMove = (ev) => {
      let diff = resizeStartPosition - ev.clientX;
      if (activeResizeControl.match(/-left$/)) {
        diff *= -1;
      }

      currentWidth = Math.round(originalWidth * (1 - diff / originalWidth));
      if (currentWidth < 100) {
        currentWidth = 100;
      } else if (currentWidth >= naturalWidth) {
        currentWidth = null;
      }

      editor.commands.updateAttributes("image", { width: currentWidth });
    };
    const handleEnd = () => {
      activeResizeControl = resizeStartPosition = null;

      document.removeEventListener("mousemove", handleMove);
      document.removeEventListener("touchmove", handleMove);
      document.removeEventListener("mouseup", handleEnd);
      document.removeEventListener("touchend", handleEnd);
    };
    resizer.querySelectorAll("[data-image-resizer-control]").forEach((ctrl) => {
      const handleStart = (ev) => {
        if (!editor.isEditable || activeResizeControl) {
          return;
        }

        document.addEventListener("mousemove", handleMove);
        document.addEventListener("touchmove", handleMove);
        document.addEventListener("mouseup", handleEnd);
        document.addEventListener("touchend", handleEnd);

        ev.preventDefault();
        activeResizeControl = ctrl.dataset.imageResizerControl;
        originalWidth = editor.getAttributes("image").width || naturalWidth;
        resizeStartPosition = ev.clientX;
      };

      ctrl.addEventListener("mousedown", handleStart);
      ctrl.addEventListener("touchstart", handleStart);
    });

    const dom = document.createElement("div");
    dom.dataset.imageResizer = "";
    dom.append(resizer);

    return {
      dom,
      contentDOM,
      update: (updatedNode) => {
        if (updatedNode.type !== self.type) {
          return false;
        }
        const { alt, src, title, width } = updatedNode.attrs;

        img.alt = alt;
        if (currentSrc !== src) {
          img.src = src;
          currentSrc = src;
        }
        if (title) {
          img.title = title;
        } else {
          img.removeAttribute("title");
        }
        if (width) {
          img.width = width;
        } else {
          img.removeAttribute("width");
        }

        return true;
      }
    };
  };
};
