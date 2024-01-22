# frozen_string_literal: true

# 運転日報（Daily Logs）に関する操作（CRUDなど）を管理するコントローラーです。
# このコントローラーでは、運転日報の作成、編集、表示、削除等のアクションを定義しています。
class DailyLogsController < ApplicationController
  before_action :authenticate_user!
  # before_action :correct_user, only: %i[index]

  def index
    # redirect_to('/daily_logs#/daily_logs', allow_other_host: true)
    # redirect_to daily_logs_path
    # @user = User.find(current_user.id)
    # @q = @user.daily_logs.all.where(discarded_at: nil).ransack(params[:q])
    # @q.sorts = 'created_at desc' if @q.sorts.empty?
    # @daily_logs = @q.result(distinct: true).page params[:page]
    # .order(created_at: :desc)
  end

  def show
    @user = User.find(current_user.id)
    @daily_log = @user.daily_logs.find(params[:id])
  end

  def new
    @daily_log = current_user.daily_logs.build(
      departure_datetime: Time.zone.today,
      arrival_datetime: Time.now.strftime('%Y-%m-%d %H:%M'),
      departure_distance: current_user.daily_logs.last_arrival_distance
    )
    # お気に入りの目的地をセレクトボックスで選べるようにする。 datalist要素
    # @frequent_destinations = current_user.frequent_destination
  end

  def confirm
    if request.post?
      @daily_log = DailyLog.new(daily_log_params)
      session[:daily_log_data] = daily_log_params
    else
      @daily_log = DailyLog.new(session[:daily_log_data])
    end
    if @daily_log.user_id != current_user.id
      flash.now[:alert] = '不正な操作が行われました。'
      render :new and return
    end
    return unless @daily_log.invalid?

    render :new
  end

  def create
    @daily_log = DailyLog.new(daily_log_params)
    if @daily_log.user_id != current_user.id
      flash[:alert] = '不正な操作が行われました。'
      render :new and return
    end
    return render :new if params[:button] == 'back'

    if @daily_log.save
      redirect_to daily_logs_path
    else
      # 失敗時にお気に入りを復旧。　恐らく不要。
      # @feed_items = current_user.feed
      render :confirm
    end
  end

  def edit
    @daily_log = DailyLog.find(params[:id])

    return unless @daily_log.user_id != current_user.id

    flash[:alert] = '不正な操作が行われました。'
    render :index and return
  end

  def update
    @daily_log = DailyLog.find(params[:id])
    if @daily_log.update(daily_log_params)
      redirect_to daily_logs_path, notice: '運転日報を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @daily_log = DailyLog.find(params[:id])
    @daily_log.discard
    flash[:success] = '運転日報を削除しました。'
    redirect_to daily_logs_path, status: :see_other
  end

  private

  def daily_log_params
    params.require(:daily_log).permit(:id,
                                      :departure_datetime,
                                      :arrival_datetime,
                                      :departure_distance,
                                      :arrival_distance,
                                      :departure_location,
                                      :arrival_location,
                                      :note,
                                      :is_alcohol_check,
                                      :is_studless_tire,
                                      :approval_status,
                                      :user_id,
                                      :vehicle_id)
  end

  def correct_user
    @daily_log = current_user.daily_logs.find_by(id: params[:id])
    return unless @daily_log.nil?

    flash[:alert] = '不正な操作が行われました。'

    redirect_to daily_logs_path, status: :see_other
  end

  def last_arrival_distance
    last_log = current_user.daily_logs.last
    last_log&.arrival_distance.present? ? last_log.arrival_distance : ''
  end
end
