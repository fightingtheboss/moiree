# frozen_string_literal: true

class Admin
  class AdminController < ApplicationController
    include Authentication

    require_authentication

    layout "admin"
  end
end
