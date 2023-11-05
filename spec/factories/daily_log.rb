FactoryBot.define do
  factory :daily_log do
    user_id { 1 }
    departure_datetime { Time.zone.today } # 出発日時
    arrival_datetime { Time.now } # 到着日時
    departure_distance { 123 } # 出発時の距離
    arrival_distance { 456 } # 到着時の距離
    departure_location { '本社' } # 出発場所
    arrival_location { '名古屋ドーム' } # 到着場所
    note { '得意先名：ドラゴン商事 件名：照明の交換' } # 備考欄
    is_studless_tire { false } # スタッドレスタイヤの装着
    is_alcohol_check { true } # アルコール検査の実施
  end
end
