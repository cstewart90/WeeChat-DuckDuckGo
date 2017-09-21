# Copyright (c) 2016 Christopher Stewart
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

SCRIPT_NAME    = 'duckduckgo'.freeze
SCRIPT_AUTHOR  = 'kanzo'.freeze
SCRIPT_DESC    = 'Adds !ddg command to search using DuckDuckGo.'.freeze
SCRIPT_VERSION = '0.1'.freeze
SCRIPT_LICENSE = 'MIT'.freeze

require 'cgi'
require 'open-uri'
require 'json'

def weechat_init
  Weechat.register(SCRIPT_NAME, SCRIPT_AUTHOR, SCRIPT_VERSION, SCRIPT_LICENSE, SCRIPT_DESC, '', '')

  Weechat.hook_print('', 'notify_message', '!ddg', 1, 'hook_print_cb', '')
  Weechat.hook_print('', 'notify_none', '!ddg', 1, 'hook_print_cb', '')
  Weechat::WEECHAT_RC_OK
end

def hook_print_cb(_data, buffer, _time, _tags, _displayed, _highlight, _prefix, message)
  return Weechat::WEECHAT_RC_OK unless message.downcase.start_with?('!ddg ')

  encoded = CGI.escape(message[5..-1])
  url = ddg(encoded)

  Weechat.command(buffer, url)
end

def ddg(query)
  default_url = "https://duckduckgo.com/?q=#{query}"
  r = open(
    "https://api.duckduckgo.com/?q=#{query}&format=json&pretty=0&no_redirect=1"
  ).read
  data = JSON.parse(r)

  data['Redirect'].to_s.empty? ? default_url : data['Redirect']
rescue SocketError, OpenURI::HTTPError
  default_url
end
