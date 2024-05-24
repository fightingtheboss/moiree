import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="refresh"
export default class extends Controller {
  connect() {
    this.interval = setInterval(() => {
      const turboStreamElement = document.createElement("turbo-stream");
      turboStreamElement.setAttribute("action", "refresh");

      this.element.appendChild(turboStreamElement);
    }, 7.5 * 60 * 1000);
  }

  disconnect() {
    clearInterval(this.interval);
  }
}
