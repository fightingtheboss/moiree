import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";
import { patch } from "@rails/request.js";

// Connects to data-controller="sortable"
export default class extends Controller {
  static values = {
    sort: { type: Boolean, default: true },
    group: String,
    url: String,
  };

  connect() {
    const options = {
      onEnd: this.onEnd.bind(this),
      ghostClass: "bg-indigo-100",
      animation: 150,
      handle: ".sortable-handle",
    };

    Sortable.create(this.element, options);
  }

  onEnd(event) {
    const body = { position: event.newIndex + 1 };

    patch(event.item.dataset.sortableUrl, {
      body: JSON.stringify(body),
      responseType: "turbo-stream",
    });
  }
}
