import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["query"];

  static values = {
    url: String,
  };

  search() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, 200);
  }

  // Local search for film
  existing() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      get(this.urlValue, {
        query: { query: this.queryTarget.value },
        responseKind: "turbo-stream"
      });
    }, 200);
  }
}
