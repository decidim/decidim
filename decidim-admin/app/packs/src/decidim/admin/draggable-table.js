import createSortList from "src/decidim/admin/sort_list.component"

/**
 * Draggable table
 *
 * This script is used to make a table draggable.
 * It works with two data attributes:
 *
 * - data-draggable-table: The table that will be draggable.
 * - data-sort-url: The URL where the order will be sent.
 */
$(() => {
  createSortList("[data-draggable-table]", {
    onSortUpdate: ($children) => {
      const children = $children.toArray();

      if (children.length === 0) {
        return;
      }

      const parent = children[0].parentNode;
      const sortUrl = parent.dataset.sortUrl;
      const order = children.map((child) => child.dataset.recordId);

      $.ajax({
        method: "PUT",
        url: sortUrl,
        contentType: "application/json",
        data: JSON.stringify({ order_ids: order }) // eslint-disable-line camelcase
      });
    }
  });
})
