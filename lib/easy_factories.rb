require 'easy_factories/version'

module EasyFactories
  class DSLProxy
    attr_reader :__default_attributes, :__factory

    def initialize(&defaults)
      @__default_attributes = {}
      @__factory = nil

      instance_eval(&defaults)
    end

    def factory(name, &defaults)
      @__factory = name

      instance_eval(&defaults)
    end

    def method_missing(attribute, value)
      add_attribute!(attribute, value) || super # if you love someone...
    end

    def respond_to_missing?(*_args)
      true
    end

    def add_attribute!(attribute, value)
      __default_attributes.merge!(attribute => value)
    end
  end
  private_constant :DSLProxy

  CannotInstantiateClassError = Class.new(StandardError)
  IllegalClassError = Class.new(StandardError)
  UnregisteredFactoryError = Class.new(StandardError)

  @registered = {}

  class << self
    def build(klass, *args)
      handle_exceptions_for(klass) do
        factory = fetch_factory(*args)
        attributes = fetch_attributes(*args)

        available_factories = @registered.fetch(klass.to_s, nil)
        validate_class_registration(klass, available_factories)

        default_attributes = available_factories.fetch(factory, nil)
        validate_factory_registration(klass, default_attributes, factory)

        klass.new(default_attributes.merge(attributes))
      end
    end

    def register(klass, &defaults)
      unless klass.is_a?(Class)
        raise IllegalClassError, "'#{klass}' is not a Class object"
      end

      proxy = DSLProxy.new(&defaults)
      @registered.merge!(
        klass.name => {
          proxy.__factory => proxy.__default_attributes
        }
      )
    end

    attr_reader :registered

    private

    def handle_exceptions_for(klass)
      yield
    rescue UnregisteredFactoryError
      raise
    rescue StandardError => e
      raise CannotInstantiateClassError,
            "'#{klass}' cannot be instantiated (#{e.message})"
    end

    def validate_class_registration(klass, factories)
      return if @registered.key?(klass.to_s) && factories.present?

      raise UnregisteredFactoryError,
            "'#{klass}' does not have registered factories"
    end

    def validate_factory_registration(klass, attributes, factory)
      return if attributes.present?

      raise UnregisteredFactoryError,
            "'#{factory}' is not a registered factory for '#{klass}'"
    end

    def fetch_factory(*args)
      args[0].is_a?(Hash) ? nil : args[0]
    end

    def fetch_attributes(*args)
      args[0].is_a?(Hash) ? args[0] : args[1] || {}
    end
  end
end
