$(() => {
  // source: https://codepen.io/retrofuturistic/pen/tlbHE
  let dragSrcEl = null;

  function handleDragStart(e) {
    dragSrcEl = this;

    e.dataTransfer.effectAllowed = "move";
    e.dataTransfer.setData("text/html", this.outerHTML);

    this.classList.add("dragging");
  }

  function handleDragOver(e) {
    if (e.preventDefault) {
      e.preventDefault(); // Necessary. Allows us to drop.
    }

    this.classList.add("over");
    e.dataTransfer.dropEffect = "move"; // See the section on the DataTransfer object.

    return false;
  }

  function handleDragLeave(e) {
    this.classList.remove("over");
  }

  function handleDrop(e) {
    if (e.stopPropagation) {
      e.stopPropagation(); // Stops some browsers from redirecting.
    }

    // Don"t do anything if dropping the same column we"re dragging.
    if (dragSrcEl != this) {
      let dropHTML = e.dataTransfer.getData("text/html");
      this.insertAdjacentHTML("beforebegin", dropHTML);
      dragSrcEl.parentElement.removeChild(dragSrcEl)
      let dropElem = this.previousSibling;
      addDnDHandlers(dropElem);
    }

    this.classList.remove("over");
    return false;
  }

  function handleDragEnd(e) {
    this.classList.remove("over");
    this.classList.remove("dragging");
  }

  function addDnDHandlers(elem) {
    elem.addEventListener("dragstart", handleDragStart, false);
    elem.addEventListener("dragover", handleDragOver, false);
    elem.addEventListener("dragleave", handleDragLeave, false);
    elem.addEventListener("drop", handleDrop, false);
    elem.addEventListener("dragend", handleDragEnd, false);
  }

  let cols = document.querySelectorAll(".draggable-list [draggable]");
  [].forEach.call(cols, addDnDHandlers);
});
