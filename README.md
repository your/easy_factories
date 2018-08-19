# EasyFactories

Set up test objects in Ruby with a lightweight and simple library.

Compatible with `ActiveModel`, `Dry::Struct` and any object that can be initialized with a hash with containing a list of key/value pairs.  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_factories'
```

## Usage

### Register factories

#### Default

```ruby
EasyFactories.register User do
  name 'John Doe'
  age 29
end
```

#### Variations

```ruby
EasyFactories.register User do
  factory :registered do
    name 'John Doe'
    age 29
    registered true
  end
end
```

### Build factories

```ruby
EasyFactories.build(User, age: 51)
EasyFactories.build(User, :registered)
EasyFactories.build(User, :registered, name: 'Paul Red')
```

## Development

This is a WIP project, as such it's very limited at the time being.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/your/easy_factories.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
