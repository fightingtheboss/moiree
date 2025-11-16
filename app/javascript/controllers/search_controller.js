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
    const query = this.queryTarget.value.trim();

    if (query.length < 2) {
      // Optionally clear previous results here
      return;
    }

    if (query === this.previousQuery) {
      return;
    }

    this.previousQuery = query;

    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      get(this.urlValue, {
        query: { query: query },
        responseKind: "turbo-stream"
      });
    }, 500);
  }
}
