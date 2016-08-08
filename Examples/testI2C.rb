#!/usr/bin/ruby
#===================================================
#  Hardsploit API - By Opale Security
#  www.opale-security.com || www.hardsploit.io
#  License: GNU General Public License v3
#  License URI: http://www.gnu.org/licenses/gpl.txt
#===================================================
require 'io/console'
require_relative '../HardsploitAPI/Core/HardsploitAPI'
require_relative '../HardsploitAPI/Modules/I2C/HardsploitAPI_I2C'

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


#The current API version
#p HardsploitAPI::VERSION::API


def i2cCustomScan
	begin
		#Create an instance of I2C
		i2c = HardsploitAPI_I2C.new(speed:HardsploitAPI::I2C::KHZ_100)

		#Change the speed
		i2c.speed = HardsploitAPI::I2C::KHZ_100

		#scan I2C
		puts "I2C SCAN :"
		scan_result = i2c.i2c_Scan
		#check parity of array index to know if a Read or Write address
		# Index 0 is write address because is is even
		# Index 1 is read address because it is  odd

		# Index 160 (0xA0) is write address because is is even
		# Index 161 (0xA1) is read address because is is odd

		#If value is 0 slave address is not available
		#If valude is 1 slave address is available

		for i in (0..scan_result.size-1) do
			if scan_result[i] == 1 then
				puts " #{(i).to_s(16)} #{scan_result[i]}"
			end
		end

	rescue HardsploitAPI::ERROR::HARDSPLOIT_NOT_FOUND
		puts "Hardsploit not found"
	rescue HardsploitAPI::ERROR::USB_ERROR
		puts "USB ERRROR"
  end
end

def i2cCustomInteract
	begin
		#Create an instance of I2C
		i2c = HardsploitAPI_I2C.new(speed:HardsploitAPI::I2C::KHZ_100)

		testpack = Array.new

		#interact I2C
		# write with even address
		# read with odd address

		#Write 4 bytes at 0x00 0x00
		# testpack.push HardAPI.lowByte(4)  #Count Low  Byte
		# testpack.push HardAPI.highByte(4)   #Count High Byte
		# testpack.push 0xA0
		# testpack.push 41  #First data byte
		# testpack.push 42  #Second data byte
		# testpack.push 43
		# testpack.push 44


		#Write pointer of I2C memorie at 0x00 0x00
		# testpack.push HardsploitAPI.lowByte(word:2)  #Count Low  Byte
		# testpack.push HardsploitAPI.highByte(word:2)   #Count High Byte
		# testpack.push 0xA0
		# testpack.push 0x00
		# testpack.push 0x00

		testpack.push HardsploitAPI.lowByte(word:2)  #Count Low  Byte
		testpack.push HardsploitAPI.highByte(word:2)   #Count High Byte
		testpack.push 0xA0
		testpack.push 0x00
		testpack.push 0x00

		testpack.push HardsploitAPI.lowByte(word:4)  #Count Low  Byte
		testpack.push HardsploitAPI.highByte(word:4)   #Count High Byte
		testpack.push 0xA1




		begin
			#result contient les ACK NACK ou les data si dispo cf wiki
			# https://github.com/OPALESECURITY/hardsploit-api/wiki#i2c-interact
			result = i2c.i2c_Interact(payload:testpack)
			p result
		rescue HardsploitAPI::ERROR::USB_ERROR
			puts "Error during USB communication, please retry"
		end

	rescue HardsploitAPI::ERROR::HARDSPLOIT_NOT_FOUND
		puts "Hardsploit not found"
	end
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
			crossvalue[0] = 8
			crossvalue[1] = 9

			crossvalue[8] = 0
			crossvalue[9] = 1

			HardsploitAPI.instance.setCrossWiring(value:crossvalue)

			puts "cross SWAP"

	elsif char == "e" then
			crossvalue = Array.new
			#Default wiring
			for i in 0..63
				crossvalue.push i
			end
			HardsploitAPI.instance.setCrossWiring(value:crossvalue)
			puts "cross Normal"

	elsif  char  == "w" then
		HardsploitAPI.instance.setStatutLed(led:HardsploitAPI::USB_COMMAND::GREEN_LED,state:true);
	elsif  char  == "x" then
		HardsploitAPI.instance.setStatutLed(led:HardsploitAPI::USB_COMMAND::GREEN_LED,state:false);
	elsif  char  == "i" then
			i2cCustomInteract
	elsif  char  == "s" then
			i2cCustomScan
	elsif  char  == "p" then
		print "Upload Firmware  check : #{HardsploitAPI.instance.uploadFirmware(pathFirmware:File.expand_path(File.dirname(__FILE__)) +  "/../../HARDSPLOIT-VHDL/Firmware/FPGA/I2C/I2C_INTERACT/HARDSPLOIT_FIRMWARE_FPGA_I2C_INTERACT.rpd",checkFirmware:false)}\n"
	end
end
