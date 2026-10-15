import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["extra", "button"]

  show() {
    this.extraTargets.forEach((row) => row.classList.remove("hidden"))
    this.buttonTarget.remove()
  }
}
