require 'zeus/rails'

class CustomPlan < Zeus::Rails
  def default_bundle_with_test_env
    ::Rails.env = 'test'
    ENV['RAILS_ENV'] = 'test'
    default_bundle
  end

  def test_environment
    require 'rspec/core'

    super
  end

  def test_helper
    # don't let minitest setup another exit hook
    begin
      require 'minitest/unit'
      if defined?(Minitest::Runnable)
        # Minitest 5
        MiniTest.class_variable_set('@@installed_at_exit', true)
      elsif defined?(MiniTest)
        # Old versions of Minitest
        MiniTest::Unit.class_variable_set('@@installed_at_exit', true)
      end
    rescue LoadError
      # noop
    end

    if ENV['RAILS_TEST_HELPER']
      require ENV['RAILS_TEST_HELPER']
    else
      if File.exists?(ROOT_PATH + '/spec/rails_helper.rb')
        require 'rails_helper'
      elsif File.exists?(ROOT_PATH + '/test/minitest_helper.rb')
        require 'minitest_helper'
      else
        require 'test_helper'
      end
    end
  end

  def parallel_rspec
    require 'parallel_tests'

    ParallelTests::CLI.new.run(['--type', 'rspec'] + ARGV)
  end
end

Zeus.plan = CustomPlan.new
