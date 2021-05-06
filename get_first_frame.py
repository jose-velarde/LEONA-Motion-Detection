import os
import cv2
import re 


def get_first_frame():
	rootdir = "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Santa Maria 28-10-2019/Positives/Clips"
	regexavi = re.compile("(.*avi$)")
	for root, dirs, files in os.walk(rootdir):
		for file in files:
			if regexavi.match(file):
				path = os.path.join(root,file)
				capture = cv2.VideoCapture(cv2.samples.findFileOrKeep(path))
				capture.set(cv2.CAP_PROP_POS_FRAMES, 0)
				ret, frame = capture.read()
				p = "{}/Time digits/{}.png".format(root, file[:-15])
				cv2.imwrite(p, frame)
				capture.release()

def get_png_dirlist():
	rootdir = "./Time digits"
	regexpng = re.compile("(.*png$)")
	png_dirlist = []
	for root, dirs, files in os.walk(rootdir):
		for file in files:
			if regexpng.match(file):
				# print(os.path.join(root,file))
				png_dirlist.append(os.path.join(root,file))
	return png_dirlist

# get_first_frame()
# print(get_png_dirlist())