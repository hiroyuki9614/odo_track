# frozen_string_literal: true

# Documentation for DailyLogDecorator
module UserDecorator
  def active_text?
    is_active ? '在籍' : '退職'
  end

  def admin_text?
    is_admin ? true : false
  end
end
