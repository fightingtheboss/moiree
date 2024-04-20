# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate

  def index
    @current = Edition.upcoming
    @past = Edition.past
  end
end
