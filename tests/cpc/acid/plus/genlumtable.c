#include <map>

typedef std::map<float,u16> LuminanceToASICRGBMapType; // automatically sorted into ascending order by key

LuminanceToASICRGBMapType LuminanceToASICRGBMap;

void main()
{	
	for (int rgb=0; rgb<4096; rgb++)
	{
		int r = (rgb>>4)&0x0f;
		int g = (rgb>>8)&0x0f;
		int b = rgb&0x0f;
		
		// 9:3:1 weighting 
		int Luminance = (r*9)+(g*3)+b;

		LuminanceToASICRGBMap[Luminance] = rgb;
	}
	
	ofstream file;
  file.open ("asiclum.txt");
	
	LuminanceToASICRGBMapType::const_iterator iter = LuminanceToASICRGBMap.begin();
	for (; iter!=LuminanceToASICRGBMap.end(); iter++)
	{
		file << "defw &" <<  std::hex << iter->second;
	}
	
  file.close();
	
	
	
}