require 'test/unit'
require 'recording_mock'
=begin
  ActiveSalesforce
  Copyright (c) 2006 Doug Chasman

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
=end


require 'pp'


class RecordingMockTest < Test::Unit::TestCase
  attr_reader :connection
  
  
  def recording?
    @recording
  end
  
  
  def setup
    url = 'https://www.salesforce.com/services/Soap/u/7.0'

    @recording = (not File.exists?(recording_file_name))
    
    @connection = MockBinding.new(url, nil, recording?)

    unless recording?
      File.open(recording_file_name) do |f|
        connection.load(f)
      end
    end
    
    response = connection.login('doug_chasman@yahoo.com', 'Maceymo@11')  
  end
  
  
  def teardown
    if recording?
      File.open(recording_file_name, "w+") do |f|
        connection.dump(f)
      end
    end 
  end

  
  def test_login
  end 
  
  
  def recording_file_name
    "#{self.class.name}.#{method_name}.recording"
  end
  
end
