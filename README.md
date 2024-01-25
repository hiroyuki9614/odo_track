## アプリ名
ODO TRACK

## 概要
　githubページをご覧頂き、誠にありがとうございます。 このアプリは運転日報を簡単にミスを少なく作成するためのWeb技術により作成したアプリです。　Web技術の魅力は日常のあらゆることの非効率を少しでもなくせるという事だと私は考えております。
　このアプリはその中の一つである、手書きの運転日報を自分が効率化するとどうなるか。という考えから作成を初めました。　そのため、書類が苦手な自分でも可能な限り楽に、かつミスを減らして日報を作成する方法を考えながら作成しました。
　至らぬ点の多々あるかと存じますが、ご査収のほど、よろしくお願い致します。　恐れ入りますが以降、詳細はアプリのトップページに記載のため、トップページの補足を中心とさせて頂きます。

## URL
　Heroku
  https://lit-tor-41640-5f66b309ac09.herokuapp.com/

## 基本技術
 - 一般ユーザー&管理ユーザー
 	- アカウント登録/編集/削除(devise)
  	- 日報の作成/編集/削除(論理削除)
	- よく乗る車両の登録
 - 管理ユーザー
 	- 車両の登録/編集/削除
 	- 社員の編集/削除
	- 日報のPDF出力

## 管理者機能についての補足
下記は管理者のみが実行可能としております。
- ユーザーの編集
- 車両の登録・編集
- PDFの出力<br><br>
また、データ保持の観点から、<br>
- ユーザーの削除は原則不可(未認証ユーザーのみ可)
- 運転日報はユーザーは論理削除のみ可能。(ユーザーが論理削除した運転日報を管理者が物理削除可能)
- 車両に関しては論理削除と物理削除を管理者が両方可能。
 としております。<br>
- PDFの出力について、月に一回、gem whenneverによりPDFが自動に出力されます。<br>※現在はポートフォリオによる閲覧用に一時的に今月の運転日報が作成されるように設定しております。


 ## 使用技術
 - rails 7.1.2
 - vue.js vuetify
 - git(github actionによりテストの自動実行)
 - docker
 - rspec(テスト)

 ## 改良予定
 - PDFの出力機能の強化（フォルダの作成・指定のgoogle driveアップロードなど)
 - モバイル表示の強化
 - AWSへの移行(進行中)

## DB
運転日報テーブル (daily_logs)
| カラム名             | 説明                 | データ型   |
|----------------------|----------------------|------------|
| user_id              | ユーザー名           | integer    |
| vehicle_id           | 車両名称             | integer    |
| departure_datetime   | 出発時間             | datetime   |
| arrival_datetime     | 到着時間             | datetime   |
| departure_distance   | 出発時の距離         | integer    |
| arrival_distance     | 到着時の距離         | integer    |
| departure_location   | 出発場所             | string     |
| arrival_location     | 目的地               | string     |
| note                 | 備考                 | text       |
| is_alcohol_check     | アルコールチェック   | boolean    |
| discarded_at         | 論理削除             | datetime   |

ユーザーテーブル (users)
| カラム名                 | 説明                       | データ型   |
|--------------------------|----------------------------|------------|
| user_name                | 氏名                       | string     |
| email                    | メールアドレス             | string     |
| telephone                | 電話番号                   | string     |
| admin                    | 管理者権限                 | boolean    |
| encrypted_password       | パスワード                 | string     |
| reset_password_token     | パスワード再設定用トークン | string     |
| reset_password_sent_at   | パスワード再設定要求時間   | datetime   |
| remember_created_at      | remember_me                | datetime   |
| confirmation_token       | ユーザー認証トークン       | string     |
| confirmed_at             | ユーザー認証時間           | datetime   |
| confirmation_sent_at     | ユーザー認証要求時間       | datetime   |
| unconfirmation_email     | email未認証                | string     |
| discarded_at             | 論理削除                   | datetime   |

車両テーブル (vehicles)
| カラム名                 | 説明                 | データ型   |
|--------------------------|----------------------|------------|
| vehicle_name             | 車両名称             | string     |
| number                   | ナンバー             | string     |
| manufacture              | メーカー             | string     |
| current_drive_distance   | 現在の走行距離       | integer    |
| discarded_at             | 論理削除             | datetime   |

よく乗る車両テーブル (favorite_vehicles)
| カラム名                 | 説明                 | データ型   |
|--------------------------|----------------------|------------|
| user_id                  | ユーザーID           | integer    |
| vehicle_id               | 車両ID               | integer    |
| favorite_vehicle_note    | 備考                 | string     |
