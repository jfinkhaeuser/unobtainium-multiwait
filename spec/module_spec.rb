# coding: utf-8
#
# unobtainium-multiwait
# https://github.com/jfinkhaeuser/unobtainium-multiwait
#
# Copyright (c) 2016 Jens Finkhaeuser and other unobtainium-multiwait contributors.
# All rights reserved.
#
require 'spec_helper'

require 'unobtainium'

DRIVER = :headless
# DRIVER = :firefox
TEST_URL = 'file://' + Dir.pwd + '/spec/data/foo.html'

class Tester
  include ::Unobtainium::World
end # class Tester

describe 'Unobtainium::MultiWait::DriverModule' do
  before :each do
    @tester = Tester.new
  end

  describe "module interface" do
    it "passes unobtainium's interface checks" do
      expect do
        require 'unobtainium-multiwait'
      end.to_not raise_error(LoadError)
    end

    it "exposes wait methods" do
      drv = @tester.driver(DRIVER)
      expect(drv.respond_to?(:wait)).to be_truthy
      expect(drv.respond_to?(:multiwait)).to be_truthy
    end
  end

  describe "wait functionality" do
    before do
      require 'unobtainium-multiwait'
    end

    it "can wait for single element that already exists" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      drv.navigate.refresh
      elem = drv.wait(xpath: '//foo/bar')
      expect(elem).not_to be_nil
      expect(elem).not_to be_empty
      expect(elem.length).to eql 1
      expect(elem[0]).not_to be_nil
    end

    it "can wait for multiple elements that already exist" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      drv.navigate.refresh
      # rubocop:disable Style/BracesAroundHashParameters
      elem = drv.wait({ xpath: '//foo/bar' },
                      { xpath: '//something' })
      # rubocop:enable Style/BracesAroundHashParameters
      expect(elem).not_to be_nil
      expect(elem).not_to be_empty
      expect(elem.length).to eql 2
      expect(elem[0]).not_to be_nil
      expect(elem[1]).not_to be_nil
    end

    it "returns an element if it appears on time" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      drv.navigate.refresh
      elem = drv.wait(xpath: '//foo/appears')
      expect(elem).not_to be_nil
      expect(elem).not_to be_empty
      expect(elem.length).to eql 1
      expect(elem[0]).not_to be_nil
    end

    it "times out when an element can't be found in time" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      drv.navigate.refresh
      elem = drv.wait(xpath: '//foo/appears-too-late')
      expect(elem).not_to be_nil
      expect(elem).not_to be_empty
      expect(elem.length).to eql 1
      expect(elem[0]).to be_nil
    end

    it "returns all elements that can be found on time" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      drv.navigate.refresh
      # rubocop:disable Style/BracesAroundHashParameters
      elem = drv.wait({ xpath: '//foo/bar' },
                      { xpath: '//foo/appears' },
                      { xpath: '//foo/appears-too-late' })
      # rubocop:enable Style/BracesAroundHashParameters
      expect(elem).not_to be_nil
      expect(elem).not_to be_empty
      expect(elem.length).to eql 3
      expect(elem[0]).not_to be_nil
      expect(elem[1]).not_to be_nil
      expect(elem[2]).to be_nil
    end

    it "returns the first found element if :wait_for == :first" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      drv.navigate.refresh
      # rubocop:disable Style/BracesAroundHashParameters
      elem = drv.wait({ xpath: '//foo/appears' },
                      { xpath: '//foo/appears-too-late' },
                      { wait_for: :first })
      # rubocop:enable Style/BracesAroundHashParameters
      expect(elem).not_to be_nil
      expect(elem).not_to be_empty
      expect(elem.length).to eql 1
      expect(elem[0]).not_to be_nil
    end

    it "passes non-hash arguments without touching them" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      expect do
        drv.wait(42) # not a valid selector for selenium
      end.to raise_error
    end
  end

  describe "wait options" do
    before do
      require 'unobtainium-multiwait'
    end

    it "can throw on errors" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      # rubocop:disable Style/BracesAroundHashParameters
      expect do
        drv.wait({ xpath: '//does-not-exist' },
                 { xpath: '//foo' },
                 { raise_on_error: true })
      end.to raise_error(::Selenium::WebDriver::Error::TimeOutError)
      # rubocop:enable Style/BracesAroundHashParameters
    end

    it "can return errors" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      # rubocop:disable Style/BracesAroundHashParameters
      elems = drv.wait({ xpath: '//does-not-exist' },
                       { xpath: '//foo' },
                       { return_errors: true })
      # rubocop:enable Style/BracesAroundHashParameters
      expect(elems).not_to be_nil
      expect(elems).not_to be_empty
      expect(elems.length).to eql 2
      expect(elems[0]).not_to be_nil
      expect(elems[1]).not_to be_nil
      is_error = elems[0].is_a?(
        ::Selenium::WebDriver::Error::TimeOutError
      )
      expect(is_error).to be_truthy
    end

    it "can honour instance options" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      drv.multiwait_options = { raise_on_error: true }
      expect do
        drv.wait(xpath: '//does-not-exist')
      end.to raise_error(::Selenium::WebDriver::Error::TimeOutError)
    end

    it "validates :wait_for" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)

      # Good option
      drv.multiwait_options = { wait_for: :all }
      expect do
        drv.wait(xpath: '//foo')
      end.not_to raise_error

      # Bad option
      drv.multiwait_options = { wait_for: :bad }
      expect do
        drv.wait(xpath: '//foo')
      end.to raise_error
    end

    it "validates :check_element" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)

      # Good option
      drv.multiwait_options = { check_element: :exists? }
      expect do
        drv.wait(xpath: '//foo')
      end.not_to raise_error

      # Bad option
      drv.multiwait_options = { check_element: :foobar }
      expect do
        drv.wait(xpath: '//foo')
      end.to raise_error
    end
  end
end
