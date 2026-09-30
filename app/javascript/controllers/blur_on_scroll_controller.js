import { Controller } from "@hotwired/stimulus";

// Tapping a tooltip trigger focuses it to show the tooltip, which then stays
// pinned in place while the grid scrolls. Blurring on scroll hides it.
export default class extends Controller {
  blur() {
    if (this.element.contains(document.activeElement)) {
      document.activeElement.blur();
    }
  }
}
