#!/usr/bin/ruby
#===================================================
#  Hardsploit API - By Opale Security
#  www.opale-security.com || www.hardsploit.io
#  License: GNU General Public License v3
#  License URI: http://www.gnu.org/licenses/gpl.txt
#===================================================
require 'io/console'
require_relative '../HardsploitAPI/Core/HardsploitAPI'
require_relative '../HardsploitAPI/Modules/UART/HardsploitAPI_UART'

def callbackInfo(receiveData)
	#print receiveData  + "\n"
end

def callbackData(receiveData)
	if receiveData != nil then
			puts "received #{receiveData.size}"
	  	p receiveData
	end
end

def callbackSpeedOfTransfert(receiveData)
	#puts "Speed : #{receiveData}"
end
def callbackProgress(percent:,startTime:,endTime:)
	print "\r\e[#{31}mUpload of FPGA firmware in progress : #{percent}%\e[0m"
	#puts "Progress : #{percent}%  Start@ #{startTime}  Stop@ #{endTime}"
	#puts "Elasped time #{(endTime-startTime).round(4)} sec"
end

#puts "Number of hardsploit detected :#{HardsploitAPI.getNumberOfBoardAvailable}"

HardsploitAPI.callbackInfo = method(:callbackInfo)
HardsploitAPI.callbackData = method(:callbackData)
HardsploitAPI.callbackSpeedOfTransfert = method(:callbackSpeedOfTransfert)
HardsploitAPI.callbackProgress = method(:callbackProgress)
HardsploitAPI.id = 0  # id of hardsploit 0 for the first one, 1 for the second etc

HardsploitAPI.instance.getAllVersions

if ARGV[0] != "nofirmware" then
	HardsploitAPI.instance.loadFirmware("UART")
end

@uart = HardsploitAPI_UART.new(baud_rate:57600, word_width:8,use_parity_bit:0,parity_type:0,nb_stop_bits:2,idle_line_level:1)
puts "\nEffective baudrate #{@uart.baud_rate} \n"
Thread.new{uartCustomRead()}
puts "Start reading :\n\n"

def uartCustomRead
	while 1
		begin
			tab = @uart.sendAndReceived
			print tab.pack('c*')
			rescue HardsploitAPI::ERROR::HARDSPLOIT_NOT_FOUND
				puts "Hardsploit not found"
		  rescue HardsploitAPI::ERROR::USB_ERROR
			  puts "USB ERRROR"
		end
		sleep(0.1)
	end
end

while true
	char = STDIN.getch
	if char ==  "\u0003"
		puts "Finished"
		exit
	else
		@uart.write(payload:[char.ord])
		print char
	end
end
