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
@uart = HardsploitAPI_UART.new(baud_rate:57600, word_width:8,use_parity_bit:0,parity_type:0,nb_stop_bits:1,idle_line_level:1)
puts "Effective baudrate #{@uart.baud_rate}"

Thread.new{uartCustomRead()}
puts "Reading :"

def uartCustomSend
	begin
		payload = Array.new
		for i in 0..23
			payload.push 0x40
		end
		payload.push 13 #Carriage return

		@uart.write(payload:payload)
		puts payload.pack("C*")
		rescue HardsploitAPI::ERROR::HARDSPLOIT_NOT_FOUND
			puts "Hardsploit not found"
		rescue HardsploitAPI::ERROR::USB_ERROR
		  puts "USB ERRROR"
	end
end

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
		sleep(0.2)
	end
end

while true
	char = STDIN.getch
	puts char
	if char ==  "\u0003"
		puts "Finished"
		exit

	elsif  char  == "e" then
		puts "enableMeasureBaudRate"
		@uart.enableMeasureBaudRate

	elsif  char  == "d" then
		 puts "disableMeasureBaudRate"
 		@uart.disableMeasureBaudRate

	elsif  char  == "b" then
			p 	@uart.measureBaudRate
	elsif  char  == "s" then
			puts "uartCustomSend"
			uartCustomSend
	elsif  char  == "r" then
		#Thread.new{uartCustomRead()}
		uartCustomRead()
	elsif  char  == "p" then
		HardsploitAPI.instance.loadFirmware("UART")
		@uart.setSettings
	end
end
