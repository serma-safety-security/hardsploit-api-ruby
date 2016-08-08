#!/usr/bin/ruby
#===================================================
#  Hardsploit API - By Opale Security
#  www.opale-security.com || www.hardsploit.io
#  License: GNU General Public License v3
#  License URI: http://www.gnu.org/licenses/gpl.txt
#===================================================
require 'io/console'
require_relative '../HardsploitAPI/Core/HardsploitAPI'
require_relative '../HardsploitAPI/Modules/NO_MUX_PARALLEL_MEMORY/HardsploitAPI_NO_MUX_PARALLEL_MEMORY'

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
HardsploitAPI.id = ARGV[0].to_i  # id of hardsploit 0 for the first one, 1 for the second etc
@para = HardsploitAPI_PARALLEL.new



while true
	char = STDIN.getch
	puts char
	if char ==  "\u0003"
		puts "Finished"
		exit

	#Dump  parallele 8 bits at 100ns for latency
elsif  char  == "a" then
		time = Time.new
		#dump_size =65536 #ROM
		dump_size =65536 #RAM


		@para.read_Memory_WithoutMultiplexing(path:"file.bin",addressStart:0,addressStop:dump_size-1,bits8_or_bits16_DataSize:true,latency:1600 ) # true = 8 bits 1600ns latency
		time = Time.new - time
		puts "DUMP #{((dump_size/time)).round(2)}Bytes/s #{(dump_size)}Bytes in #{time.round(4)} s"

	#Dump  parallele 16 bits at 100ns for latency
 elsif  char  == "z" then
		time = Time.new
		dump_size  = 5
		@para.read_Memory_WithoutMultiplexing(path:"file.bin",addressStart:0,addressStop:dump_size-1,bits8_or_bits16_DataSize:false,latency:1600)   #false = 16 bits  1600ns latency
		time = Time.new - time
		puts "DUMP #{((2*(dump_size)/(1024*time))).round(2)}KBytes/s   #{(2*dump_size)}Bytes in  #{time.round(4)} s"

	elsif  char  == "w" then
		HardsploitAPI.instance.setStatutLed(led:HardsploitAPI::USB_COMMAND::GREEN_LED,state:true);
	elsif  char  == "x" then
		HardsploitAPI.instance.setStatutLed(led:HardsploitAPI::USB_COMMAND::GREEN_LED,state:false);

	elsif  char  == "p" then
		print "Upload Firmware  check : #{HardsploitAPI.instance.uploadFirmware(pathFirmware:File.expand_path(File.dirname(__FILE__)) +  "/../../HARDSPLOIT-VHDL/Firmware/FPGA/PARALLEL/NO_MUX_PARALLEL_MEMORY/HARDSPLOIT_FIRMWARE_FPGA_NO_MUX_PARALLEL_MEMORY.rpd", checkFirmware:true)}\n"
	end
end
