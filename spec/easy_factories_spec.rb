require 'active_model'
require 'dry-struct'

RSpec.describe EasyFactories do
  it 'has a version number' do
    expect(EasyFactories::VERSION).not_to be nil
  end

  class TestDryStructClass < Dry::Struct
    include Dry::Types.module
    attribute :name, Strict::String
    attribute :age, Coercible::Integer
  end

  class TestActiveModelClass
    include ActiveModel::Model
    attr_accessor :name, :age
  end

  register_factory = lambda do |klass, *args|
    factory = args[0].is_a?(Hash) ? nil : args[0]
    attributes = args[0].is_a?(Hash) ? args[0] : args[1] || {}

    EasyFactories.register(klass) do
      defaults = lambda do
        attributes.each do |attribute, value|
          send(attribute.to_s, value)
        end
      end

      if factory.present?
        send(:factory, factory) { defaults.call }
      else
        defaults.call
      end
    end
  end

  describe '.register' do
    context 'when registering an illegal class' do
      it 'throws an error' do
        expect { register_factory.call('not-a-class', foo: 'bar') }
          .to raise_error(
            EasyFactories::IllegalClassError,
            "'not-a-class' is not a Class object"
          )
      end
    end

    context 'when registering valid class Easyfactories' do
      it 'registers Easyfactories' do
        register_factory.call(TestDryStructClass, name: 'foo', age: '29')
        register_factory.call(TestActiveModelClass, name: 'bar', age: '30')

        expect(EasyFactories.registered)
          .to match(
            hash_including(
              'TestDryStructClass' => {
                nil => {
                  name: 'foo',
                  age: '29'
                }
              },
              'TestActiveModelClass' => {
                nil => {
                  name: 'bar',
                  age: '30'
                }
              }
            )
          )
      end
    end

    context 'when registering non-default class factory' do
      it 'registers factory' do
        register_factory.call(
          TestDryStructClass,
          :special,
          name: 'Obama',
          age: '60'
        )

        expect(EasyFactories.registered)
          .to match(
            hash_including(
              'TestDryStructClass' => { special: { name: 'Obama', age: '60' } }
            )
          )
      end
    end
  end

  describe '.build' do
    shared_examples "instantiates an object of the registered factory's type" do
      it "instantiates an object of the registered factory's type" do
        expect(object).to be_a(TestDryStructClass)
      end
    end

    context 'when class does not have registered Easyfactories' do
      class UnregisteredTestClass
        attr_accessor :foo
      end

      it 'throws an error' do
        expect { EasyFactories.build(UnregisteredTestClass) }
          .to raise_error(
            EasyFactories::UnregisteredFactoryError,
            "'UnregisteredTestClass' does not have registered factories"
          )
      end
    end

    context 'when using default factory and attributes' do
      subject(:object) { EasyFactories.build(TestDryStructClass) }

      before do
        register_factory.call(TestDryStructClass, name: 'foo', age: '29')
      end

      include_examples "instantiates an object of the registered factory's type"

      it 'instantiates an object with the given attributes' do
        expect(object.name).to eq('foo')
        expect(object.age).to eq(29)
      end
    end

    context 'when overriding attributes' do
      subject(:object) do
        EasyFactories.build(TestDryStructClass, name: 'bar', age: '18')
      end

      before do
        register_factory.call(TestDryStructClass, name: 'foo', age: '29')
      end

      include_examples "instantiates an object of the registered factory's type"

      it 'instantiates an object with the given attributes' do
        expect(object.name).to eq('bar')
        expect(object.age).to eq(18)
      end
    end

    context 'when class cannot be initialized' do
      class UnsupportedTestClass
        attr_accessor :foo
      end

      before do
        register_factory.call(UnsupportedTestClass, foo: 'bar')
      end

      it 'throws an error' do
        expect do
          EasyFactories.build(UnsupportedTestClass)
        end.to raise_error(EasyFactories::CannotInstantiateClassError)
      end
    end

    context 'when building a non-default factory' do
      subject(:object) do
        EasyFactories.build(
          TestDryStructClass,
          :special,
          name: 'bar',
          age: '66'
        )
      end

      before do
        register_factory.call(
          TestDryStructClass,
          :special,
          name: 'foo',
          age: '99'
        )
      end

      include_examples "instantiates an object of the registered factory's type"

      it 'instantiates an object with the given attributes' do
        expect(object.name).to eq('bar')
        expect(object.age).to eq(66)
      end
    end
  end
end
