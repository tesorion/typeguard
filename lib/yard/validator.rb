# frozen_string_literal: true

module Yard; end
module Yard::Configuration; end
module Yard::Initializer; end
module Yard::Wrapper; end
module Yard::TypeModel; end
module Yard::TypeModel::Builder; end
module Yard::TypeModel::Parser; end

# require_relative 'validator/remove'

require_relative 'type_model/definitions'
require_relative 'type_model/parser'
require_relative 'type_model/builder'
require_relative 'validator/version'
# require_relative 'validator/initializer'
# require_relative 'validator/wrapper'
require_relative 'validator/main'
