import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {}

  show(event) {
    const dialog = document.getElementById(event.params.dialog);
    const targetCollectionId = event.params.target;

    if (targetCollectionId) {
      dialog.addEventListener(
        "turbo:frame-load",
        (event) => {
          const targetHiddenInput = document.createElement("input");

          targetHiddenInput.setAttribute("type", "hidden");
          targetHiddenInput.setAttribute("name", "target_collection_id");
          targetHiddenInput.setAttribute("value", targetCollectionId);

          dialog
            .querySelector("turbo-frame form")
            .appendChild(targetHiddenInput);

          dialog.showModal();
        },
        { once: true }
      );
    } else {
      dialog.showModal();
    }
  }

  submitEnd(event) {
    const dialog = event.target.closest("dialog");

    if (event.detail.success) {
      dialog.close();
    }
  }
}
