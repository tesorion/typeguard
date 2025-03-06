# frozen_string_literal: true

module Yard; end
module Yard::Configuration; end
module Yard::Initializer; end
module Yard::Wrapper; end

require_relative 'validator/remove'

require_relative 'validator/version'
require_relative 'validator/initializer'
require_relative 'validator/wrapper'
require_relative 'validator/main'
