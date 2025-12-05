import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // static targets = ["map", "footer"]

  // connect() {
  //   const map = this.mapTarget
  //   const footer = this.footerTarget

  //   map.addEventListener("click", () => {
  //     footer.style.display = "none"
  //   })

  //   document.addEventListener("click", (e) => {
  //     if (!e.target.closest("[data-map-footer-target='map']")) {
  //       footer.style.display = "flex"
  //     }
  //   })
  // }
}
