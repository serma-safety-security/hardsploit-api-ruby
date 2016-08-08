#!/usr/bin/ruby
#===================================================
#  Hardsploit API - By Opale Security
#  www.opale-security.com || www.hardsploit.io
#  License: GNU General Public License v3
#  License URI: http://www.gnu.org/licenses/gpl.txt
#===================================================
require 'io/console'
require_relative '../HardsploitAPI/Core/HardsploitAPI'
require_relative '../HardsploitAPI/Modules/SPI/HardsploitAPI_SPI'

def callbackInfo(receiveData)
	print receiveData  + "\n"
end

def callbackData(receiveData)
	if receiveData != nil then
			puts "received #{receiveData.size}"
	  	p receiveData
	else
			puts "ISSUE BECAUSE DATA IS NIL"
	end
end

def callbackSpeedOfTransfert(receiveData)
	#puts "Speed : #{receiveData}"
end
def callbackProgress(percent:,startTime:,endTime:)
	puts "Progress : #{percent}%  Start@ #{startTime}  Stop@ #{endTime}"
	puts "Elasped time #{(endTime-startTime).round(4)} sec"
end

puts "Number of hardsploit detected :#{HardsploitAPI.getNumberOfBoardAvailable}"

HardsploitAPI.callbackInfo = method(:callbackInfo)
HardsploitAPI.callbackData = method(:callbackData)
HardsploitAPI.callbackSpeedOfTransfert = method(:callbackSpeedOfTransfert)
HardsploitAPI.callbackProgress = method(:callbackProgress)
HardsploitAPI.id = 0  # id of hardsploit 0 for the first one, 1 for the second etc

@spi = HardsploitAPI_SPI.new(speed:60,mode:0)
#The current API version
#p HardsploitAPI::VERSION::API

def spiCustomCommand
		#Speed Range 1-255  SPI clock =  150Mhz / (2*speed) tested from 3 to 255 (25Mhz to about 0.3Khz)

		testpack = Array.new
		for i in (0..10) do
			testpack.push i
		end
		result = @spi.spi_Interact(payload:testpack)
		p result
 end

while true
	char = STDIN.getch
	puts char
	if char ==  "\u0003"
		puts "Finished"
		exit

	elsif char == "z" then
			crossvalue = Array.new
			#Default wiring
			for i in 0..63
				crossvalue.push i
			end

			#swap 2 first signal
			crossvalue[0] = 1
			crossvalue[1] = 0
			crossvalue[2] = 2
			crossvalue[3] = 3

			crossvalue[60] = 60
			crossvalue[61] = 61
			crossvalue[62] = 62
			crossvalue[63] = 63

			HardsploitAPI.setCrossWiring(value:crossvalue)

			puts "cross SWAP"

	elsif char == "e" then
			crossvalue = Array.new
			#Default wiring
			for i in 0..63
				crossvalue.push i
			end

			#swap 2 first signal

			HardsploitAPI.setCrossWiring(value:crossvalue)
			puts "cross Normal"
	elsif  char  == "w" then
		HardsploitAPI.instance.setStatutLed(led:HardsploitAPI::USB_COMMAND::GREEN_LED,state:true);
		@spi.pulse=1
	elsif  char  == "x" then
		HardsploitAPI.instance.setStatutLed(led:HardsploitAPI::USB_COMMAND::GREEN_LED,state:false);
		@spi.pulse=0
	elsif  char  == "i" then
			spiCustomCommand
	elsif  char  == "p" then
		print "Upload Firmware  check : #{HardsploitAPI.instance.uploadFirmware(pathFirmware:File.expand_path(File.dirname(__FILE__)) +  "/../../HARDSPLOIT-VHDL/Firmware/FPGA/SPI/SPI_INTERACT/HARDSPLOIT_FIRMWARE_FPGA_SPI_INTERACT.rpd",checkFirmware:false)}\n"
	end
end
