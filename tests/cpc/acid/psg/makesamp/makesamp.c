#include <stdio.h>
#include <stdlib.h>
#include <math.h>

unsigned char *pData = NULL;
unsigned long nLength = 0;
 
 enum
 {
	 METHOD_PSG_SINGLE_CHANNEL_0_TO_F,
	 METHOD_PSG_SINGLE_CHANNEL_0_OR_F,	 
 };
 
// 0 - psg single channel (0-f)
// 1 - psg single channel (0/f)

float mult[16]={
	0.0f, /* 0 */
	0.0106f, /* 1 */
	0.0150f, /* 2 */
	0.0222f, /* 3 */
	0.0320f, /* 4 */
	0.0466f, /* 5 */
	0.0665f, /* 6 */
	0.1039f, /* 7 */
	0.1237f, /* 8 */
	0.1986f, /* 9 */
	0.2803f, /* 10 */
	0.3548f, /* 11 */
	0.4702f, /* 12 */
	0.6030f, /* 13 */
	0.7530, /* 14 */
	1.0f /* 15 */
	};

int Lookup[256];
 
int main(int argc, char **argv)
{
	int i;

	int val;
	int method = METHOD_PSG_SINGLE_CHANNEL_0_TO_F;	
	int success=-2;
	method = atoi(argv[2]);
	
	for (i=0; i<256; i++)
	{
		Lookup[i] = -1;
	}

	for (i=0; i<16; i++)
	{
		val = floor(mult[i]*255);
		
		Lookup[val] = i;
	}
	
	
	for (i=255; i>=0; i--)
	{
		if (Lookup[i]!=-1)
		{
			val = Lookup[i];
		}
		else
		{
			Lookup[i] = val;
		}
	}
	
		
	printf("data:\n");
	
	FILE *fh = fopen(argv[1],"rb");
	if (fh)
	{
		int len = 0;

		fseek(fh, 0, SEEK_END);
		len = ftell(fh);
		fseek(fh, 0, SEEK_SET);
		
		pData = malloc(len);
		if (pData)
		{
			fread(pData, len, 1, fh);
		}
		fclose(fh);

		if (
			(pData[0]=='R') && 
			(pData[1]=='I') && 
			(pData[2]=='F') &&
			(pData[3]=='F') &&
			(pData[8]=='W') && 
			(pData[9]=='A') && 
			(pData[0x0a]=='V') &&
			(pData[0x0b]=='E')
			)
			{
				unsigned int nFreq = 0;
				int foundFmt = 0;
				int lengthRemaining = 0;
				unsigned char *pChunk;
				int unsupportedFormat = 0;
				int foundData = 0;

				unsigned long dataLen = (
				(pData[4]&0x0ff) |
				((pData[5]&0x0ff)<<8) |
				((pData[6]&0x0ff)<<16) |
				((pData[7]&0x0ff)<<24)
				);
					
				pChunk = &pData[0x0c];
				lengthRemaining = dataLen-4;
				
				while (!foundFmt && (lengthRemaining!=0))
				{
					unsigned long chunkLen = (
					(pChunk[4]&0x0ff) |
					((pChunk[5]&0x0ff)<<8) |
					((pChunk[6]&0x0ff)<<16) |
					((pChunk[7]&0x0ff)<<24)
					);
					
					if (
					(pChunk[0]=='f') &&
					(pChunk[1]=='m') &&
					(pChunk[2]=='t') &&
					(pChunk[3]==' ')
					)
					{
						int nChannels = 0;
						int nFormatTag = 0;
						foundFmt = 1;
						
						nFormatTag = (pChunk[8]&0x0ff)|((pChunk[9]&0x0ff)<<8);
						nChannels = (pChunk[0x0a]&0x0ff)|((pChunk[0x0b]&0x0ff)<<8);
						nFreq  = 
						((pChunk[0x0c]&0x0ff)|
						((pChunk[0x0d]&0x0ff)<<8)|
						((pChunk[0x0e]&0x0ff)<<16)|
						((pChunk[0x0f]&0x0ff)<<24));
						
						if (nFormatTag!=1)
						{
							success = -3;
							unsupportedFormat = 1;
						}
						if (nChannels!=1)
						{
							success = -4;
							unsupportedFormat = 1;
						}
						printf(";;Format: %d\n", nFormatTag);
						printf(";;Channels: %d\n", nChannels);
						printf(";;Freq: %d (hz)\n", nFreq);
					}
					
					pChunk = pChunk+chunkLen+8;
					lengthRemaining -= chunkLen+8;
				}
				
				if (unsupportedFormat)
				{
					success = -2;
				}
				else
				{
					int foundData = 0;
					int columnIndex = 0;
					
					while (!foundData && (lengthRemaining!=0))
					{
						unsigned long chunkLen = (
						(pChunk[4]&0x0ff) |
						((pChunk[5]&0x0ff)<<8) |
						((pChunk[6]&0x0ff)<<16) |
						((pChunk[7]&0x0ff)<<24)
						);
						
						if (
						(pChunk[0]=='d') &&
						(pChunk[1]=='a') &&
						(pChunk[2]=='t') &&
						(pChunk[3]=='a')
						)
						{
							int maxBytes = 4096;
							int outputFreq = 8000;
							float increment = (float)nFreq / (float)outputFreq;
							float pos = 0.0f;
							unsigned char *pPtr = pChunk+8;
							unsigned char outData = 0;
							int elementCount = 0;
							printf(";;Output freq: %d\n", outputFreq);
							printf(";;Increment: %f\n", increment);
							foundData = 1;
							
							while ( (((int)floor(pos))<chunkLen) && (((int)floor(pos))<maxBytes))
							{
								unsigned char data = pPtr[(int)floor(pos)];
								pos+=increment;
								
								if ((columnIndex==0) && (elementCount==0))
								{
									printf("defb ");
								}
								else if ((columnIndex!=0) && (elementCount==0))
								{
									printf(",");
								}
						
								switch (method)
								{
								case METHOD_PSG_SINGLE_CHANNEL_0_TO_F:
								{
									outData = Lookup[data];
									printf("&%02x", outData);
									columnIndex++;
								}
								break;

								case METHOD_PSG_SINGLE_CHANNEL_0_OR_F:
								{
									outData = outData << 1;
									if (data > 127)
									{
										outData |=0x01;
									}
									else
									{
										outData |= 0x0;
									}
									elementCount++;
									if (elementCount == 8)
									{
										printf("&%02x", outData);
										outData = 0;
										elementCount = 0;
										columnIndex++;
									}
								}
								break;
								}
									
								if (columnIndex==8)
								{
									columnIndex = 0;
									printf("\n");
								}
							}
							
							if (elementCount != 0)
							{
								printf("&%02x", outData);
							}

							success = 0;
						}
						
						pChunk = pChunk+chunkLen+8;
						lengthRemaining -=chunkLen+8;
					}
				}
				
				if (!foundData)
				{
					success = -6;
				}
			}
	}
	else
	{
		success = -1;
	}
	
	return 0;
}