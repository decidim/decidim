import { DOMSerializer } from "prosemirror-model";

const createControl = (position) => {
  const el = document.createElement("div");
  el.dataset.imageResizerControl = position;
  return el;
};

const createDimensionDisplay = () => {
  const el = document.createElement("div");
  el.dataset.imageResizerDimensions = "";

  const width = document.createElement("span");
  width.dataset.imageResizerDimension = "width";
  width.dataset.imageResizerDimensionValue = "";

  const height = document.createElement("span");
  height.dataset.imageResizerDimension = "height";
  height.dataset.imageResizerDimensionValue = "";

  el.append(width);
  el.append("×");
  el.append(height);

  return { wrapper: el, width, height };
};

/**
 * Wraps the editor element around the resizable element and implements the
 * resizer functionality.
 *
 * @param {Object} self The node extension to create the view for
 * @returns {Function} The custom node view callback to pass on to TipTap
 */
export default (self) => {
  return ({ editor, node, getPos }) => {
    const resizer = document.createElement("div");
    resizer.dataset.imageResizerWrapper = "";
    resizer.append(createControl("top-left"));
    resizer.append(createControl("top-right"));
    resizer.append(createControl("bottom-left"));
    resizer.append(createControl("bottom-right"));

    const dimensions = createDimensionDisplay();
    resizer.append(dimensions.wrapper);

    const contentDOM = DOMSerializer.fromSchema(node.type.schema).serializeNode(node);
    resizer.append(contentDOM);

    const img = contentDOM.querySelector("img");
    let activeResizeControl = null,
        currentHeight = null,
        currentSrc = node.attrs.src,
        currentWidth = null,
        naturalHeight = img.naturalHeight,
        naturalWidth = img.naturalWidth,
        originalWidth = null,
        resizeStartPosition = null;

    // Used to reliably get the image width so that it is not reported as zero
    // in case the original image element has not finished loading yet.
    const tmpImg = document.createElement("img");
    const { width: givenWidth } = node.attrs;
    tmpImg.onload = () => {
      naturalWidth = tmpImg.naturalWidth;
      naturalHeight = tmpImg.naturalHeight;

      // Set currentWidth and currentHeight
      if (givenWidth === null) {
        currentWidth = naturalWidth;
        currentHeight = naturalHeight;
      } else {
        currentWidth = givenWidth;
        currentHeight = Math.round(naturalHeight * (currentWidth / naturalWidth));
      }

      // Force node update in order to set the initial dimensions
      [{ ...node.attrs, width: 1 }, node.attrs].forEach((newAttrs) => {
        setTimeout(() => {
          editor.view.dispatch(
            editor.view.state.tr.setNodeMarkup(getPos(), self.type, newAttrs)
          );
        }, 0);
      });
    }
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
        currentWidth = naturalWidth;
      }
      currentHeight = Math.round(naturalHeight * (currentWidth / naturalWidth));

      let width = currentWidth;
      if (width >= naturalWidth) {
        width = null;
      }
      editor.commands.updateAttributes("image", { width });
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
    // dimensions.width.dataset.imageResizerDimensionValue = currentWidth;
    // dimensions.height.dataset.imageResizerDimensionValue = currentHeight;
    return {
      dom,
      contentDOM,
      update: (updatedNode) => {
        if (updatedNode.type !== self.type) {
          return false;
        }

        const { alt, src, title, width } = updatedNode.attrs;

        dimensions.width.dataset.imageResizerDimensionValue = currentWidth;
        dimensions.height.dataset.imageResizerDimensionValue = currentHeight;

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
