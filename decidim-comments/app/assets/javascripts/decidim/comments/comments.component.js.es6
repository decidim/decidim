/**
 * A plain Javascript component that handles the comments.
 *
 * @class
 * @augments Component
 */
((exports) => {
  class CommentsComponent {
    constructor($element) {
      this.$element = $element;
      this.id = this.$form.attr("id") || this._getUID();
      this.mounted = false;
    }

    /**
     * Handles the logic for mounting the component
     * @public
     * @returns {Void} - Returns nothing
     */
    mountComponent() {
      if (this.$form.length > 0 && !this.mounted) {
        this.mounted = true;
      }
    }

    /**
     * Handles the logic for unmounting the component
     * @public
     * @returns {Void} - Returns nothing
     */
    unmountComponent() {
      if (this.mounted) {
        this.mounted = false;
      }
    }

    /**
     * Generates a unique identifier for the form.
     * @private
     * @returns {String} - Returns a unique identifier
     */
    _getUID() {
      return `comments-${new Date().setUTCMilliseconds()}-${Math.floor(Math.random() * 10000000)}`;
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.CommentsComponent = CommentsComponent;

  $(() => {
    $("[data-decidim-comments]").each((_i, el) => {
      const comments = new CommentsComponent($(el));
      comments.mountComponent();
    })
  });
})(window);
