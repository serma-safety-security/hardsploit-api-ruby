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
	puts "Progress : #{percent}% Elasped time #{(endTime-startTime).round(4)} sec"
end

puts "Number of hardsploit detected :#{HardsploitAPI.getNumberOfBoardAvailable}"

HardsploitAPI.callbackInfo = method(:callbackInfo)
HardsploitAPI.callbackData = method(:callbackData)
HardsploitAPI.callbackSpeedOfTransfert = method(:callbackSpeedOfTransfert)
HardsploitAPI.callbackProgress = method(:callbackProgress)
HardsploitAPI.id = 0  # id of hardsploit 0 for the first one, 1 for the second etc

begin
	swd = HardsploitAPI_SWD.new(
		memory_start_address: "0x08000000",
		memory_size_address: 	"0x1FFFF7E0",
		cpu_id_address:				"0xE000ED00",
		device_id_address:		"0x1FFFF7E8"
	)

	#TO OBTAIN ID CODE
	code = swd.obtainCodes
	puts "DP.IDCODE: #{code[:DebugPortId].to_s(16)} "
	puts "AP.IDCODE: #{code[:AccessPortId].to_s(16)} "

	if ARGV[0] == nil
		puts "Write firmware command but path of file not founded"
	else
		# ERASE FLASH !!!!!!!!!!  AND WRITE THE CONTENT OF THE FILE ON THE FLASH
		puts "Begin of write"
		swd.writeFlash(ARGV[0])
		puts "Write finished"
	end

	rescue HardsploitAPI::ERROR::HARDSPLOIT_NOT_FOUND
		puts "Hardsploit not found"
	rescue HardsploitAPI::ERROR::USB_ERROR
		puts "USB ERRROR"
end
