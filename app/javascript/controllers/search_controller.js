import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["query", "year"];

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
    const year = this.yearTarget.value.trim();

    if (query.length < 2) {
      // Optionally clear previous results here
      return;
    }

    if (query === this.previousQuery && year === this.previousYear) {
      return;
    }

    this.previousQuery = query;
    this.previousYear = year;

    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      get(this.urlValue, {
        query: { query: query, year: year },
        responseKind: "turbo-stream"
      });
    }, 500);
  }
}
