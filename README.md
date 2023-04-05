# wayhome
使用MCU (ATmega128)進行微控制器實驗  
====
透過C語言針對晶片進行記憶體配置，並透過SPI通訊與FRID感測器(RC522)溝通資料取得，將資料傳輸於電腦，並於電腦端使用 matlab 建立簡易介面，完成門禁點名系統。由於此系統會使用到 SPI 通訊與 RC522 模組，因此將兩者分別獨立建副函式於檔案進行呼叫：Mega168_SPI、RC522  

[RFID感應流程]  
讀取Mifare卡片的流程如下，我們的程式不需要理會其中的「防衝突處理」和「選卡」	部份，讀寫器會幫我們搞定，但是在讀取資料之後，我們的程式要發出命令讓卡片進入停	止（halt）狀態，避免讀寫器重複讀取同一張卡片：  
![image](https://user-images.githubusercontent.com/39979565/229977243-ada4319f-6265-4df6-8b9d-b5feb04f46d7.png)  
SAK代表select acknowledge，直譯為「選擇應答」，是由卡片發給讀寫器，對於選擇卡片命令的回應，不同類型的Mifare卡片的SAK值不一樣（例如，Mifare Classic的SAK	值為0x18），程式可藉此判別感應到的卡片類型。  

[RFID 與 Mega168互動關係]  
運用Studio4(IDE)建構程式碼操作ATmegaM128與RFID面板進行操作，運用SPI技術，操作腳位調高調低電壓來接收數據。
SPI 通信使用 4 個引腳，分別為： 
SPI_MOSI: 做為master時資料輸出；做為slave時資料輸入  
SPI_MISO: 做為master時資料輸入；做為slave時資料輸出  
SPI_CLK: SPI的時脈信號由master主控產生；資料 (輸出及輸入) 和時脈同步  
SPI_SS: 此引腳唯有做為slave mode時有做用；做為master mode，此引腳當做GPIO使用 (0: master致能slave；1: master禁能slave)  


