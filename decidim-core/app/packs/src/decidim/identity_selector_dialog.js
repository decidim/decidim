/**
 * Send a request to select which identity want to use
 * NOTE: this should not be done using javascript
 *
 * @param {HTMLElement} node target node
 * @returns {void}
 */
export default function(node = document) {
  node.addEventListener("click", ({ target: element }) => {
    const { method } = element.dataset

    let attr = "destroy_url";

    if (method === "POST") {
      attr = "create_url";
    }

    const { [attr]: url } = element.dataset
    Rails.ajax({
      url: url,
      type: method,
      success: function() {
        if (method === "POST") {
          element.classList.add("is-selected")
          element.dataset.method = "DELETE"
        } else {
          element.classList.remove("is-selected")
          element.dataset.method = "POST"
        }
      }
    })
  })
}
