#
# Here we setup the factory *environment*, not factories themselves (do that in factories.rb)
# Allows us to separate factory definitions from setup
#

include ActionDispatch::TestProcess


#
# Configure test env for specified validator
#

validator_factory=Settings.validator.test.factory
require Rails.root.join(validator_factory) if validator_factory.present?

validator_helper=Settings.validator.test.helper

if validator_helper.present?
  require Rails.root.join(validator_helper)
  include File.basename(validator_helper).camelize.constantize
end


#
# Allows overriding of factories by engines, etc.
Factory.class_eval <<-METHOD
  def self.define_default(*args, &block)
    return if Factory.factories.has_key? args[0]
    define *args, &block
  end
METHOD