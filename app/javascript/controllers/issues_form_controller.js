import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "row"]
  static values = { index: Number }

  add() {
    const tpl = document.getElementById("issue-row-template")
    const html = tpl.innerHTML.replaceAll("NEW_INDEX", this.indexValue++)
    const wrapper = document.createElement("div")
    wrapper.innerHTML = html
    this.listTarget.appendChild(wrapper.firstElementChild)
  }

  remove(event) {
    if (this.rowTargets.length <= 1) return
    event.target.closest("[data-issues-form-target='row']").remove()
  }
}
