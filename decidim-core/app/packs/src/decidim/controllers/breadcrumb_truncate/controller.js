import { Controller } from "@hotwired/stimulus"

const ELLIPSIS = "..."

export default class extends Controller {
  static get targets() {
    return ["item", "text"]
  }

  connect() {
    this.originalTexts = this.textTargets.map((target) => target.textContent.trim())
    this.refresh = this.refresh.bind(this)

    this.resizeObserver = new ResizeObserver(() => this.refresh())
    this.resizeObserver.observe(this.element)
    window.addEventListener("resize", this.refresh)

    this.refresh()
  }

  disconnect() {
    this.resizeObserver?.disconnect()
    window.removeEventListener("resize", this.refresh)
  }

  refresh() {
    if (this.hasItemTarget) {
      this.refreshGroup()
      return
    }

    this.truncateItem(this.element, this.textTarget, this.originalTexts[0])
  }

  refreshGroup() {
    this.itemTargets.forEach((item, index) => this.resetItem(item, this.textTargets[index], this.originalTexts[index]))

    if (this.element.clientWidth <= 0) {
      return
    }

    if (!this.isOverflowing(this.element)) {
      return
    }

    let overflow = this.element.scrollWidth - this.element.clientWidth

    const candidates = this.itemTargets.map((item, index) => ({
      item,
      text: this.textTargets[index],
      originalText: this.originalTexts[index],
      width: item.scrollWidth
    })).sort((left, right) => right.width - left.width)

    candidates.forEach((candidate) => {
      if (overflow <= 0) {
        return
      }

      const nextWidth = Math.max(1, candidate.width - overflow)

      candidate.item.style.flex = `0 1 ${nextWidth}px`
      candidate.item.style.maxWidth = `${nextWidth}px`
      candidate.item.style.minWidth = "0"

      this.truncateItem(candidate.item, candidate.text, candidate.originalText)
      overflow -= candidate.width - nextWidth
    })
  }

  resetItem(item, text, originalText) {
    item.style.removeProperty("flex")
    item.style.removeProperty("max-width")
    item.style.removeProperty("min-width")
    item.removeAttribute("title")
    text.textContent = originalText
  }

  truncateItem(item, text, originalText) {
    if (item.clientWidth <= 0) {
      return
    }

    text.textContent = originalText

    if (!this.isOverflowing(item)) {
      item.removeAttribute("title")
      return
    }

    const words = originalText.split(/\s+/).filter(Boolean)
    let visibleText = ""

    for (let index = 0; index < words.length; index += 1) {
      let nextText = words[index]

      if (visibleText) {
        nextText = `${visibleText} ${words[index]}`
      }

      text.textContent = `${nextText}${ELLIPSIS}`

      if (this.isOverflowing(item)) {
        break
      }

      visibleText = nextText
    }

    if (!visibleText) {
      visibleText = this.truncateSingleWord(item, text, words[0] || "")
    }

    if (visibleText === originalText) {
      text.textContent = visibleText
    } else {
      text.textContent = `${visibleText}${ELLIPSIS}`
    }

    item.setAttribute("title", originalText)
  }

  truncateSingleWord(item, text, word) {
    let visibleText = ""

    for (let index = 0; index < word.length; index += 1) {
      text.textContent = `${visibleText}${word[index]}${ELLIPSIS}`

      if (this.isOverflowing(item)) {
        break
      }

      visibleText += word[index]
    }

    if (!visibleText && word) {
      return word[0]
    }

    return visibleText
  }

  isOverflowing(element) {
    return element.scrollWidth > element.clientWidth
  }
}
