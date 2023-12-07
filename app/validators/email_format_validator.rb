# frozen_string_literal: true

# # メールに関するバリデーション
# class EmailFormatValidator < ActiveModel::EachValidator
#   def validate_each(record, attribute, value)
#     return if /^[a-zA-Z0-9_.+-]+@([a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.)+[a-zA-Z]{2,}$/.match?(value)

#     record.errors.add(attribute, 'の形式が正しくありません')
#   end
# end
