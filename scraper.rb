require 'Mechanize'
require 'Nokogiri'
require 'Pry'

# Use global variables - requires testing
username = ""
user_pass = ""
amount_due = ""
bill_amount = ""
start_date = ""
end_date = ""

mech = Mechanize.new

page = mech.get('https://mya.dom.com/')

# Select VA (https://www.dom.com/residential/dominion-virginia-power is broken)
# link = page.link_with(text: 'VA')
# page = link.click

# Get username and pass from User
puts "Please input your login info for Dominion (I'm sure this is typically stored somewhere with Arcadia)."

# Login
def login
puts "username:"
username = gets.chomp
puts "password:"
user_pass = gets.chomp
end
login

puts "Logging in... one sec.."

# Fill out Sign in for with Mechanize, hit submit button and change page var
form = page.forms.first
form['user'] = username
form['password'] = user_pass
page = form.submit

h1 = page.css("h1").text

if h1 == "Sign In"
  puts "Check your username and password and try again"
  login
elsif h1 == "My Account Overview"
  puts "Successfully logged in"
else
  puts "Something went wrong"
end

# View Past Usage page
due = page.css("table#billingAndPaymentsTable tbody tr[2] td[12]").inner_html()
amount_due = due.to_i

# Switch to Analyze Energy Usage page
link = page.link_with(text: 'Analyze Energy Usage')
page = link.click

# Test to make sure user got in, else send back to login.
usage = Nokogiri::HTML(page.body)

bill_amount = usage.css("table#billHistoryTable tbody tr[2] td[3]").text()
start_date = usage.css("table#paymentsTable tbody tr[3] td[1]").text()
end_date = usage.css("table#paymentsTable tbody tr[2] td[1]").text()

def calculate_bill
  if amount_due == 0
    puts "You don't owe anything!"
  else
    puts "You owe: #{bill_amount.to_i}"
  end
end
calculate_bill

# Get kwh from page
kwh = usage.css('table#paymentsTable tbody tr[2] td[3]').text()

# Hash
# usage (kWh), bill amount ($), service start date, service end date
bill_details = {}
bill_details[:kwh] = kwh
bill_details[:bill_amount] = bill_amount
bill_details[:start_date] = start_date
bill_details[:end_date] = end_date

# TODO
# Create method that calls in different tables with various cells, rows, and table IDs as parameters into Nokogiri
# Look into classes for this project
# Call in ENV vars (credentials)
# Nokogiri not returning second table of Analyze Energy User page. Convert app to Watir gem to see if that will do it.
