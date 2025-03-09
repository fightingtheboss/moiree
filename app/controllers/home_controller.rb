# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @current = Edition.current
    @upcoming = Edition.upcoming
    @past = Edition.past
  end
end
