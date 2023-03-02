import { DOMSerializer } from "prosemirror-model";

import { getDictionary } from "src/decidim/i18n";

const createControl = (position, label) => {
  const el = document.createElement("button");
  el.type = "button";
  el.ariaLabel = label;
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
  const i18nResize = getDictionary("editor.extensions.image.nodeView.resizer");
  const createResizeControl = (position) => {
    const label = i18nResize["control.resize"];
    const positionLabel = i18nResize[`position.${position.replace(/-(\w)/, (da, ch) => ch.toUpperCase())}`];

    return createControl(position, label.replace("%position%", positionLabel));
  }

  return ({ editor, node, getPos }) => {
    const resizer = document.createElement("div");
    resizer.dataset.imageResizerWrapper = "";
    resizer.append(createResizeControl("top-left"));
    resizer.append(createResizeControl("top-right"));
    resizer.append(createResizeControl("bottom-left"));
    resizer.append(createResizeControl("bottom-right"));

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
        // The `setTimeout` below is to push the node updates to the next JS
        // event loop so that we are not triggering a change in the element
        // before it is created as would happen e.g. during the Jest tests.
        setTimeout(() => {
          editor.view.dispatch(
            editor.view.state.tr.setNodeMarkup(getPos(), self.type, newAttrs)
          );
        }, 0);
      });
    }
    tmpImg.src = img.src;

    const getEventPagePosition = (ev, device) => {
      if (device === "touch") {
        const originalEv = ev.originalEvent;
        const touches = ev.touches || ev.changedTouches || originalEv.touches || originalEv.changedTouches;
        if (!touches) {
          return { xPos: null, yPos: null };
        }
        const touch = touches[0];
        return { xPos: touch.pageX, yPos: touch.pageY };
      }
      return { xPos: ev.clientX, yPos: ev.clientY };
    };
    const handleMove = (ev, device) => {
      let { xPos } = getEventPagePosition(ev, device);
      let diff = resizeStartPosition - xPos;
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
    const handleMouseMove = (ev) => handleMove(ev, "mouse");
    const handleTouchMove = (ev) => handleMove(ev, "touch");
    const handleEnd = () => {
      activeResizeControl = resizeStartPosition = null;

      document.removeEventListener("mousemove", handleMouseMove);
      document.removeEventListener("touchmove", handleTouchMove);
      document.removeEventListener("mouseup", handleEnd);
      document.removeEventListener("touchend", handleEnd);
    };
    resizer.querySelectorAll("[data-image-resizer-control]").forEach((ctrl) => {
      const handleStart = (ev, device) => {
        // Only allow mouse events to start the resize on the primary button
        // click.
        if (device === "mouse" && ev.button !== 0) {
          return;
        }
        if (!editor.isEditable || activeResizeControl) {
          return;
        }

        document.addEventListener("mousemove", handleMouseMove);
        document.addEventListener("touchmove", handleTouchMove);
        document.addEventListener("mouseup", handleEnd);
        document.addEventListener("touchend", handleEnd);

        ev.preventDefault();
        activeResizeControl = ctrl.dataset.imageResizerControl;
        originalWidth = editor.getAttributes("image").width || naturalWidth;

        resizeStartPosition = getEventPagePosition(ev, device).xPos;
      };
      const handleMouseStart = (ev) => handleStart(ev, "mouse");
      const handleTouchStart = (ev) => handleStart(ev, "touch");

      ctrl.addEventListener("mousedown", handleMouseStart);
      ctrl.addEventListener("touchstart", handleTouchStart);
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

        // We set the value through an attribute change here because otherwise
        // we would trigger a mutation in the DOM which causes the update method
        // to be called recursively.
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
