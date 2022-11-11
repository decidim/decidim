export default class RemoteModal {
  constructor(element) {
    if (!element) {
      throw new Error("RemoteModal requires a DOM Element")
    }

    const { dialogRemoteUrl: url, dialogOpen } = element.dataset
    this.url = url
    this.modalTarget = dialogOpen

    element.addEventListener("click", (event) => this.handleClick(event))
  }

  handleClick() {
    fetch(this.url).
      then((res) => {
        if (!res.ok) {
          throw res
        }
        return res.text()
      }).
      then((res) => this.handleSuccess(res)).
      catch((err) => this.handleError(err));
  }

  handleSuccess(response) {
    const node = document.getElementById(`${this.modalTarget}-content`)
    node.innerHTML = response
    document.dispatchEvent(new CustomEvent("remote-modal:loaded", { detail: node }));
  }

  handleError(err) {
    const node = document.getElementById(`${this.modalTarget}-content`)
    node.innerHTML = `<h3>${err.status}</h3><p>${err.statusText}</p>`
    document.dispatchEvent(new CustomEvent("remote-modal:failed", { detail: node }));
  }
}
