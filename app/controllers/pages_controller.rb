class PagesController < ApplicationController
  def home
    @visible_pings = Ping.visible.includes(:user)
    @visible_pings_all = Ping.visible
  end

  def profile
    @user = current_user
  end

  def new
    @Ping = Ping.new
  end
end
