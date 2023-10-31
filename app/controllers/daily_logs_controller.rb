# frozen_string_literal: true

# 運転日報（Daily Logs）に関する操作（CRUDなど）を管理するコントローラーです。
# このコントローラーでは、運転日報の作成、編集、表示、削除等のアクションを定義しています。
class DailyLogsController < ApplicationController
  def index
    @daily_logs = DailyLog.all.order(created_at: :desc).page params[:page]
    # @search = SearchKeyword.new
  end

  def show
    @daily_log = DailyLog.find(params[:id])
  end

  def new
    @daily_log = DailyLog.new(departure_datetime: Time.zone.today,
                              arrival_datetime: Time.now.strftime('%Y-%m-%d %H:%M'))
  end

  def confirm
    if request.post?
      @daily_log = DailyLog.new(daily_log_params)
      session[:daily_log_data] = daily_log_params
    else
      @daily_log = DailyLog.new(session[:daily_log_data])
    end
    return unless @daily_log.invalid?

    render :new
  end

  def create
    @daily_log = DailyLog.new(daily_log_params)
    return render :new if params[:button] == 'back'

    if @daily_log.save
      redirect_to daily_logs_path
    else
      render :confirm
    end
  end

  def edit
    @daily_log = DailyLog.find(params[:id])
  end

  def edit_confirm
    if request.patch?
      @daily_log = DailyLog.find(params[:id])
      session[:daily_log_data] = daily_log_params
      @daily_log.attributes = daily_log_params
    else
      # ここでセッションから取得したデータを属性にセット
      @daily_log = DailyLog.new(session[:daily_log_data])
    end
    return unless @daily_log.invalid?

    render :edit
  end

  def update
    @daily_log = DailyLog.find(params[:id])
    if params[:button] == 'back'
      @daily_log.attributes = session[:daily_log_data]
      render :edit and return
    end
    if @daily_log.update(daily_log_params)
      redirect_to daily_logs_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @daily_log = DailyLog.find(params[:id])
    @daily_log.destroy
    redirect_to daily_logs_path, status: :see_other
  end

  # def keywd
  #   @search = SearchKeyword.new
  # end

  # def keywd_process
  #   @search = SearchKeyword.new(params.require(:search_keyword).permit(:keyword))
  #   if @search.valid?
  #     # 検索ロジックを実行し、結果を表示するページへリダイレクトする
  #     # 例えば、検索結果を表示するindexアクションへリダイレクトする場合：
  #     redirect_to daily_logs_path(keyword: @search.keyword)
  #   else
  #     flash[:error] = @search.errors.full_messages[0]
  #     redirect_to keywd_daily_logs_path
  #   end
  # end

  private

  def daily_log_params
    params.require(:daily_log).permit(:departure_datetime,
                                      :arrival_datetime,
                                      :departure_distance,
                                      :arrival_distance,
                                      :departure_location,
                                      :arrival_location,
                                      :note,
                                      :is_alcohol_check,
                                      :is_studless_tire,
                                      :approval_status,
                                      :user_id)
  end
end
