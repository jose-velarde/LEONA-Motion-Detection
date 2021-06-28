#	Chrono Downloader Filter for CPTEC FTP
#	()(YEARMONTH)(DAY1|DAY2|..)(HOUR16|...|HOUR08)()
#	()(201910)(01|02|10|11|12|13|14|18|19|24|25|26|27|28|29|30|31)(16|17|18|19|20|21|22|23|00|01|02|03|04|05|06|07|08)()
#   ()(201911)(01|02|03|04|07|08|09|10|11|12|13|14|16|17|18|19)(16|17|18|19|20|21|22|23|00|01|02|03|04|05|06|07|08)()
#	()(201912)(02|03)()
#	
#	()(201910)(24|25|26|27|28|29|30|31)(09|10|11|12|13|14|15)()
import cv2
import os
import re
from pprint import pprint

from numpy import fabs

# Get a the images corresponding to the night of the indicated date to the morning of the following day.
def get_scan_list(month = "10", day= "2"):
	rootdir = "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/CPTEC data/2019" + month + "_HD"
	if len(day) == 1:
		day = "0" + day 
	# Look for unedited video clips
	regexday = re.compile("(.*_2019)({})(({}[1-2][0-9])|({}[0][0-9]))(\d\d\.jpg)".format(month, day, str(int(day)+1)))
	scan_list = []
	for root, dirs, files in os.walk(rootdir):
		for file in files:
			path = os.path.join(root,file)
			string_match = regexday.match(path)
			if string_match:
				scan_list.append(path)
	return scan_list


month = "11"
day = "13"
pprint(get_scan_list(month, day), width=180)

scan_list = get_scan_list(month, day)
break_flag = False
if len(day) == 1:
	day = "0" + day 
regextime = re.compile("(.*_2019)({})({}|{})(\d\d\d\d)(\.jpg)$".format(month, day, str(int(day)+1)))
# Original resolution: 3737 3425
height, width = 3737, 3425

while True:
	for scan in scan_list:
		string_match = regextime.match(scan)
		if string_match:
			print(string_match.group(4))
		cptec = cv2.imread(scan)
		cptec = cv2.applyColorMap(cptec, cv2.COLORMAP_JET)

		cv2.namedWindow("cptec", cv2.WINDOW_NORMAL)
		cv2.resizeWindow("cptec", int(height/5), int(width/5))
		cv2.imshow("cptec", cptec)
		keyboard = cv2.waitKey(1)
		if keyboard == 32:
			pprint("Pause")
			cv2.waitKey(-1)
		if keyboard == 27:
			break_flag = True
			break
	if break_flag:
		break
cv2.destroyAllWindows()