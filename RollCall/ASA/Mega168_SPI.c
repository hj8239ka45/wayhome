#include "C:\Users\hj823\Desktop\test\OM-test7-1\OM-test7-1\Mega168_SPI.h"

	//setting the master register
void M168_SPI_Master_init(void){
	DDRB |= (1<<7)|(1<<6)|(1<<5);
	PORTB |= (0<<7)|(0<<6)|(1<<5);
	
	SPI_DDR&=~((1<<SPI_SS)|(1<<SPI_SCK)|(1<<SPI_MOSI)|(1<<SPI_MISO));
	SPI_DDR|=(1<<SPI_SS)|(1<<SPI_SCK)|(1<<SPI_MOSI);
	SPI_CS_DDR|=(1<<SPI_CS);
	SPCR=(0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
	SPI_CSH();
}
	//get or put the data
char SPI_swap(char Data){
	SPDR = Data;
	while( !(SPSR&(1<<SPIF)) );
	return SPDR;
}
	//push down the CS line (end)
void SPI_CSL(void){
	SPI_CS_PORT |= (1<<SPI_CS);
	_delay_ms(10);
	// _delay_us(1);
}
	//push up the CS line (begin)
void SPI_CSH(void){
	SPI_CS_PORT &= ~(1<<SPI_CS);
}
