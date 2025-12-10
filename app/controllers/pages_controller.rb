class PagesController < ApplicationController
  def home
    # If not authenticated and hasn't seen tutorial, show it
    unless user_signed_in? || cookies[:skip_tutorial] == 'true' || cookies[:is_pwa] == 'true'
      redirect_to tutorials_install_path and return
    end

    @visible_pings = Ping.visible.includes(:user)
    @visible_pings_all = Ping.visible
  end

  def profile
    @user = current_user
  end

  def new
    @Ping = Ping.new
  end

  def this_ping
   @ping = Ping.find(params[:id])
  end
end
