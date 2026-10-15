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
    const visibleRows = this.rowTargets.filter((row) => !row.classList.contains("hidden"))
    if (visibleRows.length <= 1) return

    const row = event.target.closest("[data-issues-form-target='row']")
    const idField = row.querySelector("input[type=hidden][name$='[id]']")

    if (idField) {
      // persisted issue: keep it in the form, marked for destruction, instead of
      // removing it outright -- an absent nested attribute is left unchanged, not destroyed
      row.querySelector("[data-issue-destroy-field]").value = "1"
      row.classList.add("hidden")
    } else {
      row.remove()
    }
  }
}
