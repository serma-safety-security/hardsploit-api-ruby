#!/usr/bin/ruby
#===================================================
#  Hardsploit API - By Opale Security
#  www.opale-security.com || www.hardsploit.io
#  License: GNU General Public License v3
#  License URI: http://www.gnu.org/licenses/gpl.txt
#===================================================
require 'io/console'
require_relative '../HardsploitAPI/Core/HardsploitAPI'
require_relative '../HardsploitAPI/Modules/NRF24L01/HardsploitAPI_NRF24L01'

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
HardsploitAPI.id = 0

if ARGV[0] != "nofirmware" then
	print "Upload Firmware  check : #{HardsploitAPI.instance.uploadFirmware(pathFirmware:File.expand_path(File.dirname(__FILE__)) +  "/../../HARDSPLOIT-VHDL/Firmware/FPGA/SPI/SPI_INTERACT/HARDSPLOIT_FIRMWARE_FPGA_SPI_INTERACT.rpd",checkFirmware:false)}\n"
end
# Wait to be sure the fpga was started
sleep(1)

# HARDSPLOIT      		 				NRF24L01
# SPI_CLK   (pin A0)	 	===>    SCK
# SPI_CS 	  (pin A1)  	===>    CSN
# SPI_MOSI  (pin A2)  	===> 		MOSI
# SPI_MISO  (pin A3)		===> 		MISO
# SPI_PULSE (pin A4)		===>		 CE

begin
	@nrf = HardsploitAPI_NRF24L01.new
	if @nrf.reset then
		#You need to change your channel and you address
		@nrf.initDrone(channel:98,address:[0x66, 0x88, 0x68, 0x68, 0x68])
	else
		raise "NRF24L01 not found"
	end

rescue HardsploitAPI::ERROR::HARDSPLOIT_NOT_FOUND
	puts "Hardsploit not found"
rescue HardsploitAPI::ERROR::USB_ERROR
	puts "USB ERRROR"
end

puts "NRF24L01+"
puts "Press p to program hardsploit"
puts "Press r to received"
puts "Press t to transmit"
puts "Press s to sniff all channel"

while true
	char = STDIN.getch
	puts char
	if char ==  "\u0003"
		puts "Finished"
		exit
	elsif  char  == "t" then
		datat = [0xFF,0xFF]
		@nrf.Send(datat)
		puts "Send data"
		p datat
	elsif  char  == "r" then
		puts "Listen :"
    while 1
			 data = @nrf.Read
			if data.size > 0 then
  			p	data
			end
		end
	elsif  char  == "s" then
		puts "Sniffing in progress :"
		for i in 90..110
			@nrf.NRF24L01_FlushTx()
			@nrf.NRF24L01_FlushRx()
			@nrf.changeChannel(channel:i)
			timeoutValue = 1 # timeout in seconds

			#read during 1 second to verify if something is available
			timeBegin = Time.now
			while(1)
				if(Time.now - timeBegin) > timeoutValue then
						puts "Nothing to read on channel #{i} after #{timeoutValue} second"
						break
				end
				data = @nrf.Read
				if data.size > 0 then
					puts "Something is available on channel #{i}, you need to read this channel now"
					p data
					break
				end
			end
		end

	elsif  char  == "p" then
		print "Upload Firmware  check : #{HardsploitAPI.instance.uploadFirmware(pathFirmware:File.expand_path(File.dirname(__FILE__)) +  "/../../HARDSPLOIT-VHDL/Firmware/FPGA/SPI/SPI_INTERACT/HARDSPLOIT_FIRMWARE_FPGA_SPI_INTERACT.rpd",checkFirmware:false)}\n"
	end
end
