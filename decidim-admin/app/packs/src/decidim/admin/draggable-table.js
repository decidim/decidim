/* eslint-disable require-jsdoc */
import createSortList from "src/decidim/admin/sort_list.component"

$(() => {
  createSortList(".draggable-table", {
    onSortUpdate: ($children) => {
      const children = $children.toArray();

      if (children.length === 0) return;

      const parent = children[0].parentNode;
      const sortUrl = parent.dataset.sortUrl;
      const order = children.map((child) => child.dataset.componentId);

      $.ajax({
        method: "PUT",
        url: sortUrl,
        contentType: "application/json",
        data: JSON.stringify({ order_ids: order }) // eslint-disable-line camelcase
      });
    }
  });
})
