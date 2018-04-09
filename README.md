# unobtainium-multiwait

This gem provides a driver module for [unobtainium](https://github.com/jfinkhaeuser/unobtainium)
allowing for more easily finding (one of) multiple elements.

[![Gem Version](https://badge.fury.io/rb/unobtainium-multiwait.svg)](https://badge.fury.io/rb/unobtainium-multiwait)
[![Build status](https://travis-ci.org/jfinkhaeuser/unobtainium-multiwait.svg?branch=master)](https://travis-ci.org/jfinkhaeuser/unobtainium-multiwait)

To use it, require it after requiring unobtainium, then create the any driver
with a Selenium API:

```ruby
require 'unobtainium'
require 'unobtainium-multiwait'

include Unobtainium::World

driver.navigate.to('http://finkhaeuser.de')

elems = driver.multiwait({ xpath: '//some-element' },
                         { xpath: '//other-element' },
                         timeout: 10)

# Entries will be nil if nothing is found by these xpaths before the
# timeout expires.
puts elems.length # => 2
```
