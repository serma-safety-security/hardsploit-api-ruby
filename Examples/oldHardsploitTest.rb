#!/usr/bin/ruby
#===================================================
#  Hardsploit API - By Opale Security
#  www.opale-security.com || www.hardsploit.io
#  License: GNU General Public License v3
#  License URI: http://www.gnu.org/licenses/gpl.txt
#===================================================

require_relative 'HardsploitAPI/HardsploitAPI'
require 'io/console'
val =0;
#$file_test = File.open("Flash2.bin","wb")
def callbackInfo(receiveData)
	print receiveData  + "\n"
end

def callbackData(receiveData)
	if receiveData != nil then
			puts "received #{receiveData.size}"
			$file_test.write(receiveData.pack("c*"))
	  	#p receiveData

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

HardAPI = HardsploitAPI.new(method(:callbackData),method(:callbackInfo),method(:callbackProgress),method(:callbackSpeedOfTransfert))

case HardAPI.connect
	when HardsploitAPI::USB_STATE::NOT_CONNECTED
		puts "Hardsploit not found"
	when HardsploitAPI::USB_STATE::UNKNOWN_CONNECTED
		puts "Hardsploit not found  maybe BUSY or a device with the same IdVendor and IdProduct was found"
	when HardsploitAPI::USB_STATE::CONNECTED
		puts "Hardsploit found #{HardAPI.getVersionNumber}\n"
		puts "API VERSION : #{HardsploitAPI::VERSION::API}\n"
	else
		puts "UNKNOWN STATE OF HARDSPLOIT"
end


def check_SendAndReceivedData(value)
	case value
		when HardsploitAPI::USB_STATE::PACKET_IS_TOO_LARGE
			puts "PACKET_IS_TOO_LARGE max: #{HardsploitAPI::USB::USB_TRAME_SIZE}"
		when HardsploitAPI::USB_STATE::ERROR_SEND
			puts "ERROR_SEND\n"
		when HardsploitAPI::USB_STATE::BUSY
			puts "BUSY"
		when HardsploitAPI::USB_STATE::TIMEOUT_RECEIVE
			puts "TIMEOUT_RECEIVE\n"
		else
			puts "Received Size: #{value.size}"
			p value
	end
end


def check_ReceivedData
	result = HardAPI.receiveDATA(2000)
	case result
		when HardsploitAPI::USB_STATE::BUSY
			puts "BUSY"
		when HardsploitAPI::USB_STATE::TIMEOUT_RECEIVE
			puts "TIMEOUT_RECEIVE\n"
		else
			puts "Received"
			p result
	end
end

def check_SendData( value)
	case value
		when HardsploitAPI::USB_STATE::SUCCESSFUL_SEND
			puts "SUCCESSFUL_SEND"
		when HardsploitAPI::USB_STATE::PACKET_IS_TOO_LARGE
			puts "PACKET_IS_TOO_LARGE max: #{USB::USB_TRAME_SIZE}"
		when HardsploitAPI::USB_STATE::ERROR_SEND
			puts "ERROR_SEND\n"
		else
			puts "UNKNOWN SEND STATE"
	end
end



while true

	char = STDIN.getch
	puts char
	if char ==  "\u0003"
		puts "Finished"
		exit
	elsif  char  == "1" then
	#	p HardAPI.test_InteractWrite(0x00FF00FF00FF00FF)
		print "Upload Firmware  check : #{HardAPI.uploadFirmware(File.expand_path(File.dirname(__FILE__)) +  "/../HARDSPLOIT-VHDL/Firmware/FPGA/TEST/TEST_INTERACT/HARDSPLOIT_FIRMWARE_FPGA_TEST_INTERACT.rpd",false)}\n"
		puts "Date of firmware #{File.new(File.expand_path(File.dirname(__FILE__)) +  "/../HARDSPLOIT-VHDL/Firmware/FPGA/TEST/TEST_INTERACT/HARDSPLOIT_FIRMWARE_FPGA_TEST_INTERACT.rpd").mtime}"


	elsif  char  == "2" then
		#p HardAPI.test_InteractWrite(0)

	#	check_SendData(HardAPI.setWiringLeds(0))
	#	puts HardAPI.test_InteractWrite(0).to_s(16)

		#puts HardAPI.test_InteractWrite(~(2**56)).to_s(16)


 #puts HardAPI.test_InteractRead.to_s(16)
		#puts HardAPI.test_InteractRead.to_s(16)
		puts HardAPI.test_InteractRead.to_s(2).rjust(64, '0')
#puts HardAPI.test_InteractRead.to_s(16)

	elsif  char  == "3" then
		cpt=1
	while 1
			#p cpt
		#	puts HardAPI.test_InteractRead.to_s(16)


				#puts HardAPI.test_InteractWrite(0xFF00FF00FF00FF12).to_s(16)
		    #	p HardAPI.test_InteractWrite(0xFFFFFFFFFFFFFFFF)
		  	#puts HardAPI.test_InteractRead.to_s(16)
				puts HardAPI.test_InteractRead.to_s(2).rjust(64, '0')

			sleep(0.1)
			cpt = cpt +1
		end

	elsif  char  == "4" then
		puts "HARDWARE & SOFTWARE VERSION OF THE BOARD : #{HardAPI.getVersionNumber}"
	elsif  char  == "5" then
			p HardAPI.getSerialNumber

	elsif  char  == "y" then
		if  HardAPI.isBoardConnected? then
			p "Connected"
		else
			p "Unconnected"
		end

	elsif  char  == "o" then
		HardAPI.startFPGA
	elsif  char  == "p" then
		HardAPI.stopFPGA
	elsif  char  == "a" then
			puts "dfeoo"
		 check_SendData(HardAPI.setStatutLed(HardsploitAPI::USB_COMMAND::LED1,true) )
	elsif  char  == "z" then
		 check_SendData(HardAPI.setStatutLed(HardsploitAPI::USB_COMMAND::LED1,false))
	elsif  char  == "e" then
		 check_SendAndReceivedData(HardAPI.testLoopBack)
	elsif  char  == "b" then
		check_SendData(HardAPI.setWiringLeds(0xFFFFFFFFFFFFFFFF))

	elsif  char  == "c" then
		check_SendData(HardAPI.setWiringLeds(0xFF00FF00FF00FF00))
		crossvalue = Array.new
		for i in 0..63
			crossvalue.push i
		end
		#swap 2 first signal
		crossvalue[0] = 63
		crossvalue[63] = 0
		HardAPI.setCrossWiring(crossvalue)


	elsif  char  == "v" then
		check_SendData(HardAPI.setWiringLeds(0x00FF00FF00FF00FF))
		crossvalue = Array.new
		for i in 0..63
			crossvalue.push i
		end
		#swap 2 first signal
		crossvalue[0] = 0
		crossvalue[1] = 1
		HardAPI.setCrossWiring(crossvalue)


	elsif  char  == "u" then

		#I2C EEPROM example
	#HardAPI.i2c_Generic_Import(speed:HardsploitAPI::I2C::KHZ_100,i2cBaseAddress:0xA0,startAddress:0x00,pageSize:32,memorySize:64000,dataFile:"EEPROM.bin",writePageLatency:0.003)
	#HardAPI.i2c_Generic_Dump 0,0xA0,0,81920-1,81920
	#HardAPI.i2c_Generic_Dump 0,0xA0,0,7984-1,81920

		#Flash example

		#SPI FLASH 25P40 4Mb (2048 x 256 x 8 )
		#75 MHz max,  speed =  150Mhz / (2*frequency) = 150/(2*3) = 25Mhz
		#256 byte page (2048 pages)
		#Page program in 0.8ms
		#Bulk erase: 4Mb in 4.5 s (TYP)
	#	HardAPI.spi_Generic_Import(mode:0,speed:3,startAddress:0,pageSize:256,memorySize:524288,dataFile:"Flash.bin",writeSpiCommand:0x02,writePageLatency:0.008,enableWriteSpiCommand:0x06,clearSpiCommand:0xFF,clearChipTime:5,isFLASH:TRUE)


		#SPI EEPROM 25LC080  8Kb (1024 x 8)
		#2Mhz max,  speed =  150Mhz / (2*frequency) = 150/(2*2) = 37,5 = 38, check to be sure : 150/(2*38) = 1,97 Mhz perfect less than 2Mhz !
		#1024 x 8-bit organization
		#16 byte page (64 pages)
		#Page programm : 5 ms max.
		#clearSpiCommand not used in case of EEPROM
		#HardAPI.spi_Generic_Import(mode:0,speed:38,startAddress:0,pageSize:16,memorySize:1024,dataFile:"Flash.bin",writeSpiCommand:0x02,writePageLatency:0.005,enableWriteSpiCommand:0x06,clearSpiCommand:0xC7,clearChipTime:1,isFLASH:FALSE)


		#Generic dump of 1024Bytes spi memory
#		HardAPI.spi_Generic_Dump(mode:0,speed:40,readSpiCommand:0x03,startAddress:0,stopAddress:1024-1,sizeMax:1024)

 	#HardAPI.spi_Generic_Dump(mode:0,speed:40,readSpiCommand:0x03,startAddress:0,stopAddress:524288-1,sizeMax:524288)


	# crossvalue = Array.new
	# for i in 0..63
	# 	crossvalue.push i
	# end
	# #swap 2 first signal
	# crossvalue[0] = 1
	# crossvalue[1] = 0
	# HardAPI.setCrossWiring(crossvalue)


	elsif  char  == "i" then
		#speed = 2 ->37.5Mhz
		#speed = 3 ->25Mhz
		testpack = Array.new
		testpack.push 0x9F
		for i in 1..20
			testpack.push 0
		end

		check_SendAndReceivedData(HardAPI.spi_Interact(0,5,testpack))

	elsif  char  == "F" then
		#HardAPI.writeBufferToMemory(0x00)

		#p HardAPI.readManufactuerCodeMemory
		#p HardAPI.readDeviceIdMemory
		#HardAPI.eraseTwoFirstPages

		#HardAPI.eraseBlockMemory(0x0000000000000000)
		#HardAPI.writePage(0x0000000000000000)
		#HardAPI.writeBufferToMemory(0x00)

		#HardAPI.unlockBlock(0x00)

		#HardAPI.writePage(0x00)

		#  for r in 0..10000
		# 	 HardAPI.read_Memory_WithoutMultiplexing(0,5,1,1000)
  	#  end

		#p HardAPI.readByteFromMemory(0,5)
		#HardAPI.writeByteToMemory(0x10,0x1234)
		# p HardAPI.write_command_Memory_WithoutMultiplexing(0x000000,0x90) #ReadDeviceIdentifierCommand


		#p HardAPI.readByteFromMemory(0,0)
		#sleep(1)
		#p readByteFromMemory(1,1) #Read from 1 to 1 = read 1 byte at 1

		#p HardAPI.readDeviceIdMemory
	elsif  char  == "D" then
		HardAPI.runSWD  #MUST BE CALL FIRST

		#TO OBTAIN ID CODE
		code = HardAPI.obtainCodes
		puts "DP.IDCODE: #{code[:DebugPortId].to_s(16)} "
		puts "AP.IDCODE: #{code[:AccessPortId].to_s(16)} "
		puts "CPU ID : #{code[:CpuId].to_s(16)} "
		puts "DEVICE ID : #{code[:DeviceId].to_s(16)}"


		# ERASE FLASH !!!!!!!!!!  AND WRITE THE CONTENT OF THE FILE ON THE FLASH
		#HardAPI.writeFlash('/mnt/hgfs/GIT_OPALE/HARDSPLOIT-API-RUBY/FirmwareStLink.bin')

		# ERASE FLASH
		#HardAPI.flashErase

		#TO DUMP FLASH
		#HardAPI.dumpFlash('/mnt/hgfs/GIT_OPALE/HARDSPLOIT-API-RUBY/dumdp.bin')


	elsif  char  == "7" then
		puts "dump"
		#TO DUMP FLASH
		HardAPI.dumpFlash('/mnt/hgfs/GIT_OPALE/HARDSPLOIT-API-RUBY/dumdp.bin')

	elsif  char  == "8" then
		puts "write"
		# ERASE FLASH !!!!!!!!!!  AND WRITE THE CONTENT OF THE FILE ON THE FLASH
		HardAPI.writeFlash('/mnt/hgfs/GIT_OPALE/HARDSPLOIT-API-RUBY/FirmwareStLink.bin')

	elsif  char  == "9" then
		puts "unhalt"
 		HardAPI.stm32.unhalt
	elsif  char  == "d" then
		#upload without check (faster)
		#print "Upload Firmware  check : #{HardAPI.uploadFirmware(File.expand_path(File.dirname(__FILE__)) +  "/../HARDSPLOIT-VHDL/Firmware/FPGA/SPI/SPI_INTERACT/HARDSPLOIT_FIRMWARE_FPGA_SPI_INTERACT.rpd",false)}\n"
		#print "Upload Firmware  check : #{HardAPI.uploadFirmware(File.expand_path(File.dirname(__FILE__)) +  "/../HARDSPLOIT-VHDL/Firmware/FPGA/I2C/I2C_INTERACT/HARDSPLOIT_FIRMWARE_FPGA_I2C_INTERACT.rpd",true)}\n"
    #print "Upload Firmware  check : #{HardAPI.uploadFirmware(File.expand_path(File.dirname(__FILE__)) +  "/../HARDSPLOIT-VHDL/Firmware/FPGA/TEST/TEST_INTERACT/HARDSPLOIT_FIRMWARE_FPGA_TEST_INTERACT.rpd",true)}\n"
		#print "Upload Firmware  check : #{HardAPI.uploadFirmware(File.expand_path(File.dirname(__FILE__)) +  "/../HARDSPLOIT-VHDL/Firmware/FPGA/SWD/SWD_INTERACT/HARDSPLOIT_FIRMWARE_FPGA_SWD_INTERACT.rpd",false)}\n"
	  #print "Upload Firmware  check : #{HardAPI.uploadFirmware(File.expand_path(File.dirname(__FILE__)) +  "/../HARDSPLOIT-VHDL/Firmware/FPGA/PARALLEL/NO_MUX_PARALLEL_MEMORY/HARDSPLOIT_FIRMWARE_FPGA_NO_MUX_PARALLEL_MEMORY.rpd",false)}\n"
		print "Upload Firmware  check : #{HardAPI.uploadFirmware(File.expand_path(File.dirname(__FILE__)) +  "/../HARDSPLOIT-VHDL/Firmware/FPGA/UART/UART_INTERACT/HARDSPLOIT_FIRMWARE_FPGA_UART_INTERACT.rpd",false)}\n"


		#sleep(2)
		#Mode 0
		#Speed =3
		#Spi read command by default 0x03
		#start at 0
		#stop at 5000
		#size max in BYTE  8000 bytes = 8000*8 = 64000 bits = 64Kb memory
		#HardAPI.spi_Generic_Dump  0,3,0x03,0,250000,512000

		#HardAPI.i2c_Generic_Dump 0,0xA0,0,1000,8192

	elsif  char  == "n" then
		#HardsploitAPI::I2C::KHZ_100
		#HardsploitAPI::I2C::KHZ_400
		#HardsploitAPI::I2C::KHZ_1000

		#SizeH SizeL address(read or write) dataN

		testpack = Array.new
		#We want to write 2 bytes


		#Write 4 bytes at 0x00 0x00
		# testpack.push HardAPI.lowByte(4)  #Count Low  Byte
		# testpack.push HardAPI.highByte(4)   #Count High Byte
		# testpack.push 0xA0
		# testpack.push 41  #First data byte
		# testpack.push 42  #Second data byte
		# testpack.push 43
		# testpack.push 44


		#Write pointer of I2C memorie at 0x00 0x00
		testpack.push HardAPI.lowByte(2)  #Count Low  Byte
		testpack.push HardAPI.highByte(2)   #Count High Byte
		testpack.push 0xA0
		testpack.push 0x00
		testpack.push 0x00


		#read 4 bytes
		testpack.push HardAPI.lowByte(4)  #Count Low  Byte
		testpack.push HardAPI.highByte(4)   #Count High Byte
		testpack.push 0xA1



		#testpack.push HardAPI.lowByte(4)  #Count Low Byte
		#testpack.push HardAPI.highByte(4)   #Count High  Byte
		#testpack.push 0xA1


		check_SendAndReceivedData(HardAPI.i2c_Interact(HardsploitAPI::I2C::KHZ_100,testpack))

	elsif  char  == "m" then
		scan_result = HardAPI.i2c_Scan(HardsploitAPI::I2C::KHZ_100)

		#check parity of array index to know if a Read or Write address
		# Index 0 is write address because is is even
		# Index 1 is read address because it is  odd

		# Index 160 (0xA0) is write address because is is even
		# Index 161 (0xA1) is read address because is is odd

		#If value is 0 slave address is not available
		#If valude is 1 slave address is available

		for i in (0..scan_result.size-1) do
			puts " #{(i).to_s(16)} #{scan_result[i]}"
		end

elsif char == "+" then
	puts "Manufactuer Code : #{HardAPI.readManufactuerCodeMemory.to_s(16)}"
	puts "Device Memory Id : #{HardAPI.readDeviceIdMemory.to_s(16)}"

	#puts "UNLOCK BLOCK 0"
	puts HardAPI.unlockBlock(0)

	#puts "ERASE"
	puts HardAPI.eraseBlockMemory(0)

	saved_value =  "OPALE SECURITY 32C3"

 for i in (0..saved_value.size-1) do
  	puts "Write :#{saved_value[i]} Statut : #{HardAPI.writeByteToMemory(i,saved_value[i].ord)}"
 end

 puts "READ MODE"
 HardAPI.readMode

	#Dump  parallele 8 bits at 100ns for latency
	elsif  char  == "g" then
		time = Time.new
		#4194304
		dump_size =17200
		HardAPI.read_Memory_WithoutMultiplexing(0,dump_size-1,true,1600 ) # true = 8 bits 1600ns latency
		time = Time.new - time
		puts "DUMP #{((dump_size/time)).round(2)}Bytes/s #{(dump_size)}Bytes in #{time.round(4)} s"

	#Dump  parallele 16 bits at 100ns for latency
	elsif  char  == "h" then
	#	puts "Manufactuer Code : #{HardAPI.readManufactuerCodeMemory.to_s(16)}"
	#	puts "Device Memory Id : #{HardAPI.readDeviceIdMemory.to_s(16)}"
	#	HardAPI.readMode
		time = Time.new
		dump_size  = 40000
		HardAPI.read_Memory_WithoutMultiplexing(0,dump_size-1,false,1600)   #false = 16 bits  1600ns latency
		time = Time.new - time
		puts "DUMP #{((2*(dump_size)/(1024*time))).round(2)}KBytes/s   #{(2*dump_size)}Bytes in  #{time.round(4)} s"
	end
end
