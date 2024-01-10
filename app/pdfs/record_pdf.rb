# frozen_string_literal: true

class RecordPdf < Prawn::Document
  # 受け取ったものがrecordに入っている
  def initialize(daily_logs, user)
    super(
      page_size: 'A4',
      top_margin: 40,
      bottom_margin: 30,
      left_margin: 20,
      right_margin: 20
    )

    @daily_logs = daily_logs # メソッドで利用できるようにインスタンス化
    @user = user
    @first_day = Date.today.beginning_of_month - 1.month
    @last_day = @first_day.end_of_month
    font 'app/assets/fonts/ipaexg.ttf'

    # stroke_axis

    # 下記で作成したコンポーネントを表示順に
    header
    move_down 40
    contents
  end

  # コンポーネント作成
  def header
    text '運転日報', size: 16, align: :center
    move_down 10
    draw_text '作成日：',
              at: [430, 736]
    text Time.zone.today.to_s, size: 11, align: :right
    move_down 5
    draw_text '氏名　：',
              at: [430, 721]
    text @user.user_name.to_s, size: 11, align: :right
    move_down 20
    text "期間:#{@first_day}〜#{@last_day}", size: 11, align: :center
  end

  def contents
    header = %w[登録日 車両名 出発時間 到着時間 距離(出) 距離(着) 出発場所 目的地 酒気検査]
    all_data_rows = []

    @daily_logs.each do |log|
      # 余分な角括弧を取り除き、配列に直接要素を追加
      data = [
        log.created_at.strftime('%Y-%m-%d'),
        "#{log.vehicle.vehicle_name} - #{log.vehicle.number}",
        log.departure_datetime.strftime('%Y-%m-%d %H:%M'),
        log.arrival_datetime.strftime('%Y-%m-%d %H:%M'),
        log.departure_distance.to_s,
        log.arrival_distance.to_s,
        log.departure_location.to_s,
        log.arrival_location.to_s,
        log.is_alcohol_check ? '実施' : '未実施'
      ]
      all_data_rows << data
    end

    # ヘッダーと全てのデータ行を含む表を描画
    table [header] + all_data_rows,
          header: true,
          cell_style: { size: 9 }
  end
end
