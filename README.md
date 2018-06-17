# LiffSelector

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/liff_selector`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'liff_selector'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install liff_selector

## Usage

### show
display all liff applications.

```
$ ./exe/liff_select show
id liffId   type  url
1. 1578425738-81wbQ6WM  full  https://example.com
2. 1578425738-8AM1APKY  tall  https://esample.com/1
```

### same
display same type and url liff applications.

```
./exe/liff_select same
> "type": full, "url": https://example.com
 - id: 1, liffId: XXXXXXXXXX-XXXXXXXX
> "type": tall, "url": https://esample.com/1
 - id: 2, liffId: XXXXXXXXXX-XXXXXXXX
```

### create
create new liff application. give type, url

```
./exe/liff_select create compact https://example.com
> make liff app
> [SUCESS] make app
> app uri : line://app/XXXXXXXXXX-XXXXXXXX
```

### delete

```
./exe/liff_select delete 1
1. XXXXXXXXXX-XXXXXXXX  compact https://example.com
> [SUCESS] delete app
```

### clean
delete same type and url applications

```
./exe/liff_select clean
> "type": tall, "url": https://liff-a4geru.c9users.io/charge
 - id: 1, liffId: 1578425738-8AM1APKY
> "type": compact, "url": https://liff-a4geru.c9users.io/
 - id: 2, liffId: 1578425738-GBp65o2R
 - id: 3, liffId: 1578425738-WeqQXxKp
 - id: 5, liffId: 1578425738-yLqlrmVE
> "type": compact, "url": https://liff-a4geru.c9users.io/charge
 - id: 4, liffId: 1578425738-YbD5yxAq
>> delete "id": 3, "type": compact, "url": https://liff-a4geru.c9users.io/
>> delete "id": 5, "type": compact, "url": https://liff-a4geru.c9users.io/
> [SUCESS] delete app
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/liff_selector. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LiffSelector project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/liff_selector/blob/master/CODE_OF_CONDUCT.md).
