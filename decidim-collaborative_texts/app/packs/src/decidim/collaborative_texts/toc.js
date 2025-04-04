export default class Toc {
  constructor(toc, document) {
    this.toc = toc;
    this.document = document;
    this.ul = toc.getElementsByTagName("ul")[0];
    this._bindEvents();
  }
  
  headings() {
    this.nodes = [];
    this.document.doc.querySelectorAll("*> h2, *> div.collaborative-texts-changes").forEach((node) => {
      if (node.nodeName === "H2") {
        this.nodes.push(node);
      }
      if (node.classList.contains("collaborative-texts-changes")) {
        // add h2 nodes inside changes
        let h2s = node.querySelectorAll("*>h2");
        h2s.forEach((h2) => {
          this.nodes.push(h2);
        });
      }
    });
    return this.nodes;
  }

  render() {
    this.ul.innerHTML = "";
    this.ul.classList.remove("spinner-container");
    console.log("Rendering table of contents", this.headings());
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
    this.document.doc.addEventListener("collaborative-texts:applied", this.render.bind(this));
    this.document.doc.addEventListener("collaborative-texts:restored", this.render.bind(this));
  }
}
