# frozen_string_literal: true

class FrequentDestinationsController < ApplicationController
  def new
    @frequent_destination = current_user.frequent_destinations.new
  end

  def create
    @frequent_destination = FrequentDestination.new(frequent_destination_params)
    if @frequent_destination.save
      flash notice: '目的地がブックマークに追加されました'
      redirect_to user_path
    else
      # 失敗時にお気に入りを復旧。　恐らく不要。
      # @feed_items = current_user.feed
      flash notice: 'ブックマークの追加に失敗しました。'
      render :new
    end
  end

  def click_on_create
    @daily_log = DailyLog.find(params[:id])
    @frequent_destination.create(destination_name: @daily_log.arrival_location)
    if @frequent_destination.save
      flash notice: '目的地がブックマークに追加されました'
    else
      flash notice: 'ブックマークの追加に失敗しました。'
    end
  end

  def edit
    @frequent_destination = FrequentDestination.find(params[:id])
  end

  def update
    @frequent_destination = FrequentDestination.find(params[:id])
    if params[:button] == 'back'
      @frequent_destination.attributes = session[:frequent_destination_data]
      render :edit and return
    end
    if @frequent_destination.update(frequent_destination_params)
      redirect_to frequent_destinations_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @frequent_destination = FrequentDestination.find(params[:id])
    @frequent_destination.destroy
    flash[:success] = '運転日報を削除しました。'
    redirect_to daily_logs_path, status: :see_other
  end
end
