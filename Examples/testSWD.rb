#!/usr/local/bin/ruby
#===================================================
#  Hardsploit API - By Opale Security
#  www.opale-security.com || www.hardsploit.io
#  License: GNU General Public License v3
#  License URI: http://www.gnu.org/licenses/gpl.txt
#===================================================
require 'io/console'
require_relative '../HardsploitAPI/Core/HardsploitAPI'
require_relative '../HardsploitAPI/Modules/SWD/HardsploitAPI_SWD'

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
def swdCustomRead
	begin
		swd = HardsploitAPI_SWD.new(
			memory_start_address: "0x08000000",
			memory_size_address:   "0x1FFFF7E0",
			cpu_id_address:		   "0xE000ED00",
			device_id_address:	   "0x1FFFF7E8"
		)
		#TO OBTAIN ID CODE
		code = swd.obtainCodes
		puts "DP.IDCODE: 	#{code[:DebugPortId].to_s(16)} "
		#puts "AP.IDCODE: 	#{code[:AccessPortId].to_s(16)} "
		#puts "CPU ID : 		#{code[:CpuId].to_s(16)} "
		#	puts "DEVICE ID : #{code[:DeviceId].to_s(16)}"
	rescue
		puts "MCU NOT FOUND"
		#puts "Read ARM Register"
		#swd.readRegs

		#puts "stop"
		#swd.stop

		#TO DUMP FLASH
		#swd.dumpFlash('dumdp.bin')
		#swd.erase
		# ERASE FLASH !!!!!!!!!!  AND WRITE THE CONTENT OF THE FILE ON THE FLASH
		#swd.writeFlash('dumdp2.bin')

	rescue HardsploitAPI::ERROR::HARDSPLOIT_NOT_FOUND
		puts "Hardsploit not found"
	rescue HardsploitAPI::ERROR::USB_ERROR
		puts "USB ERRROR"
	end
end
def swdCustomWrite
	begin

		swd = HardsploitAPI_SWD.new(
			memory_start_address: "0x08000000",
			memory_size_address:  "0x1FFFF7E0",
			cpu_id_address:		  	"0xE000ED00",
			device_id_address:	  "0x1FFFF7E8"
		)
		#TO OBTAIN ID CODE
		code = swd.obtainCodes
		puts "DP.IDCODE: 	#{code[:DebugPortId].to_s(16)} "
		puts "AP.IDCODE: 	#{code[:AccessPortId].to_s(16)} "
		puts "CPU ID : 		#{code[:CpuId].to_s(16)} "

	#TO DUMP FLASH
	#swd.dumpFlash('dumdp.bin')
	#swd.erase
	# ERASE FLASH !!!!!!!!!!  AND WRITE THE CONTENT OF THE FILE ON THE FLASH
	swd.writeFlash('dumdp2.bin')
	#unhalt
	#swd.stop

	rescue HardsploitAPI::ERROR::HARDSPLOIT_NOT_FOUND
		puts "Hardsploit not found"
	rescue HardsploitAPI::ERROR::USB_ERROR
		puts "USB ERRROR"
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
			crossvalue[1] = HardsploitAPI.getSignalId(signal:"SWD_CLK")
			crossvalue[2] = HardsploitAPI.getSignalId(signal:"SWD_IO")

			crossvalue[0] = 2

			p crossvalue
			HardsploitAPI.instance.setCrossWiring(value:crossvalue)

			puts "cross SWAP"
			HardsploitAPI.instance.signalHelpingWiring(signal:"SWD_CLK")
	elsif char == "e" then
			crossvalue = Array.new
			#Default wiring
			for i in 0..63
				crossvalue.push i
			end

			crossvalue[0] = 2
			crossvalue[1] = HardsploitAPI.getSignalId(signal:"SWD_IO")
			crossvalue[2] = HardsploitAPI.getSignalId(signal:"SWD_CLK")

			p crossvalue
			HardsploitAPI.instance.setCrossWiring(value:crossvalue)
			puts "cross Normal"

			HardsploitAPI.instance.signalHelpingWiring(signal:"SWD_CLK")
	# TEST POUR LE BUG DE CROSS WIRING PRESS M
	elsif char == 'm'
		# 0 = CLK
		# 1 = IO
		swd = HardsploitAPI_SWD.new(
			memory_start_address: "0x08000000",
			memory_size_address:  "0x1FFFF7E0",
			cpu_id_address:		  	"0xE000ED00",
			device_id_address:	  "0x1FFFF7E8"
		)
		base_crossvalue = Array.new
		for i in 0..63
			base_crossvalue.push i
		end
		crossvalue = Array.new(base_crossvalue)
		crossvalue[0] = 2
		crossvalue[1] = 3
		crossvalue[2] = 1
		crossvalue[3] = 0
		HardsploitAPI.instance.setCrossWiring(value:crossvalue)
		result = swd.obtainCodes
		#for i in 0..63
		#	crossvalue = Array.new(base_crossvalue)
		#	crossvalue[i] = 0
		#	crossvalue[0] = i
		#	crossvalue[i.next] = 1
		#	crossvalue[1] = i.next
		#	p crossvalue
		#	HardsploitAPI.instance.setCrossWiring(value:crossvalue)
		#	result = swd.obtainCodes
		#	p result unless result.nil?
		#	char = 'r'
		#	p "Branchement suivant"
		#	while char != 'n'
		#		char = STDIN.getch
		#		p "Next"
		#	end
		#end
	elsif  char  == "i" then
		crossvalue = Array.new
		#Default wiring
		for i in 0..63
			crossvalue.push i
		end
		#HardsploitAPI.instance.stopFPGA
		#sleep(1)
		#HardsploitAPI.instance.startFPGA
		#sleep(1)
		HardsploitAPI.instance.setCrossWiring(value:crossvalue)

	  swd.find(numberOfConnectedPinFromA0:2)
	elsif  char  == "w" then
		HardsploitAPI.instance.setStatutLed(led:HardsploitAPI::USB_COMMAND::GREEN_LED,state:true);
	elsif  char  == "x" then
		HardsploitAPI.instance.setStatutLed(led:HardsploitAPI::USB_COMMAND::GREEN_LED,state:false);
	elsif  char  == "f" then
				swdCustomRead
	elsif  char  == "g" then
				swdCustomWrite

	elsif  char  == "1" then
				puts "Read @ 0x20000000 "
				p swd.read_mem32(0x20000000,3)
				#p swd.read_mem8(0x20000000,4)

	elsif  char  == "2" then
				puts "Write @ 0x20000000 "
				swd.write_mem32(0x20000000,[11,11,11,11,11,11,11,11,11,11,11,11])
				swd.write_mem8(0x20000000,[1,2,3,4,5,6,7,8,9,10,14,12])

	elsif  char  == "p" then
		print "Upload Firmware  check : #{HardsploitAPI.instance.uploadFirmware(pathFirmware:File.expand_path(File.dirname(__FILE__)) +  "/../../HARDSPLOIT-VHDL/Firmware/FPGA/SWD/SWD_INTERACT/HARDSPLOIT_FIRMWARE_FPGA_SWD_INTERACT.rpd",checkFirmware:false)}\n"
	end
end
