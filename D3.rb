require 'sinatra'
require 'sinatra/reloader'

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

def valid_params?(ts, fs, s)
  return (ts != fs) && s.to_i >= 2 
end

# If a GET request comes in at /, do the following.
def getSymbols(pts, pfs, ps)

  array = ["t","T","F","f","0","1","2","3","4","5","6","7","8","9"]
  trueParams = ["t","T","1","2","4","6","8"]
  falseParams = ["f","F","0","3","5","7","9"]
  if trueParams.include?(pts) && trueParams.include?(pfs) || falseParams.include?(pts) && falseParams.include?(pfs)
    ts = nil
    fs = nil
    s = nil
  else
      if pts == ""
        ts = "T"
      elsif array.include? pts
        ts = pts
      else
        ts = nil
      end

      if pfs == ""
        fs = "F"
      elsif array.include? pfs
        fs = pfs
      else
        fs = nil
      end

      if ps == ""
        s = "3"
      elsif array.include? ps
        s = ps
      else
        s = nil
      end
  end



  return ts, fs, s

end

get '/' do
  # Get the parameters
  pts = params['ts']
  pfs = params['fs']
  ps = params['s']

  valid = false
  table = ""

  # if all fields are nil, no data entered yet and submit button not pressed
  if pts.nil? && pfs.nil? && ps.nil?
    show = true
  else # if the button was pressed
    show = false

    ts, fs, s = getSymbols(pts, pfs, ps)
    if ts == nil || fs == nil || s == nil
      redirect '/error'
    end

    valid = valid_params? ts, fs, s.to_i
  
    if valid
      table = createTable ts, fs, s.to_i
    else
      redirect '/error'
    end 
  end
  erb :index, :locals => { valid: valid, table:table, show:show}
end


get '/error' do
  erb :error
end

not_found do
  status 404
  erb :notfound
end
