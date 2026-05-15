export default class Toc {
  constructor(toc, doc) {
    this.toc = toc;
    this.doc = doc;
    this.ul = toc.getElementsByTagName("ul")[0];
    this._bindEvents();
  }

  headings() {
    this.nodes = [];
    this.doc.querySelectorAll("*> h2:not(.collaborative-texts-hidden), *> div.collaborative-texts-changes> h2").forEach((node) => {
      if (node.nodeName === "H2") {
        this.nodes.push(node);
      }
    });
    return this.nodes;
  }

  render() {
    this.ul.innerHTML = "";
    this.ul.classList.remove("spinner-container");
    this.headings().forEach((heading) => {
      this.ul.appendChild(this.createEntry(heading));
    });
  }

  createEntry(heading) {
    let entry = window.document.createElement("li");
    entry.textContent = heading.textContent;
    entry.addEventListener("click", this._onClick.bind(this));
    return entry;
  }

  _onClick(event) {
    event.preventDefault();
    let entry = event.currentTarget;
    let heading = this.headings().find((el) => el.textContent === entry.textContent);
    if (heading) {
      history.replaceState(null, null, `#${heading.id}`);
      heading.scrollIntoView({ behavior: "smooth" });
    }
  }

  _bindEvents() {
    this.doc.addEventListener("collaborative-texts:applied", this.render.bind(this));
    this.doc.addEventListener("collaborative-texts:restored", this.render.bind(this));
  }
}
