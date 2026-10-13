import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "otherDetail"]

  connect() {
    this.toggle()
  }

  toggle() {
    this.otherDetailTarget.classList.toggle("hidden", this.selectTarget.value !== "other")
  }
}
