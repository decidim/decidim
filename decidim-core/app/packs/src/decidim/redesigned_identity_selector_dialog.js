/**
 * Send a request to select which identity want to use
 * NOTE: this shouldn't be done using javascript
 *
 * @param {DOMNode} element node to select
 * @returns {void}
 */
export default function(element) {
  element.addEventListener("click", ({ target: node }) => {
    const { method } = node.dataset

    let attr = "destroy_url";

    if (method === "POST") {
      attr = "create_url";
    }

    const { [attr]: url } = node.dataset
    fetch(url, { method }).then((response) => {
      if (response.ok) {
        if (method === "POST") {
          node.classList.add("is-selected")
          node.dataset.method = "DELETE"
        } else {
          node.classList.remove("is-selected")
          node.dataset.method = "POST"
        }
      }
    })
  })
}
