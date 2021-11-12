
#include <map>
#include <ctype.h>
#include <fstream>
#include <vector>

typedef std::vector<int> rgbValuesType;
typedef std::map<int, rgbValuesType> LuminanceToASICRGBMapType; // automatically sorted into ascending order by key

LuminanceToASICRGBMapType LuminanceToASICRGBMap;

void main()
{	
	for (int rgb=0; rgb<4096; rgb++)
	{
		int r = (rgb>>4)&0x0f;
		int g = (rgb>>8)&0x0f;
		int b = rgb&0x0f;
		
		// 9:3:1 weighting, g:r:b
		int Luminance = (g*9)+(r*3)+b;

		LuminanceToASICRGBMap[Luminance].push_back(rgb);
	}
	
	std::ofstream file;
  file.open ("asiclum.txt");
	
	LuminanceToASICRGBMapType::const_iterator iter = LuminanceToASICRGBMap.begin();
	for (; iter != LuminanceToASICRGBMap.end(); iter++)
	{
		rgbValuesType::const_iterator valueIter = iter->second.begin();
		for (; valueIter != iter->second.end(); valueIter++)
		{
			file << "defw &" << std::hex << *valueIter << "\r\n";
		}
	}
	
  file.close();
	
	
	
}