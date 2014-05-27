#Copyright (c) 2014, IDEO 

require 'cgi'
def value_display(value)
  if value.is_a?(Array)
    "<span class='array' title='#{display_escaped(value)}'>[&hellip;]</span>"
  elsif value.to_s.length > 15
    value.to_s[0..10] + "&hellip;"
  else
    value.to_s
  end
end

def value_escaped(value)
    CGI.escape(value.to_s)
end

def display_escaped(value)
    CGI.escapeHTML(value.to_s)
end

# Includes milliseconds so receiver can differential fine-grained updates
def format_date( date )
	date.strftime( "%Y-%m-%dT%H:%M:%S:%L%z" ) if date
end

def format_date_utc( date )
	if date
		utc_date = date.new_offset(0)
		utc_date.strftime( "%Y-%m-%dT%H:%M:%S.%LZ" )
	end
end

# Add conversion from Time to Milliseconds
class Time
  def to_ms
    (self.to_f * 1000.0).to_i
  end
end
