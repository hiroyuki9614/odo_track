## アプリ名
ODO TRACK

## Live Demo

The current live URL is maintained separately from this repository while the VPS
deployment is being finalized. See the deployment notes supplied with the
portfolio for the active address and demo credentials.

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
 - rails 7.1.3
 - vue.js vuetify
 - git(github actionによりテストの自動実行)
 - docker
 - rspec(テスト)

## Deployment architecture

Production runs as a rootless Docker Compose stack on the VPS:

```text
Nginx (host, HTTPS) -> 127.0.0.1:3100 -> Rails/Puma container
                                  -> PostgreSQL and Redis containers
```

Secrets are supplied through the VPS-only `.env.production` file and are not
committed to Git.

## Demo account usage

Demo accounts are provisioned with deployment-local credentials. Do not reuse
them outside the portfolio environment or use the demo admin account for real
data.

 ## 改良予定
 - PDFの出力機能の強化（フォルダの作成・指定のgoogle driveアップロードなど)
 - モバイル表示の強化

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
