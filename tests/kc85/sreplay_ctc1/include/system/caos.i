;
;  caos.i
;  Framework85
;
;  Created by Stefan Koch on 14.02.16.
;
;

; --- System calls ---

COLD:	EQU	0F000H	; Kaltstart
WARM:	EQU	0E000H	; Warmstart

; --- PV ---

CAOS:	EQU	0F003H	; PV I

PV1:	EQU	0F003H	; PV I		UP-Nr. nach CALL
PV2:	EQU	0F006H	; PV II		UP-Nr. auf ARGC im IRM
PV3:	EQU	0F009H	; PV III	UP-Nr. im Register E
PV4:	EQU	0F00CH	; PV IV		Wie PV3 mit Ein/Ausschalten des IRM.
PV5:	EQU	0F015H	; PV V		Wie PV3 mit Ein/Ausschalten des IRM und Um- bzw. Rückschalten des Stackpointers auf dem Systemstackbereich.
PV6:	EQU	0F01EH	; PV VI		Wie PV3, jedoch UP-Nr. über (ARGC).

PVR:	EQU	0F00FH	; Relativer Unterprogrammaufruf (für verschiebliche Programme)

; --- Switches ---

IRMON:	EQU	0F018H	; Einschalten des IRM und Setzen des Stackpointers auf (SYSP)
IRMOFF:	EQU	0F01BH	; Abschalten des IRM und Rückstellen des Stackpointers.

; --- UP ---

; KC 85/2 (CAOS 2.2)
CRT:	EQU	00H	; Zeichenausgabe auf Bildschirm
MBO:	EQU	01H	; Datenblockausgabe auf Kassette (*)
UOT1:	EQU	02H	; Ausgabe auf Anwenderkanal 1
UOT2:	EQU	03H	; Ausgabe auf Anwenderkanal 2
KBD:	EQU	04H	; Tasteneingabe mit Cursoreinblendung
MBI:	EQU	05H	; Einlesen eines Datenblockes von Kassette
USIN1:	EQU	06H	; Eingabe Anwenderkanal 1
USIN2:	EQU	07H	; Eingabe Anwenderkanal 2
ISRO:	EQU	08H	; Initialisierung der Magnetbandausgabe (*)
CSRO:	EQU	09H	; Abschluß Magnetbandausgabe (*)
ISRI:	EQU	0AH	; Initialisierung Magnetbandeingabe (*)
CSRI:	EQU	0BH	; Abschluß Magnetbandeingabe
KBDS:	EQU	0CH	; Tastenstatusabfrage ohne Quittierung
BYE:	EQU	0DH	; Sprung auf RESET
KBDZ:	EQU	0EH	; Tastenstatusabfrage mit Quittierung
COLOR:	EQU	0FH	; Farbe einstellen
LOAD:	EQU	10H	; Laden Maschinenprogramm von Kassette
VERIF:	EQU	11H	; Kontrollesen von Kassettenaufzeichnungen
LOOP:	EQU	12H	; Übergeben Steuerung an CAOS
NORM:	EQU	13H	; Rückschalten E/A-Kanäle auf CRT und KBD
WAIT:	EQU	14H	; Warteschleife
LARG:	EQU	15H	; Register mit Argumenten laden (*)
INTB:	EQU	16H	; Zeicheneingabe vom aktuellen Eingabekanal
INLIN:	EQU	17H	; Eingabe einer Zeile, Abschluß mit (ENTER) (*)
RHEX:	EQU	18H	; Umwandlung einer Zeichenkette (hex.) in interne Darstellung (*)
ERRM:	EQU	19H	; Ausschrift "ERROR"
HLHX:	EQU	1AH	; Wertausgabe des Register HL als Hexzahl
HLDE:	EQU	1BH	; Ausgabe der Register HL, DE als Hexzahlen
AHEX:	EQU	1CH	; Ausgabe Register A als Hexzahl
ZSUCH:	EQU	1DH	; Suche nach Zeichenkette (Menüwort) (*)
SOUT:	EQU	1EH	; Zeiger auf Ausgabetabelle (*)
SIN:	EQU	1FH	; Zeiger auf Eingabetabelle (*)
NOUT:	EQU	20H	; Zeiger auf Normalausgabe (CRT) (*)
NIN:	EQU	21H	; Zeiger auf Eingabe KBD (*)
GARG:	EQU	22H	; Erfassen  von  10  Hexzahlen, Wandlung in interne Darstellung
OSTR:	EQU	23H	; Ausgabe einer Zeichenkette
OCHR:	EQU	24H	; Zeichenausgabe an Gerät
CUCP:	EQU	25H	; Komplementiere Cursor
MODU:	EQU	26H	; Modulsteuerung (*)
JUMP:	EQU	27H	; Sprung in neues Betriebssystem
LDMA:	EQU	28H	; LD (HL),A
LDAM:	EQU	29H	; LD A,(HL)
BRKT:	EQU	2AH	; Test auf Unterbrechungsanforderung
SPACE:	EQU	2BH	; Ausgabe eines Leerzeichens
CRLF:	EQU	2CH	; Ausgabe von "NEWLINE"
HOME:	EQU	2DH	; Ausgabe von "HOME" (Steuerzeichen)
MODI:	EQU	2EH	; Aufruf Systemkommando MODIFY
PUDE:	EQU	2FH	; Löschen Bildpunkt
PUSE:	EQU	30H	; Setzen Bildpunkt
SIXD:	EQU	31H	; Verlagern des Arbeitsbereiches von CAOS
DABR:	EQU	32H	; Berechnung der VRAM-Adresse aus Cursorposition (*)
TCIF:	EQU	33H	; Test, ob Cursorposition im definierten Fenster ist
PADR:	EQU	34H	; Pixeladresse (unterschiedlich auf KC 85/3 und KC 85/4!) (*)
TON:	EQU	35H	; Tonausgabe
SAVE:	EQU	36H	; Maschinenprogramm auf Kassette ausgeben

; Erweiterung für KC 85/3 (CAOS 3.1)
MBIN:	EQU	37H	; Byteweise Eingabe von Kassette (D: Steuerwort, A: Anzahl der verfügbaren Datenbytes)
MBOUT:	EQU	38H	; Byteweise Ausgabe auf Kassette
KEY:	EQU	39H	; Belegung einer Funktionstaste
KEYLI:	EQU	3AH	; Anzeige der Funktionstastenbelegung
DISP:	EQU	3BH	; HEX/ASCII-Dump
WININ:	EQU	3CH	; Neues Fenster initialisieren
WINAK:	EQU	3DH	; Aufruf Fenster über Fensternummer
LINE:	EQU	3EH	; Zeichnen einer Linie
CIRCLE:	EQU	3FH	; Zeichnen eines Kreises
SQR:	EQU	40H	; Quadratwurzelberechnung
MULT:	EQU	41H	; Multiplikation zweier 8-Bit-Zahlen (*)
CSTBT:	EQU	42H	; Negation des Steuerbytes und Ausgabe Zeichen
INIEA:	EQU	43H	; Initialisierung eines E/A-Kanals (*)
INIME:	EQU	44H	; Initialisierung mehrerer E/A-Kanäle (*)
ZKOUT:	EQU	45H	; Ausgabe einer Zeichenkette (*)
MENU:	EQU	46H	; Anzeige des aktuellen Menüs, Kommandoeingabe

; Erweiterung für KC 85/4 (CAOS 4.2)
V24OUT:	EQU	47H	; Druckerinitialisierung
V24DUP:	EQU	48H	; Initialisierung V24-Duplexroutine

; *   Unterprogramme,  die die Parameter in den Registern BC,  DE,
;     HL     an   das   Hauptprogramm   übergeben,  benötigen  den
;     Programmverteiler  I.  Bei allen anderen  Programmverteilern
;     werden  die  Register BC,  DE,  HL vor der  Abarbeitung  des
;     gewünschten  Unterprogramms gerettet und danach  wieder  mit
;     den  vorherigen  Werten  geladen.

; --- Systemzellen CAOS ---

ARGC:	EQU	0B780H	; UP-Nr. bei PV II, IV wird hier übergeben
ARGN:	EQU	0B781H	; Anzahl der übergebenen Argumente steht hier und in Register A
ARG1:	EQU	0B782H	; 1. Argument
ARG2:	EQU	0B784H	; 2. Argument
ARG3:	EQU	0B786H	; 3. Argument
ARG4:	EQU	0B788H	; 4. Argument
ARG5:	EQU	0B78AH	; 5. Argument
ARG6:	EQU	0B78CH	; 6. Argument
ARG7:	EQU	0B78EH	; 7. Argument
ARG8:	EQU	0B790H	; 8. Argument
ARG9:	EQU	0B792H	; 9. Argument
ARG10:	EQU	0B794H	; 10. Argument
HCADR:	EQU	0B799H	; SHIFT CLEAR (Hardcopy)
WINNR:	EQU	0B79BH	; Nr. des aktuellen Bildschirmfensters (0..9)
WINON:	EQU	0B79CH	; Fensteranfang (L: Spalte 0..39, H: Zeile 0..31)
WINLG:	EQU	0B79EH	; Fenstergröße (L: Spalten 0..40, H: Zeilen 0..32)
CURSO:	EQU	0B7A0H	; rel. Cursor-Position (L: Spalte, H: Zeile)
STBT:	EQU	0B7A2H	; Steuerbyte für Bildschirmprogramm
COLOR_:	EQU	0B7A3H	; Farbbyte für Bildschirmprogramm
WEND:	EQU	0B7A4H	; Anfangsadresse des Reaktionsprogramms auf Erreichen des Fensterendes (Page-/Scrollmode usw.)
CCTL0:	EQU	0B7A6H	; Adresse der Zeichenbildtabelle für Codes 20H-5FH
CCTL1:	EQU	0B7A8H	; Adresse der Zeichenbildtabelle für Codes 00H-1FH und 60H-7FH
CCTL2:	EQU	0B7AAH	; Adresse der Zeichenbildtabelle für Codes A0H-DFH
CCTL3:	EQU	0B7ACH	; Adresse der Zeichenbildtabelle für Codes 80H-9FH und E0H-FFH
SYSP:	EQU	0B7AEH	; SYSTEM STACKPOINTER INIT ADRESSE
OUTAB:	EQU	0B7B9H	; OUT-CHANNEL
UOUT1:	EQU	0B7BEH	; USER OUT 1
UOUT2:	EQU	0B7C4H	; USER OUT 2
IOERR:	EQU	0B7C9H	; I/O Error Handler
VRAM:	EQU	0B7CBH	; Beginn Video RAM (ASCII-Speicher)
FARB:	EQU	0B7D6H	; Vordergrundfarbe für Grafikprogramm
COUNT:	EQU	0B7E0H	; Zeiteinheiten bis 1. Autorepeat (Tastatureingabe)

; --- Arbeitszellen im IX-Bereich ---

; Interrupttabelle

IXO_USR0:	EQU	-28	; Frei für Anwender-Interrupts
IXO_USR1:	EQU	-26	; Frei für Anwender-Interrupts
IXO_USR2:	EQU	-24	; Frei für Anwender-Interrupts
IXO_USR3:	EQU	-22	; Frei für Anwender-Interrupts
IXO_USR4:	EQU	-20	; Frei für Anwender-Interrupts
IXO_USR5:	EQU	-18	; Frei für Anwender-Interrupts
IXO_USR6:	EQU	-16	; Frei für Anwender-Interrupts
IXO_SIOB:	EQU	-14	; Interrupt SIO Kanal B   (wenn V24-Modul im System)
IXO_PIOA:	EQU	-12	; Interrupt PIO Kanal A - Kassetteneingabe
IXO_PIOB:	EQU	-10	; Interrupt PIO Kanal B - Tastatur
IXO_CTC0:	EQU	-8	; Interrupt CTC Kanal 0   kein Interrupt, Tonhöhe 1
IXO_CTC1:	EQU	-6	; Interrupt CTC Kanal 1 - Kassettenausaabe, Tonhöhe 2
IXO_CTC2:	EQU	-4	; Interrupt CTC Kanal 2 - Tondauer, Blinkfrequenz
IXO_CTC3:	EQU	-2	; Interrupt CTC Kanal 3 - Tastatur

; Kassetten-Ein/-Ausgabe

IXO_CABIT_TIME:	EQU	0	; Ergebnis der Stopuhr für Unterscheidung 0/1 Bit

; Status der internen Ausgabeadresse 84H

IXO_CH84:	EQU	1	; Merkzelle für zuletzt geschriebenen Wert für Ausgabe-Kanal 84H

; Kassetten-Ein/-Ausgabe

IXO_CABLK_ACT:	EQU	2	; aktuelle tatsächlich gelesene Blocknummer
IXO_CABLK_EXP:	EQU	3	; erwartete Blocknummer

; Status der internen Ausgabeadresse 86H

IXO_CH86:	EQU	4	; Merkzelle für zuletzt geschriebenen Wert für Ausgabe-Kanal 86H

; Kassetten-Ein/-Ausgabe

IXO_CAIOBUF:	EQU	5	; Pufferadresse für Kassetten-Ein-/Ausgabe (Offset 5 und 6)
IXO_CACTL:	EQU	7	; BIT 0 = 1: LOAD, 0: VERIFY
				; Bit 5 = 1: Blocknummern-Unterdrückung
				; Bit 6 = 1: List-Schutz für BASIC-Programme
; Tastatureingabe

IXO_AVAIL:	EQU	8	; Tastencode steht zur Verfügung, Ton läuft, Shift Lock
IXO_PROLOG:	EQU	9	; Prolog byte (default: 7FH)
IXO_COUNTER:	EQU	10	; Zähler für Autorepeat der Tastatur
IXO_KEY:	EQU	13	; Tastencode (ASCII)

; Bits (IXO_AVAIL)

COAVAIL:	EQU	0	; Tastencode steht zur Verfügung, Übernahmequittierung mit "RES 0, (IX + 8)"
PLAYING:	EQU	1	; Ton spielt
SFTLOCK:	EQU	7	; Shift Lock aktiv

; Interne Ausgabeadressen

; Im Unterschied zur PIO ist beim D374 kein „Zurücklesen“ des zuletzt ausgegebenen Datenwortes möglich.
; Aus diesem Grund muß von der Software das an die Adressen (84H bzw. 86H) ausgegebene Datenwort auch
; in die dafür vorgesehenen Zellen des IX-Speicherbereiches eingeschrieben werden
; (siehe Softwaredokumentation).

; Quelle: Serviceanleitung KC 85/4

; Ausgabekanal 84H bzw. (IX + 1)

DISPV:		EQU	0	; Anzeige Bild 0 oder 1
PIXCOL:		EQU	1	; Zugriff auf Pixel = 0 oder Farbe = 1
DISPWR:		EQU	2	; Zugriff auf Bild 0 oder 1
HIRES:		EQU	3	; hohe Farbauflösung ein/aus ; ein (aktiv) = Low, Bit 3 = 0
RAM8SEL:	EQU	4	; Auswahl RAM8-Block (0 oder 1)
RAM8BLK:	EQU	5	; RAM-Block-Selectbit für RAM8
; Bit 6 - reserviert
; Bit 7 - reserviert

; Ausgabekanal 86H bzw. (IX + 4)

RAM4:		EQU	0	; RAM 4
RAM4_RO:	EQU	1	; Schreibschutz RAM 4 ; 1 = Schreibschutz aus
; Bit 2 - frei
; Bit 3 - frei
; Bit 4 - frei
; Bit 5 - reserviert
; Bit 6 - reserviert
RAMC:		EQU	7	; CAOS-ROM C ; Wird vom Betriebssystem automatisch verwaltet,
				; ist im Normalfall abgeschaltet. Aus diesem Grund
				; ist die Eingabe SWITCH nicht notwendig.

; --- I/O ---

; Interne I/O-Adressen

; PIO
PIOA:		EQU	88H	; PIO KANAL A DATEN
PIOB:		EQU	89H	; PIO KANAL B DATEN (Lautstärke)
PIOAC:		EQU	8AH	; PIO KANAL A STEUERWORT
PIOBC:		EQU	8BH	; PIO KANAL B STEUERWORT

; CTC (see also: Z80 CPU Peripherals User Manual)
CTC0:		EQU	8CH	; CTC KANAL 0 STEUERWORT/ZEITKONSTANTE (Tonhöhe 1)
CTC1:		EQU	8DH	; CTC KANAL 1 STEUERWORT/ZEITKONSTANTE (Tonhöhe 2)
CTC2:		EQU	8EH	; CTC KANAL 2 STEUERWORT/ZEITKONSTANTE (Blinksteuerung, Zeitgeber für Kassetteneingabe)
CTC3:		EQU	8FH	; CTC KANAL 3 STEUERWORT/ZEITKONSTANTE (Zeitgeber für Tastatureingabe)

; PIO-Port A (88H) Data Bits

ROME:		EQU	0	; CAOS-ROM E
RAM0:		EQU	1	; RAM 0
IRM:		EQU	2	; IRM
RAM0_RO:	EQU	3	; Schreibschutz RAM 0; 1 = Schreibschutz aus
K_OUT:		EQU	4	; nicht benutzt
LED:		EQU	5	; LED "TAPE" an der Frontplatte
MOTOR:		EQU	6	; Motorschaltspannung (Schnellstop) des Kassetenrecorders
ROMC:		EQU	7	; ROM C (BASIC)

; PIO-Port B (89H) Data Bits

; An die Flip-Flops für die Tonausgabe (Schaltkreis D3023) ist zusätzlich
; das Signal trück herangeführt, durch welches beide Flip-Flops vor Beginn
; der Tonausgabe in eine definierte Ausgangslage zurückgesetzt werden.
; Hierdurch wird eine gegenseitige Auslöschung beider Tonkanäle vermieden,
; falls sie mit gleicher Frequenz angesteuert werden. (KC 85/4 Serviceanleitung, Seite 5)

RESET_TON:	EQU	0	; Rücksetzen der Symmetrie-Flip-Flops für Tonausgabe
VOL_MSK:	EQU	1FH	; Lautstärke (Bit-Maske, Bit 0-4, low-aktiv)
VOL_MSK4:	EQU	1EH	; Lautstärke (Bit-Maske, Bit 1-4, low-aktiv)
RAM8:		EQU	5	; RAM 8
RAM8_RO:	EQU	6	; Schreibschutz RAM 8 ; 1 = Schreibschutz aus
BLINK:		EQU	7	; Blinken der Vordergrundfarbe ein/aus
