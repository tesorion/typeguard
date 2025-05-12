# frozen_string_literal: true

require_relative '../lib/yard/validator'

# rubocop:disable all

class One
end
module A
  class Two
  end
  module B
    module C
      a_super = Object
      class Three < a_super
        
      end
    end
  end

  module B::C::D
  end

  module E
    SOME_CONST = 1
    class Four
      include A::E
      @@somevar = 1
    end
    module ::F
      class A::B::Five < A::E::Four
      end
      class Six
      end
    end
  end

  module ::G
  end
end

Yard.configure do |config|
  # config.source = :rbs
  # config.target = 'sig'
  config.source = :yard
  config.target = ['bin/example3.rb']
  config.enabled = true
  config.reparse = true
  config.at_exit_report = true
  config.resolution.raise_on_name_error = false
  config.wrapping.raise_on_unexpected_arity = false
  config.wrapping.raise_on_unexpected_visibility = false
  config.validation.raise_on_unexpected_argument = false
  config.validation.raise_on_unexpected_return = false
end.process!
