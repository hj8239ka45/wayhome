#ifndef MEGA168_SPI_h
#define MEGA168_SPI_h
#include <avr/io.h>
#include <util\delay.h>

#define SPI_DDR     DDRB
#define SPI_PORT    PORTB
#define SPI_SS      PB0
#define SPI_SCK     PB1
#define SPI_MOSI    PB2
#define SPI_MISO    PB3

#define SPI_CS_DDR     DDRF
#define SPI_CS_PORT    PORTF
#define SPI_CS      PF4


void M168_SPI_Master_init(void);
char SPI_swap(char Data);
void SPI_CSL(void);
void SPI_CSH(void);

#endif
