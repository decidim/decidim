import createSortList from "src/decidim/admin/sort_list.component"

/**
 * Draggable table
 *
 * This script is used to make a table draggable.
 * It works with the following data attributes:
 *
 * - data-draggable-table: The table that will be draggable.
 * - data-sort-url: The URL where the order will be sent.
 * - data-draggable-handle: (optional) CSS selector for the drag handle element.
 *   When specified, dragging can only be initiated from this element.
 * - data-draggable-placeholder: (optional) HTML for the placeholder element.
 */
document.addEventListener("turbo:load", () => {
  document.querySelectorAll("[data-draggable-table]").forEach((container) => {
    const options = {
      forcePlaceholderSize: true,
      onSortUpdate: ($children) => {
        const children = $children.toArray();

        if (children.length === 0) {
          return;
        }

        const parent = children[0].parentNode;
        const sortUrl = parent.dataset.sortUrl;
        const order = children.map((child) => child.dataset.recordId);

        if (sortUrl && sortUrl !== "#") {
          $.ajax({
            method: "PUT",
            url: sortUrl,
            contentType: "application/json",
            data: JSON.stringify({ order_ids: order }) // eslint-disable-line camelcase
          });
        }
      }
    };

    // Read optional configuration from data attributes
    if (container.dataset.draggableHandle) {
      options.handle = container.dataset.draggableHandle;
    }
    if (container.dataset.draggablePlaceholder) {
      options.placeholder = container.dataset.draggablePlaceholder;
    }

    createSortList(container, options);
  });
})
