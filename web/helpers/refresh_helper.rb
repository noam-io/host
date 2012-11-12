require 'cgi'
def value_display(value)
  if value.is_a?(Array)
    "<span class='array' title=#{value_escaped(value)}>[&hellip;]</span>"
  elsif value.to_s.length > 15
    value.to_s[0..10] + "&hellip;"
  else
    value.to_s
  end
end

def value_escaped(value)
    escaped = CGI.escape(value.to_s)
end

def format_date( date )
  date.strftime( "%l.%M.%S" ) if date
end
