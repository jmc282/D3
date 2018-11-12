require 'sinatra'
require 'sinatra/reloader'


def determine_msg(ts, fs, s)
    return "ts:#{ts}, fs:#{fs}, s:#{s}"
  # end
end

def valid_args?(ts, fs, s)
   return (ts != fs) && s.to_i > 2 
end

def getHeading(size)
  toReturn = "<table><tr>"
  num = size-1
  size.times do
    toReturn << "<th>" + num.to_s + "</th>"
    num -= 1
  end

  toReturn << "<th>AND</th><th>OR</th><th>XOR</th> "
end

def getRows(t, f, size)
  rows = ""
  cols = size+3
  count = 0
  numRows = 2**size

  array = rowData(t, f, size)
  array = revert(t, f, array.flatten)

  numRows.times do
    rows << "<tr>"
      cols.times do
        rows << "<td>" + array[count].to_s 
        rows<< "</td>"
        count+=1
      end
    rows << "</tr>"
  end
  rows
end

def revert(t, f, array)
  toReturn = Array.new()
  array.each do |symbol|
    if symbol == true
      toReturn << t
    elsif symbol == false
      toReturn << f
    end
  end
  toReturn 
end


def convert(symbol)
  if symbol == "t" || symbol == "T" || symbol == "1" || symbol == 1
    true
  elsif symbol == "f" || symbol == "F" || symbol == "0" || symbol == 0
    false
  else
    symbol = symbol.to_i % 2
    if symbol == 1
      false
    elsif symbol == 0
      true
    end
  end
end 
  

def symbolData(t,f,size)
  a = Array.new()
  #initialize first row
  size.times do
    a << f
  end

  size.times do
    a << t
  end

  symbols = a.permutation(size).to_a
  return symbols.uniq
  
end


def resultData(size, data)
  and_result = data[0]
  or_result = data[0]
  xor_result = data[0]
  ind = 1
  while ind < size
    and_result = and_result & data[ind]
    or_result = or_result | data[ind]
    xor_result = xor_result ^ data[ind]
    ind+=1
  end

  data<<and_result
  data<<or_result
  data<<xor_result

  return data

  # and_result = true 
  # or_result = false
  # xor_result = false

  # if data.include? false
  #   and_result = false
  # end

  # if data.include? true
  #   or_result = true
  # end

  # if data.count(true) % 2 == 1
  #   xor_result = true
  # end

  # data<<and_result
  # data<<or_result
  # data<<xor_result

  # return data
end

def rowData(t, f, size)
  toReturn = Array.new()
  t = convert(t)
  f = convert(f)

  sd = symbolData(t,f,size)
  ind = 0
  while ind < sd.length
    data = resultData(size, sd[ind])
    toReturn << data
    ind+=1
  end
  return toReturn
end

def createTable(t, f, size)
  table = getHeading(size)
  table << getRows(t, f, size)
  table << "</table>"

end

# If a GET request comes in at /, do the following.

get '/' do
  # Get the parameters
  pts = params['ts']
  pfs = params['fs']
  ps = params['s']

  valid = false
  table = "null table"
  # Setting these variables here so that they are accessible
  # outside the conditional

  valid = valid_args? pts, pfs, ps
  
  if valid
    table = createTable pts, pfs, ps.to_i
  end 
      

  
  erb :index, :locals => { valid: valid, table:table}
end

get '/error' do
  erb :error
end

not_found do
  status 404
  erb :error
end
