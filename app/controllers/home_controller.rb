# frozen_string_literal: true

class HomeController < ApplicationController
  # skip_before_action :authenticate

  def index
    @current = Edition.current
    @upcoming = Edition.upcoming
    @past = Edition.past
  end
end
