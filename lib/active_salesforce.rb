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

require 'salesforce_connection_adapter'

module ActionView
  module Helpers
    # Provides a set of methods for making easy links and getting urls that depend on the controller and action. This means that
    # you can use the same format for links in the views that you do in the controller. The different methods are even named
    # synchronously, so link_to uses that same url as is generated by url_for, which again is the same url used for
    # redirection in redirect_to.
    module UrlHelper
      def link_to_asf(active_record, column)
        if column.reference_to
          link_to(column.reference_to, { :action => 'show', :controller => column.reference_to.pluralize, :id => active_record.send(column.name) } )
        else
          active_record.send(column.name)
        end
      end
    end
  end
end
