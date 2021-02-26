((exports) => {
  const L = exports.L; // eslint-disable-line

  L.DivIcon.SVGIcon.DecidimIcon = L.DivIcon.SVGIcon.extend({
    options: {
      fillColor: "#ef604d",
      opacity: 0
    },
    _createPathDescription: function() {
      return "M14 1.17a11.685 11.685 0 0 0-11.685 11.685c0 11.25 10.23 20.61 10.665 21a1.5 1.5 0 0 0 2.025 0c0.435-.435 10.665-9.81 10.665-21A11.685 11.685 0 0 0 14 1.17Zm0 17.415A5.085 5.085 0 1 1 19.085 13.5 5.085 5.085 0 0 1 14 18.585Z";
    },
    _createCircle: function() {
      return ""
    },
    // Improved version of the _createSVG, essentially the same as in later
    // versions of Leaflet. It adds the `px` values after the width and height
    // CSS making the focus borders work correctly across all browsers.
    _createSVG: function() {
      const path = this._createPath();
      const circle = this._createCircle();
      const text = this._createText();
      const className = `${this.options.className}-svg`;

      const style = `width:${this.options.iconSize.x}px; height:${this.options.iconSize.y}px;`;

      const svg = `<svg xmlns="http://www.w3.org/2000/svg" version="1.1" class="${className}" style="${style}">${path}${circle}${text}</svg>`;

      return svg;
    }
  });
})(window);
