#!/usr/bin/ruby
#===================================================
#  Hardsploit API - By Opale Security
#  www.opale-security.com || www.hardsploit.io
#  License: GNU General Public License v3
#  License URI: http://www.gnu.org/licenses/gpl.txt
#===================================================
require 'io/console'
require_relative '../HardsploitAPI/Core/HardsploitAPI'
require_relative '../HardsploitAPI/Modules/SPI_SNIFFER/HardsploitAPI_SPI_SNIFFER'

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

@spi = HardsploitAPI_SPI_SNIFFER.new(mode:0,sniff:HardsploitAPI::SPISniffer::MOSI)  # MISO MOSI MISO_MOSI

sleep(0.5)
def spiCustomCommand
	i = '.'
	while 1
		i == "." ? i = ".." : i = "." #just to have a toggle in console to keep alive the console
		begin
			result = @spi.spi_receive_available_data

			#if half a simple array, if fullduplex  first item -> an array of MISO  and second array -> an array of MOSI
			case @spi.sniff
			when HardsploitAPI::SPISniffer::MISO
				puts "MISO : #{result}"
			when HardsploitAPI::SPISniffer::MOSI
				puts "MOSI : #{result}"
			else
				puts "MOSI : #{result[0]}"
				puts "MISO : #{result[1]}"
			end

			rescue HardsploitAPI::ERROR::HARDSPLOIT_NOT_FOUND
				puts "Hardsploit not found"
			rescue HardsploitAPI::ERROR::USB_ERROR
				puts i
				#Ignore time out because we read in continous
		end
	end
 end

while true
	char = STDIN.getch
	puts char
	if char ==  "\u0003"
		puts "Finished"
		exit

	elsif  char  == "i" then
			spiCustomCommand
	elsif  char  == "p" then
		print "Upload Firmware  check : #{HardsploitAPI.instance.uploadFirmware(pathFirmware:File.expand_path(File.dirname(__FILE__)) +  "/../../HARDSPLOIT-VHDL/Firmware/FPGA/SPI/SPI_SNIFFER/HARDSPLOIT_FIRMWARE_FPGA_SPI_SNIFFER.rpd",checkFirmware:false)}\n"
	end
end
