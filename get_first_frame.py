import os
import cv2
import re 

rootdir = "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Santa Maria 28-10-2019/Positives/Clips"
regexavi = re.compile("(.*avi$)")

def get_first_frame():
	for root, dirs, files in os.walk(rootdir):
		for file in files:
			if regexavi.match(file):
				path = os.path.join(root,file)
				capture = cv2.VideoCapture(cv2.samples.findFileOrKeep(path))
				capture.set(cv2.CAP_PROP_POS_FRAMES, 0)
				ret, frame = capture.read()
				p = "{}/Frames1/{}.png".format(root, file[:-15])
				cv2.imwrite(p, frame)
				capture.release()

regexpng = re.compile("(.*png$)")
for root, dirs, files in os.walk(rootdir):
	for file in files:
		if regexavi.match(file):

# get_first_frame()
