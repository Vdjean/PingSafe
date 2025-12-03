class PagesController < ApplicationController
  def home
  end

  def profile
    @user = current_user
  end

  def new
    @Ping = Ping.new
  end
end
