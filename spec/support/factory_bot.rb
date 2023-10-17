# frozen_string_literal: true

require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    ActiveRecord::Base.transaction do
      FactoryBot.lint
    end
  end

  config.before do |_ex|
    FactoryBot.definition_file_paths = Dir['spec/factories/']

    FactoryBot.reload

    FactoryBot.use_parent_strategy = false
  end
end
