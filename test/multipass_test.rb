$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'test/unit'
require 'multipass'

class MultiPassTest < Test::Unit::TestCase
  def setup
    @date   = Time.now + 1234
    @input  = {:expires => @date, :email => 'ricky@bobby.com'}
    @output = @input.merge(:expires => @input[:expires].to_s)
    @key    = EzCrypto::Key.with_password('example', 'abc')
    @mp     = MultiPass.new('example', 'abc')
  end

  def test_encodes_multipass
    expected = @key.encrypt64(@output.to_json)
    assert_equal expected, @mp.encode(@input)
  end

  def test_encodes_multipass_with_class_method
    expected = @key.encrypt64(@output.to_json)
    assert_equal expected, MultiPass.encode('example', 'abc', @input)
  end

  def test_decodes_multipass
    encoded = @mp.encode(@input)
    assert_equal @input, @mp.decode(encoded)
  end

  def test_decodes_multipass_with_class_method
    encoded = @mp.encode(@input)
    assert_equal @input, MultiPass.decode('example', 'abc', encoded)
  end

  def test_invalidates_bad_string
    assert_raises MultiPass::DecryptError do
      @mp.decode("abc")
    end
  end

  def test_invalidates_bad_json
    assert_raises MultiPass::JSONError do
      @mp.decode(@key.encrypt64("abc"))
    end
    assert_raises MultiPass::JSONError do
      @mp.decode(@key.encrypt64("{a"))
    end
  end

  def test_invalidates_old_expiration
    encrypted = @key.encrypt64(@input.merge(:expires => (Time.now - 1)).to_json)
    assert_raises MultiPass::ExpiredError do
      @mp.decode(encrypted)
    end
  end
end