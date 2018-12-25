//			FinalProject													made by 陳崴淇 林修羽
//			day:2018/11/28

#include <avr\io.h>
#include <avr\interrupt.h>
#include <stdio.h>
#include <string.h>
#include <util\delay.h>
#include "ASA_Lib.h"
#include "Mega168_SPI.h"
#include "RC522.h"

#define F_CPU 11059200UL
#define HMI_TYPE_I8   0
#define HMI_TYPE_I16  1
#define HMI_TYPE_I32  2
#define HMI_TYPE_I64  3
#define HMI_TYPE_UI8  4
#define HMI_TYPE_UI16 5
#define HMI_TYPE_UI32 6
#define HMI_TYPE_UI64 7
#define HMI_TYPE_F32  8
#define HMI_TYPE_F64  9

#define RESET_DDR DDRA
#define RESET_PORT PORTA
#define RESET_PIN PA5
int t=0;
int i = 0;
ISR(TIMER1_OVF_vect){
	i++;
	if(i==3000) {
		t=1;
		i=0;
	}
}

int time_init(){
	TCCR1B |= (0<<CS12) | (1<<CS11) | (0<<CS10);//設定中斷頻率
	// 		// 除頻值設定 11059200/2*8*ICR1
	TCCR1A |= (1<<WGM11) | (0<<WGM10);
	TCCR1B |= (1<<WGM13) | (1<<WGM12);
	// 		// 設定計時方式，使用 Fast PWM
	TIMSK |= (1<<TOIE1);
	// 		// 開啟TIMER1中斷
	ICR1=692; //11059200/64/2(800+1) 0.2k
	sei();
}

int main(){
	ASA_M128_set();
	time_init();
	M168_SPI_Master_init();
	RESET_PORT &= ~(1<<RESET_PIN);
	_delay_ms(100);
	RESET_PORT |=(1<<RESET_PIN);
	_delay_ms(100);
	// Reset RC522
	int a = RC522_ReadRegister(VersionReg);
	//printf("%x\n",a);//check SPI
	RC522_Init();
	int flag=1;
	while(1){
		if(t==1||flag==1)
		{
			flag=0;
			t=0;
		int result = 0;
		result = RC522_NewCardPresent();
		// find card
		int32_t Card_ID[4];
		if(result==1)
		{
			// new card  has been found
			result = RC522_ReadCardSerial();
			// try to get card UID
			if(result==1)
			{
				// get UID successfully
				for(int i = 0;i<4;i++){
					Card_ID[i] = uid.uidByte[i];
					//printf("%x\n",Card_ID[i]);//print the card id
				}
				int TMP_bytes = sizeof(Card_ID);
				M128_HMI_put( TMP_bytes, HMI_TYPE_I32 , Card_ID);
			}
			else
			{
				for(int i = 0;i<4;i++)
				{
					Card_ID[i] = 0;
				}
			}
		}
		else {
			for(int i = 0;i<4;i++){
				Card_ID[i] = 0;
			}
		}
		RC522_HaltA();
		RC522_StopCrypto1();//close the interact
		}
	}
	return 0;
}


