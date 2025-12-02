class PingsController < ApplicationController


  def index
    @Pings = Ping.all
  end

  def show
    @Ping = Ping.find(params[:id])
  end

  def new # homepage
    @Ping = Ping.new
  end

  def create
    @Ping = Ping.new(ping_params)
    if @Ping.save
      redirect_to new_ping_path, notice: "Ping created."
    else
      render :show
    end
  end

  private

  def ping_params
    params.require(:ping).permit(:date, :time, :comment, :photo, :latitude, :longitude, :users_id)
  end
end
