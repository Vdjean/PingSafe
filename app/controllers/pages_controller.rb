class PagesController < ApplicationController
  def home
    @visible_pings = Ping.visible.includes(:user)
  end

  def profile
    @user = current_user
  end

  def new
    @Ping = Ping.new
  end
end
