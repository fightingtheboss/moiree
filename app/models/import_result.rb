# frozen_string_literal: true

class ImportResult
  attr_accessor :imported, :skipped, :errors

  def initialize
    @imported = []
    @skipped = []
    @errors = []
  end

  def count
    @imported.size
  end

  def full_error_messages
    @errors.join("\n")
  end
end
