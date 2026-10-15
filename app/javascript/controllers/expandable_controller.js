import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["extra", "button"]
  static values = { count: Number }

  toggle() {
    const collapsed = this.buttonTarget.textContent.trim().startsWith("Show all")
    this.extraTargets.forEach((row) => row.classList.toggle("hidden", !collapsed))
    this.buttonTarget.textContent = collapsed ? "Collapse" : `Show all (${this.countValue})`
  }
}
