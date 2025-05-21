import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="rating"
export default class extends Controller {
  static targets = ["score", "scoreDisplay"]

  connect() {
    this.scoreDisplayTarget.textContent = this.scoreTarget.value;
  }

  onChange(event) {
    const score = event.target.value;
    const displayScore = score === "0" ? "💣" : (score === "5" ? "🔥" : score);
    this.scoreDisplayTarget.textContent = displayScore;
  }
}
