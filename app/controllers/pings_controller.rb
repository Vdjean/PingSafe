class PingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @pings = current_user.pings
  end

  def show
    @ping = Ping.find(params[:id])
    @chat = @ping.chat
  end

  def new
    @ping = Ping.new
  end

  def create
    @ping = Ping.new(ping_params)
    @ping.user = current_user

    if @ping.save
      # Create chat immediately
      Chat.create(ping: @ping)

      # Process in background job (replaces Thread.new)
      ProcessPingJob.perform_later(@ping.id)

      redirect_to ping_path(@ping), notice: "Ping created successfully! Analysis in progress..."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @ping = Ping.find(params[:id])

    if @ping.update(ping_params)
      if params[:ping][:photo].present? && @ping.chat.nil?
        ProcessPingJob.perform_later(@ping.id)
      end

      redirect_to ping_path(@ping), notice: "Photo uploaded and analysis started!"
    else
      render :show
    end
  end

  def share
    @ping = Ping.find(params[:id])

    @ping.update(shared_at: Time.current)

    redirect_to ping_path(@ping), notice: "Ping shared with the Pinger community within 300 meters!"
  end

  private

  def ping_params
    params.require(:ping).permit(:date, :heure, :comment, :photo, :latitude, :longitude, :nombre_personnes, :signe_distinctif)
  end
end
