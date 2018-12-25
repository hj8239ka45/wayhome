#include "C:\Users\hj823\Desktop\test\OM-test7-1\OM-test7-1\RC522.h"

void RC522_Init(void){
	RC522_WriteRegister(TxModeReg,0x00);
	RC522_WriteRegister(RxModeReg,0x00);
	// Reset baud rates
	RC522_WriteRegister(ModWidthReg,0x26);
	// Reset ModWidthReg
	// When communicating with a PICC we need a timeout if something goes wrong.
	// f_timer = 13.56 MHz / (2*TPreScaler+1) where TPreScaler = [TPrescaler_Hi:TPrescaler_Lo].
	// TPrescaler_Hi are the four low bits in TModeReg. TPrescaler_Lo is TPrescalerReg.
	RC522_WriteRegister(TModeReg,0x80);
	// TAuto=1; timer starts automatically at the end of the transmission in all communication modes at all speeds
	RC522_WriteRegister(TPrescalerReg, 0xA9);
	// TPreScaler = TModeReg[3..0]:TPrescalerReg, ie 0x0A9 = 169 => f_timer=40kHz, ie a timer period of 25μs.
	RC522_WriteRegister(TReloadRegH,0x03);
	RC522_WriteRegister(TReloadRegL,0xE8);
	// Reload timer with 0x3E8 = 1000, ie 25ms before timeout.
	RC522_WriteRegister(TxASKReg,0x40);
	// Default 0x00. Force a 100 % ASK modulation independent of the ModGsPReg register setting
	RC522_WriteRegister(ModeReg,0x3D);
	// Default 0x3F. Set the preset value for the CRC coprocessor for the CalcCRC command to 0x6363 (ISO 14443-3 part 6.2.4)
	RC522_AntennaOn();						// Enable the an1tenna driver pins TX1 and TX2 (they were disabled by the reset)
}

char RC522_ReadRegister(char reg){
	char temp;
	SPI_CSL();
	SPI_swap(0x80|reg);
	temp = SPI_swap(0);
	SPI_CSH();
	return temp;
}

void RC522_ReadRegister_Bytes(char reg ,char Bytes ,char* data_p ,char rxAlign){
	char index = 0;
	SPI_CSL();
	SPI_swap(0x80|reg);					// One read is performed outside of the loop
	if (rxAlign) {		// Only update bit positions rxAlign..7 in values[0]
		// Create bit mask for bit positions rxAlign..7
		char mask = (0xFF << rxAlign) & 0xFF;
		// Read value and tell that we want to read the same address again.
		char value = SPI_swap(0x80|reg);
		// Apply mask to both current value of values[0] and the new data in value.
		*(data_p+0) = (*(data_p+0) & ~mask) | (value & mask);
		index++;
	}
	while (index < (Bytes-1)) {
		*(data_p+index) = SPI_swap(0x80|reg);	// Read value and tell that we want to read the same address again.
		index++;
	}
	*(data_p+index) = SPI_swap(0);			// Read the final byte. Send 0 to stop reading.
	SPI_CSH();
}

void RC522_WriteRegister(char reg ,char data){
	SPI_CSL();
	SPI_swap(reg);
	SPI_swap(data);
	SPI_CSH();
}

void RC522_WriteRegister_Bytes(char reg ,char Bytes ,char* data_p){
	SPI_CSL();
	SPI_swap(reg);
	for (int i = 0; i < Bytes; i++) {
		SPI_swap(*(data_p+i));
	}
	SPI_CSH();
}

void RC522_AntennaOn(void){
	char data;
	data = RC522_ReadRegister(TxControlReg);
	if((data&0x03)!=0x03){
		data=data|0x03;
		RC522_WriteRegister(TxControlReg ,data);
	}
}

void RC522_AntennaOff(void){
	char data;
	data = RC522_ReadRegister(TxControlReg);
	data=data&(~(0x03));
	RC522_WriteRegister(TxControlReg ,data);
}

char RC522_CalculateCRC( char *data, char length,char *result) {
	RC522_WriteRegister(CommandReg, PCD_Idle);		// Stop any active command.
	RC522_WriteRegister(DivIrqReg, 0x04);				// Clear the CRCIRq interrupt request bit
	RC522_WriteRegister(FIFOLevelReg, 0x80);			// FlushBuffer = 1, FIFO initialization
	RC522_WriteRegister_Bytes(FIFODataReg, length, data);	// Write data to the FIFO
	RC522_WriteRegister(CommandReg, PCD_CalcCRC);		// Start the calculation

   // Wait for the CRC calculation to complete. Each iteration of the while-loop takes 17.73μs.
   // TODO check/modify for other architectures than Arduino Uno 16bit

   // Wait for the CRC calculation to complete. Each iteration of the while-loop takes 17.73us.
	for (int i = 5000; i > 0; i--) {
	   // DivIrqReg[7..0] bits are: Set2 reserved reserved MfinActIRq reserved CRCIRq reserved reserved
	   char n = RC522_ReadRegister(DivIrqReg);
	 	if (n & 0x04) {									// CRCIRq bit set - calculation done
			RC522_WriteRegister(CommandReg, PCD_Idle);	// Stop calculating CRC for new content in the FIFO.
			// Transfer the result from the registers to the result buffer
			*result = RC522_ReadRegister(CRCResultRegL);
			*(result+1) = RC522_ReadRegister(CRCResultRegH);
			return STATUS_OK;
		}
	}
	// 89ms passed and nothing happend. Communication with the MFRC522 might be down.
	return STATUS_TIMEOUT;
} // End PCD_CalculateCRC()

char RC522_CommunicateWithFIFO(char command ,char waitIRq ,char* sendData_p ,char sendDataBytes ,
						char* receiveData_p ,char* receiveDataBytes_p ,char* validBits ,char rxAlign ,
						char checkCRC){
	char txLastBits;
	if( validBits==0 ){ txLastBits = 0; }
	else{ txLastBits = *validBits; }
	char BitFraming;
	BitFraming = (rxAlign << 4) + txLastBits;
	RC522_WriteRegister(CommandReg, PCD_Idle);			// Stop any active command.
	RC522_WriteRegister(ComIrqReg, 0x7F);					// Clear all seven interrupt request bits
	RC522_WriteRegister(FIFOLevelReg, 0x80);				// FlushBuffer = 1, FIFO initialization
	RC522_WriteRegister_Bytes(FIFODataReg, sendDataBytes, sendData_p);	// Write sendData to the FIFO
	RC522_WriteRegister(BitFramingReg, BitFraming);		// Bit adjustments
	RC522_WriteRegister(CommandReg, command);				// Execute the command
	if (command == PCD_Transceive) {
		char temp;
		temp = RC522_ReadRegister(BitFramingReg);
		RC522_WriteRegister(BitFramingReg, temp|0x80);
		// StartSend=1, transmission of data starts
	}
	// Wait for the command to complete.
	// In PCD_Init() we set the TAuto flag in TModeReg. This means the timer automatically starts when the PCD stops transmitting.
	// Each iteration of the do-while-loop takes 17.86μs.
	// TODO check/modify for other architectures than Arduino Uno 16bit
	int i;
	for (i = 2000; i > 0; i--) {
		char n = RC522_ReadRegister(ComIrqReg);	// ComIrqReg[7..0] bits are: Set1 TxIRq RxIRq IdleIRq HiAlertIRq LoAlertIRq ErrIRq TimerIRq
		if (n & waitIRq) {					// One of the interrupts that signal success has been set.
			break;
		}
		if (n & 0x01) {						// Timer interrupt - nothing received in 25ms
			return STATUS_TIMEOUT;
		}
	}
	// 35.7ms and nothing happend. Communication with the MFRC522 might be down.
	if (i == 0) {
		return STATUS_TIMEOUT;
	}
	// Stop now if any errors except collisions were detected.
	char errorRegValue = RC522_ReadRegister(ErrorReg); // ErrorReg[7..0] bits are: WrErr TempErr reserved BufferOvfl CollErr CRCErr ParityErr ProtocolErr
	if (errorRegValue & 0x13) {	 // BufferOvfl ParityErr ProtocolErr
		return STATUS_ERROR;
	}

	char _validBits = 0;
	// If the caller wants data back, get it from the MFRC522.
	if (receiveData_p && receiveDataBytes_p) {
		char n = RC522_ReadRegister(FIFOLevelReg);	// Number of bytes in the FIFO
		if (n > *receiveDataBytes_p) {
			return STATUS_NO_ROOM;
		}
		*receiveDataBytes_p = n;											// Number of bytes returned
		RC522_ReadRegister_Bytes(FIFODataReg, n, receiveData_p, rxAlign);	// Get received data from FIFO
		_validBits = RC522_ReadRegister(ControlReg) & 0x07;		// RxLastBits[2:0] indicates the number of valid bits in the last received byte. If this value is 000b, the whole byte is valid.
		if (validBits) {
			*validBits = _validBits;
		}
	}

	// Tell about collisions
	if (errorRegValue & 0x08) {		// CollErr
		return STATUS_COLLISION;
	}

	// Perform CRC_A validation if requested.
	if (receiveData_p && receiveDataBytes_p && checkCRC) {
		// In this case a MIFARE Classic NAK is not OK.
		if (*receiveDataBytes_p == 1 && _validBits == 4) {
			return STATUS_MIFARE_NACK;
		}
		// We need at least the CRC_A value and all 8 bits of the last byte must be received.
		if (*receiveDataBytes_p < 2 || _validBits != 0) {
			return STATUS_CRC_WRONG;
		}
		// Verify CRC_A - do our own calculation and store the control in controlBuffer.
		char controlBuffer[2];
		char status;
		status = RC522_CalculateCRC(receiveData_p, *receiveDataBytes_p-2, controlBuffer);
		if (status != STATUS_OK) {
			return status;
		}
		if ((receiveData_p[*receiveDataBytes_p - 2] != controlBuffer[0]) || (receiveData_p[*receiveDataBytes_p - 1] != controlBuffer[1])) {
			return STATUS_CRC_WRONG;
		}
	}

	return STATUS_OK;
}

char RC522_CMD_REQAorWUPA(char command ,char* bufferATQA,char buffersize){
	char temp;
	char status;
	if (bufferATQA == 0 || buffersize < 2) {	// The ATQA response is 2 bytes long.
		return STATUS_NO_ROOM;
	}
	// ValuesAfterColl=1 => Bits received after collision are cleared.
	temp = RC522_ReadRegister(CollReg);
	temp = temp&(~0x80);
	RC522_WriteRegister(CollReg ,temp);
	char validBits = 7;			// For REQA and WUPA we need the short frame format - transmit only 7 bits of the last (and only) byte. TxLastBits = BitFramingReg[2..0]
	char waitIRq = 0x30;		// RxIRq and IdleIRq
	status = RC522_CommunicateWithFIFO(PCD_Transceive, waitIRq, &command, 1, bufferATQA, &buffersize, &validBits, 0, 0);
	if (status != STATUS_OK) {
		return status;
	}
	if (buffersize != 2 || validBits != 0) {		// ATQA must be exactly 16 bits.
		return STATUS_ERROR;
	}
	return STATUS_OK;
}

char RC522_HaltA(void) {
	char result;
	char buffer[4];

	// Build command buffer
	buffer[0] = PICC_CMD_HLTA;
	buffer[1] = 0;
	// Calculate CRC_A
	result = RC522_CalculateCRC(buffer, 2, &buffer[2]);
	if (result != STATUS_OK) {
		return result;
	}
	return STATUS_OK;
}

char RC522_Authenticate(char command,	char blockAddr,	char* key, Uid *uid) {
	// Build command buffer
	char sendData[12];
	sendData[0] = command;
	sendData[1] = blockAddr;
	for (int i = 0; i < MF_KEY_SIZE; i++) {	// 6 key bytes
		sendData[2+i] = key[i];
	}
	// Use the last uid bytes as specified in http://cache.nxp.com/documents/application_note/AN10927.pdf
	// section 3.2.5 "MIFARE Classic Authentication".
	// The only missed case is the MF1Sxxxx shortcut activation,
	// but it requires cascade tag (CT) byte, that is not part of uid.
	for (int i = 0; i < 4; i++) {				// The last 4 bytes of the UID
		sendData[8+i] = uid->uidByte[i+uid->size-4];
	}
	// Start the authentication.
	char waitIRq = 0x10;		// IdleIRq
	return RC522_CommunicateWithFIFO(PCD_MFAuthent, waitIRq, &sendData[0], sizeof(sendData),0,0,0,0,0);
} // End PCD_Authenticate()

/**
 * Used to exit the PCD from its authenticated state.
 * Remember to call this function after communicating with an authenticated PICC - otherwise no new communications can start.
 */
void RC522_StopCrypto1(void) {
	// Clear MFCrypto1On bit
	char temp;
	temp = RC522_ReadRegister(Status2Reg);
	temp=temp&(~0x08);
	RC522_WriteRegister(Status2Reg , temp);
	// Status2Reg[7..0] bits are: TempSensClear I2CForceHS reserved reserved MFCrypto1On ModemState[2:0]
} // End PCD_StopCrypto1()

char RC522_MIFARE_Read(char blockAddr,	char *buffer, char bufferSize ) {
	char result;
	// Sanity check
	if (buffer == 0 || bufferSize < 18) {
		return STATUS_NO_ROOM;
	}

	// Build command buffer
	buffer[0] = PICC_CMD_MF_READ;
	buffer[1] = blockAddr;
	// Calculate CRC_A
	result = RC522_CalculateCRC(buffer, 2, &buffer[2]);
	if (result != STATUS_OK) {
		return result;
	}
	// Transmit the buffer and receive the response, validate CRC_A.
	char waitIRq = 0x30;		// RxIRq and IdleIRq
	return RC522_CommunicateWithFIFO(PCD_Transceive ,waitIRq ,buffer ,4 ,buffer ,&bufferSize ,0 ,0 , 1);
} // End MIFARE_Read()

char RC522_MIFARE_Transceive(char *sendData,	char sendLen,char acceptTimeout) {
	char result;
	char cmdBuffer[18]; // We need room for 16 bytes data and 2 bytes CRC_A.

	// Sanity check
	if (sendData == 0 || sendLen > 16) {
		return STATUS_INVALID;
	}

	// Copy sendData[] to cmdBuffer[] and add CRC_A
	for(int i=0; i<sendLen; i++){
		cmdBuffer[i]=*(sendData+i);
	}
	result = RC522_CalculateCRC(cmdBuffer, sendLen, cmdBuffer+sendLen);
	if (result != STATUS_OK) {
		return result;
	}
	sendLen = sendLen + 2;

	// Transceive the data, store the reply in cmdBuffer[]
	char waitIRq = 0x30;		// RxIRq and IdleIRq
	char cmdBufferSize = sizeof(cmdBuffer);
	char validBits = 0;
	result = RC522_CommunicateWithFIFO(PCD_Transceive, waitIRq, cmdBuffer, sendLen, cmdBuffer, &cmdBufferSize, &validBits,0,0);
	if (acceptTimeout && result == STATUS_TIMEOUT) {
		return STATUS_OK;
	}
	if (result != STATUS_OK) {
		return result;
	}
	// The PICC must reply with a 4 bit ACK
	if (cmdBufferSize != 1 || validBits != 4) {
		return STATUS_ERROR;
	}
	if (cmdBuffer[0] != MF_ACK) {
		return STATUS_MIFARE_NACK;
	}
	return STATUS_OK;
} // End PCD_MIFARE_Transceive()

char RC522_MIFARE_Write(char blockAddr,	char *buffer, char bufferSize){
	char result;

	// Sanity check
	if (buffer == 0 || bufferSize < 16) {
		return STATUS_INVALID;
	}

	// Mifare Classic protocol requires two communications to perform a write.
	// Step 1: Tell the PICC we want to write to block blockAddr.
	char cmdBuffer[2];
	cmdBuffer[0] = PICC_CMD_MF_WRITE;
	cmdBuffer[1] = blockAddr;
	result = RC522_MIFARE_Transceive(cmdBuffer,2,0);
	// Adds CRC_A and checks that the response is MF_ACK.
	if (result != STATUS_OK) {
		return result;
	}

	// Step 2: Transfer the data
	result =  RC522_MIFARE_Transceive(buffer,bufferSize,0);
	// Adds CRC_A and checks that the response is MF_ACK.
	if (result != STATUS_OK) {
		return result;
	}

	return STATUS_OK;
} // End MIFARE_Write()

char RC522_CardSelect(Uid* uid, char validBits){
	char uidComplete;
	char selectDone;
	char useCascadeTag;
	char cascadeLevel = 1;
	char result;
	char count;
	int index;
	char uidIndex;					// The first index in uid->uidByte[] that is used in the current Cascade Level.
	int currentLevelKnownBits;		// The number of known UID bits in the current Cascade Level.
	char buffer[9];					// The SELECT/ANTICOLLISION commands uses a 7 byte standard frame + 2 bytes CRC_A
	char bufferUsed;				// The number of bytes used in the buffer, ie the number of bytes to transfer to the FIFO.
	char rxAlign;					// Used in BitFramingReg. Defines the bit position for the first bit received.
	char txLastBits;				// Used in BitFramingReg. The number of valid bits in the last transmitted byte.
	char *responseBuffer;
	char responseLength;

	// Description of buffer structure:
	//		Byte 0: SEL 				Indicates the Cascade Level: PICC_CMD_SEL_CL1, PICC_CMD_SEL_CL2 or PICC_CMD_SEL_CL3
	//		Byte 1: NVB					Number of Valid Bits (in complete command, not just the UID): High nibble: complete bytes, Low nibble: Extra bits.
	//		Byte 2: UID-data or CT		See explanation below. CT means Cascade Tag.
	//		Byte 3: UID-data
	//		Byte 4: UID-data
	//		Byte 5: UID-data
	//		Byte 6: BCC					Block Check Character - XOR of bytes 2-5
	//		Byte 7: CRC_A
	//		Byte 8: CRC_A
	// The BCC and CRC_A are only transmitted if we know all the UID bits of the current Cascade Level.
	//
	// Description of bytes 2-5: (Section 6.5.4 of the ISO/IEC 14443-3 draft: UID contents and cascade levels)
	//		UID size	Cascade level	Byte2	Byte3	Byte4	Byte5
	//		========	=============	=====	=====	=====	=====
	//		 4 bytes		1			uid0	uid1	uid2	uid3
	//		 7 bytes		1			CT		uid0	uid1	uid2
	//						2			uid3	uid4	uid5	uid6
	//		10 bytes		1			CT		uid0	uid1	uid2
	//						2			CT		uid3	uid4	uid5
	//						3			uid6	uid7	uid8	uid9
	// Sanity checks

	if (validBits > 80) {
		return STATUS_INVALID;
	}
	// Prepare MFRC522
	char temp;
	temp = RC522_ReadRegister(CollReg);
	temp = temp&(~0x80);
	RC522_WriteRegister(CollReg ,temp);
	// ValuesAfterColl=1 => Bits received after collision are cleared.
	uidComplete = 0;
	while (uidComplete==0) {
		// Set the Cascade Level in the SEL byte, find out if we need to use the Cascade Tag in byte 2.
		switch (cascadeLevel) {
			case 1:
				buffer[0] = PICC_CMD_SEL_CL1;
				uidIndex = 0;
				useCascadeTag = validBits && (uid->size > 4);	// When we know that the UID has more than 4 bytes
				break;

			case 2:
				buffer[0] = PICC_CMD_SEL_CL2;
				uidIndex = 3;
				useCascadeTag = validBits && (uid->size > 7);	// When we know that the UID has more than 7 bytes
				break;

			case 3:
				buffer[0] = PICC_CMD_SEL_CL3;
				uidIndex = 6;
				useCascadeTag = 0;						// Never used in CL3.
				break;

			default:
				return STATUS_INTERNAL_ERROR;
				break;
		}
		// How many UID bits are known in this Cascade Level?
		currentLevelKnownBits = validBits - (8 * uidIndex);
		if (currentLevelKnownBits < 0) {
			currentLevelKnownBits = 0;
		}
		// Copy the known bits from uid->uidByte[] to buffer[]
		index = 2; // destination index in buffer[]
		if (useCascadeTag) {
			buffer[index++] = PICC_CMD_CT;
		}
		char bytesToCopy = currentLevelKnownBits / 8 + (currentLevelKnownBits % 8 ? 1 : 0); // The number of bytes needed to represent the known bits for this level.
		if (bytesToCopy) {
			char maxBytes = useCascadeTag ? 3 : 4; // Max 4 bytes in each Cascade Level. Only 3 left if we use the Cascade Tag
			if (bytesToCopy > maxBytes) {
				bytesToCopy = maxBytes;
			}
			for (count = 0; count < bytesToCopy; count++) {
				buffer[index++] = uid->uidByte[uidIndex + count];
			}
		}
		// Now that the data has been copied we need to include the 8 bits in CT in currentLevelKnownBits
		if (useCascadeTag) {
			currentLevelKnownBits =currentLevelKnownBits + 8;
		}

		// Repeat anti collision loop until we can transmit all UID bits + BCC and receive a SAK - max 32 iterations.
		selectDone = 0;
		while (!selectDone) {
			// Find out how many bits and bytes to send and receive.
			if (currentLevelKnownBits >= 32) { // All UID bits in this Cascade Level are known. This is a SELECT.
				//Serial.print(F("SELECT: currentLevelKnownBits=")); Serial.println(currentLevelKnownBits, DEC);
				buffer[1] = 0x70; // NVB - Number of Valid Bits: Seven whole bytes
				// Calculate BCC - Block Check Character
				buffer[6] = buffer[2] ^ buffer[3] ^ buffer[4] ^ buffer[5];
				// Calculate CRC_A
				result = RC522_CalculateCRC(buffer, 7, &buffer[7]);
				if (result != STATUS_OK) {
					return result;
				}
				txLastBits		= 0; // 0 => All 8 bits are valid.
				bufferUsed		= 9;
				// Store response in the last 3 bytes of buffer (BCC and CRC_A - not needed after tx)
				responseBuffer	= &buffer[6];
				responseLength	= 3;
			}
			else { // This is an ANTICOLLISION.
				//Serial.print(F("ANTICOLLISION: currentLevelKnownBits=")); Serial.println(currentLevelKnownBits, DEC);
				txLastBits		= currentLevelKnownBits % 8;
				count			= currentLevelKnownBits / 8;	// Number of whole bytes in the UID part.
				index			= 2 + count;					// Number of whole bytes: SEL + NVB + UIDs
				buffer[1]		= (index << 4) + txLastBits;	// NVB - Number of Valid Bits
				bufferUsed		= index + (txLastBits ? 1 : 0);
				// Store response in the unused part of buffer
				responseBuffer	= &buffer[index];
				responseLength	= sizeof(buffer) - index;
			}

			// Set bit adjustments
			rxAlign = txLastBits;											// Having a separate variable is overkill. But it makes the next line easier to read.
			RC522_WriteRegister(BitFramingReg, (rxAlign << 4) + txLastBits);	// RxAlign = BitFramingReg[6..4]. TxLastBits = BitFramingReg[2..0]

			// Transmit the buffer and receive the response.
			char waitIRq = 0x30;
			result = RC522_CommunicateWithFIFO(PCD_Transceive ,waitIRq ,buffer ,bufferUsed ,responseBuffer ,&responseLength ,&txLastBits ,rxAlign, 0);
			if (result == STATUS_COLLISION) { // More than one PICC in the field => collision.
				char valueOfCollReg = RC522_ReadRegister(CollReg); // CollReg[7..0] bits are: ValuesAfterColl reserved CollPosNotValid CollPos[4:0]
				if (valueOfCollReg & 0x20) { // CollPosNotValid
					return STATUS_COLLISION; // Without a valid collision position we cannot continue
				}
				char collisionPos = valueOfCollReg & 0x1F; // Values 0-31, 0 means bit 32.
				if (collisionPos == 0) {
					collisionPos = 32;
				}
				if (collisionPos <= currentLevelKnownBits) { // No progress - should not happen
					return STATUS_INTERNAL_ERROR;
				}
				// Choose the PICC with the bit set.
				currentLevelKnownBits = collisionPos;
				count			= (currentLevelKnownBits - 1) % 8; // The bit to modify
				index			= 1 + (currentLevelKnownBits / 8) + (count ? 1 : 0); // First byte is index 0.
				buffer[index]	|= (1 << count);
			}
			else if (result != STATUS_OK) {
				return result;
			}
			else { // STATUS_OK
				if (currentLevelKnownBits >= 32) { // This was a SELECT.
					selectDone = 1; // No more anticollision
					// We continue below outside the while.
				}
				else { // This was an ANTICOLLISION.
					// We now have all 32 bits of the UID in this Cascade Level
					currentLevelKnownBits = 32;
					// Run loop again to do the SELECT.
				}
			}
		} // End of while (!selectDone)

		// We do not check the CBB - it was constructed by us above.

		// Copy the found UID bytes from buffer[] to uid->uidByte[]
		if(buffer[2] == PICC_CMD_CT){
			index = 3;
			bytesToCopy = 3;
		}
		else{
			index = 2;
			bytesToCopy = 4;
		}
		for (count = 0; count < bytesToCopy; count++) {
			uid->uidByte[uidIndex + count] = buffer[index++];
		}

		// Check response SAK (Select Acknowledge)
		if (responseLength != 3 || txLastBits != 0) { // SAK must be exactly 24 bits (1 byte + CRC_A).
			return STATUS_ERROR;
		}
		// Verify CRC_A - do our own calculation and store the control in buffer[2..3] - those bytes are not needed anymore.
		result = RC522_CalculateCRC(responseBuffer, 1, &buffer[2]);
		if (result != STATUS_OK) {
			return result;
		}
		if ((buffer[2] != responseBuffer[1]) || (buffer[3] != responseBuffer[2])) {
			return STATUS_CRC_WRONG;
		}
		if (responseBuffer[0] & 0x04) { // Cascade bit set - UID not complete yes
			cascadeLevel++;
		}
		else {
			uidComplete = 1;
			uid->sak = responseBuffer[0];
		}
		} // End of while (!uidComplete)

		// Set correct uid->size
		uid->size = 3 * cascadeLevel + 1;

		return STATUS_OK;
}

char RC522_NewCardPresent(void){
	char bufferATQA[2];
	char bufferSize = 2;
	// Reset baud rates
	RC522_WriteRegister(TxModeReg,0);
	RC522_WriteRegister(RxModeReg,0);
	// Reset ModWidthReg
	RC522_WriteRegister(ModWidthReg,0x26);
	char result;
	result = RC522_CMD_REQAorWUPA(PICC_CMD_REQA, bufferATQA, bufferSize);
	return (result == STATUS_OK || result == STATUS_COLLISION);
}

char RC522_ReadCardSerial(void){
	char result = RC522_CardSelect(&uid, 0);
	return (result == STATUS_OK);
}

char RC522_GetCardType(char sak){		///< The SAK byte returned from PICC_Select().
	// http://www.nxp.com/documents/application_note/AN10833.pdf
	// 3.2 Coding of Select Acknowledge (SAK)
	// ignore 8-bit (iso14443 starts with LSBit = bit 1)
	// fixes wrong type for manufacturer Infineon (http://nfc-tools.org/index.php?title=ISO14443A)
	sak &= 0x7F;
	switch (sak) {
		case 0x04:	return PICC_TYPE_NOT_COMPLETE;	// UID not complete
		case 0x09:	return PICC_TYPE_MIFARE_MINI;
		case 0x08:	return PICC_TYPE_MIFARE_1K;
		case 0x18:	return PICC_TYPE_MIFARE_4K;
		case 0x00:	return PICC_TYPE_MIFARE_UL;
		case 0x10:
		case 0x11:	return PICC_TYPE_MIFARE_PLUS;
		case 0x01:	return PICC_TYPE_TNP3XXX;
		case 0x20:	return PICC_TYPE_ISO_14443_4;
		case 0x40:	return PICC_TYPE_ISO_18092;
		default:	return PICC_TYPE_UNKNOWN;
	}
}
