
#include <map>
#include <ctype.h>
#include <fstream>
#include <vector>

typedef std::vector<int> rgbValuesType;
typedef std::map<int, rgbValuesType> LuminanceToAlesteRGBMapType; // automatically sorted into ascending order by key

LuminanceToAlesteRGBMapType LuminanceToAlesteRGBMap;

void main()
{	
	for (int rgb=0; rgb<64; rgb++)
	{
		int r = (rgb>>4)&0x03;
		int g = (rgb>>2)&0x03;
		int b = rgb&0x03;
		
		float Luminance = (g*10.0f)+(r*3.03f)+b;
		int nLuminance = (int)floor(Luminance);
		LuminanceToAlesteRGBMap[nLuminance].push_back(rgb);
	}
	
	std::ofstream file;
  file.open ("Alestelum.txt");
	
	LuminanceToAlesteRGBMapType::const_iterator iter = LuminanceToAlesteRGBMap.begin();
	for (; iter != LuminanceToAlesteRGBMap.end(); iter++)
	{
		rgbValuesType::const_iterator valueIter = iter->second.begin();
		for (; valueIter != iter->second.end(); valueIter++)
		{
			file << "defw &" << std::hex << *valueIter << "\r\n";
		}
	}
	
  file.close();
	
	
	
}