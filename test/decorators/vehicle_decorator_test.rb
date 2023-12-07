# frozen_string_literal: true

require 'test_helper'

class VehicleDecoratorTest < ActiveSupport::TestCase
  def setup
    @vehicle = Vehicle.new.extend VehicleDecorator
  end

  # test "the truth" do
  #   assert true
  # end
end
