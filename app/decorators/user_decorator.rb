# frozen_string_literal: true

# Documentation for DailyLogDecorator
module UserDecorator
  def active_text?
    discarded_at.nil? ? '在籍' : '退職'
  end

  def admin_text?
    admin ? '管理者' : 'ユーザー'
  end
end
