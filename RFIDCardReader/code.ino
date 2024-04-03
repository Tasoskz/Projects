* --------------------------------------------------------------------------------------------------------------------
 * Example sketch/program showing how to read data from a PICC to serial.
 * --------------------------------------------------------------------------------------------------------------------
 * This is a MFRC522 library example; for further details and other examples see: https://github.com/miguelbalboa/rfid
 * 
 * Example sketch/program showing how to read data from a PICC (that is: a RFID Tag or Card) using a MFRC522 based RFID
 * Reader on the Arduino SPI interface.
 * 
 * When the Arduino and the MFRC522 module are connected (see the pin layout below), load this sketch into Arduino IDE
 * then verify/compile and upload it. To see the output: use Tools, Serial Monitor of the IDE (hit Ctrl+Shft+M). When
 * you present a PICC (that is: a RFID Tag or Card) at reading distance of the MFRC522 Reader/PCD, the serial output
 * will show the ID/UID, type and any data blocks it can read. Note: you may see "Timeout in communication" messages
 * when removing the PICC from reading distance too early.
 * 
 * If your reader supports it, this sketch/program will read all the PICCs presented (that is: multiple tag reading).
 * So if you stack two or more PICCs on top of each other and present them to the reader, it will first output all
 * details of the first and then the next PICC. Note that this may take some time as all data blocks are dumped, so
 * keep the PICCs at reading distance until complete.
 * 
 * @license Released into the public domain.
 * 
 * Typical pin layout used:
 * -----------------------------------------------------------------------------------------
 *             MFRC522      Arduino       Arduino   Arduino    Arduino          Arduino
 *             Reader/PCD   Uno/101       Mega      Nano v3    Leonardo/Micro   Pro Micro
 * Signal      Pin          Pin           Pin       Pin        Pin              Pin
 * -----------------------------------------------------------------------------------------
 * RST/Reset   RST          9             5         D9         RESET/ICSP-5     RST
 * SPI SS      SDA(SS)      10            53        D10        10               10
 * SPI MOSI    MOSI         11 / ICSP-4   51        D11        ICSP-4           16
 * SPI MISO    MISO         12 / ICSP-1   50        D12        ICSP-1           14
 * SPI SCK     SCK          13 / ICSP-3   52        D13        ICSP-3           15
 *
 * More pin layouts for other boards can be found here: https://github.com/miguelbalboa/rfid#pin-layout
 */

#include <SPI.h>            //SPI bus library 
#include <MFRC522.h>        //RC522 library

#define RST_PIN         9           // reset pin
#define SS_PIN          10         // slave select pin

MFRC522 mfrc522(SS_PIN, RST_PIN);  // Create MFRC522 object
MFRC522::MIFARE_Key key;           //create a MIFARE_Key struct named 'key', which will hold the card information

byte accessCard[4] = {0x43, 0xE7, 0xB3, 0xA6};
byte readtheblock[18];
int i;
int counter = 0;
int greenPin = 5;
int redPin = 6;
int bluePin = 7;
int buzzerPin = 4;

void setup() {
  pinMode(greenPin, OUTPUT);
  pinMode(redPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  pinMode(buzzerPin, OUTPUT);
	Serial.begin(9600);		// Initialize serial communications with the PC
	SPI.begin();			// Init SPI bus
	mfrc522.PCD_Init();		// Init MFRC522
  Serial.println(F("  Scan your card...")); //Message to scan the card
  for (byte i = 0; i < 6; i++) 
    key.keyByte[i] = 0xFF;    //Security key, which bytes are 255
}

void loop() {

  digitalWrite(bluePin, HIGH);

	// Reset the loop if no new card present on the sensor/reader. This saves the entire process when idle.
	if ( ! mfrc522.PICC_IsNewCardPresent()) {
		return;
	} 

	// Select one of the cards
	if ( ! mfrc522.PICC_ReadCardSerial()) {
		return;
	}
  digitalWrite(bluePin, LOW);
  Serial.println("your card has passed successfully");
  readBlock(4, readtheblock);
  for (i=0; i<4; i++)
    { 
    if (mfrc522.uid.uidByte[i] == accessCard[i])
      counter++;
    }

  if (counter == 4){
    digitalWrite(greenPin, HIGH);
    Serial.print("Hello");
    for (int j=0 ; j<16 ; j++)
    {
      Serial.write (readtheblock[j]);
    }
    Serial.println("");
    Serial.println("WELCOME!!!");
    counter = 0;
    delay(2000);
    digitalWrite(greenPin, LOW);
  }
  else{
    digitalWrite(redPin, HIGH);
    digitalWrite(buzzerPin, HIGH);
    Serial.print("Oops");
    for (int j=0 ; j<16 ; j++)
    {
      Serial.write (readtheblock[j]);
    }
    Serial.println("");
    Serial.println("you are not in the list, sorry...☹");
    counter = 0;
    delay(2000);
    digitalWrite(redPin, LOW);
    digitalWrite(buzzerPin, LOW);
  } 
  mfrc522.PCD_StopCrypto1();    //for the RC522 to communicate with PICCs after communicating with an authenticated PICC 
  Serial.println(F("  Scan your card...")); //Message to scan the card
}
//Read specific block
int readBlock(int blockNumber, byte arrayAddress[]) 
{
  int largestModulo4Number=blockNumber/4*4;
  int trailerBlock=largestModulo4Number+3;//determine trailer block for the sector

  //authentication of the desired block for access
  byte status = mfrc522.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A, trailerBlock, &key, &(mfrc522.uid));
  if (status != MFRC522::STATUS_OK) {
         Serial.print("PCD_Authenticate() failed (read): ");
         Serial.println(mfrc522.GetStatusCodeName(status));
         return 3;//return "3" as error message
  }

//reading a block
byte buffersize = 18;//we need to define a variable with the read buffer size, since the MIFARE_Read method below needs a pointer to the variable that contains the size... 
status = mfrc522.MIFARE_Read(blockNumber, arrayAddress, &buffersize);//&buffersize is a pointer to the buffersize variable; MIFARE_Read requires a pointer instead of just a number
  if (status != MFRC522::STATUS_OK) {
          Serial.print("MIFARE_read() failed: ");
          Serial.println(mfrc522.GetStatusCodeName(status));
          return 4;//return "4" as error message
  }
}
