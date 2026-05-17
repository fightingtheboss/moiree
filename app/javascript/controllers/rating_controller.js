import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="rating"
export default class extends Controller {
  static targets = ["score", "scoreDisplay", "walkedOut"]

  connect() {
    this.toggleWalkedOut();
    this.updateScoreDisplay(this.scoreTarget.value);
  }

  onChange(event) {
    this.updateScoreDisplay(event.target.value);
  }

  toggleWalkedOut() {
    if (!this.hasWalkedOutTarget) return;

    const walkedOut = this.isWalkedOut();
    this.scoreTarget.disabled = walkedOut;

    if (walkedOut) {
      this.scoreTarget.value = "0.0";
      this.scoreDisplayTarget.textContent = "🚪🚶";
      return;
    }

    this.updateScoreDisplay(this.scoreTarget.value);
  }

  updateScoreDisplay(score) {
    if (this.isWalkedOut()) {
      this.scoreDisplayTarget.textContent = "🚪🚶";
      return;
    }

    const numericScore = Number(score);
    const displayScore = numericScore === 0 ? "💣" : (numericScore === 5 ? "🔥" : score);
    this.scoreDisplayTarget.textContent = displayScore;
  }

  isWalkedOut() {
    return this.hasWalkedOutTarget && this.walkedOutTarget.checked;
  }
}
