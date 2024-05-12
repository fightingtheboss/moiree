import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";
import { patch, post, destroy } from "@rails/request.js";

// Connects to data-controller="sortable"
export default class extends Controller {
  static values = {
    sort: { type: Boolean, default: true },
    group: String,
    url: String,
    handle: String,
    sourceList: { type: Boolean, default: false },
  };

  connect() {
    const options = {
      onAdd: this.onAdd.bind(this),
      onEnd: this.onEnd.bind(this),
      onRemove: this.onRemove.bind(this),
      ghostClass: "bg-indigo-100",
      animation: 150,
      handle: this.handleValue,
      sort: this.sortValue,
      group: this.groupValue,
    };

    Sortable.create(this.element, options);
  }

  onEnd(event) {
    if (event.from === event.to && event.oldIndex !== event.newIndex) {
      const body = { position: event.newIndex + 1 };

      patch(event.item.dataset.sortableUrl, {
        body: JSON.stringify(body),
        responseKind: "turbo-stream",
      });
    }
  }

  onAdd(event) {
    if (this.sourceListValue) {
      const body = {
        critic_id: event.item.dataset.criticId,
      };

      post(this.urlValue, {
        body: JSON.stringify(body),
        responseKind: "turbo-stream",
      });
    }
  }

  onRemove(event) {
    if (this.sourceListValue) {
      const attendanceId = event.item.dataset.attendanceId;

      const body = {
        attendance_id: attendanceId,
      };

      destroy(this.urlValue + `/${attendanceId}`, {
        body: JSON.stringify(body),
        responseKind: "turbo-stream",
      });
    }
  }
}
