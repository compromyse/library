import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    const row = event.currentTarget
    const detailRow = row.nextElementSibling
    detailRow.classList.toggle("hidden")

    const frame = detailRow.querySelector("turbo-frame")
    if (!frame.getAttribute("src")) frame.src = frame.dataset.src

    row.querySelector("[data-row-details-chevron]").classList.toggle("rotate-90")
  }
}
