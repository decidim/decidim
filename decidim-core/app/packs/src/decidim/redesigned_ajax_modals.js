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
    document.getElementById(`${this.modalTarget}-content`).innerHTML = response
  }

  handleError(err) {
    document.getElementById(`${this.modalTarget}-content`).innerHTML = `<h3>${err.status}</h3><p>${err.statusText}</p>`
  }
}
