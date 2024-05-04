import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";
import { patch } from "@rails/request.js";

// Connects to data-controller="sortable"
export default class extends Controller {
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
    const body = { position: event.newIndex };

    patch(event.item.dataset.sortableUrl, {
      body: JSON.stringify(body),
      responseType: "turbo-stream",
    });
  }
}
