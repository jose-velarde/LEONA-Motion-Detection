import os
import cv2
import re 
from pprint import pprint

def get_first_frame():
	rootdir = "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV"
	# Look for unedited video clips
	regexavi = re.compile("(.*)(Positives)(.*)(.*original.avi$)")
	video_clip_list = []
	for root, dirs, files in os.walk(rootdir):
		for file in files:
			path = os.path.join(root,file)
			string_match = regexavi.match(path)
			if string_match:
				# capture = cv2.VideoCapture(cv2.samples.findFileOrKeep(path))
				# capture.set(cv2.CAP_PROP_POS_FRAMES, 0)
				# ret, frame = capture.read()
				# p = "{}/Time digits/{}.png".format(root, file[:-15])
				# cv2.imwrite(p, frame)
				# capture.release()
				video_clip_list.append(path)
				print(string_match.group(1) + string_match.group(2))
		# break
	pprint(len(video_clip_list))

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

def make_triggerframe_list():
	rootdir = "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV"
	# Look for unedited video clips
	regexframe = re.compile("(.*)(Positives|False positives)(.)(\d+)(\.png$)")
	triggerframe_list = []
	for root, dirs, files in os.walk(rootdir):
		for file in files:
			path = os.path.join(root,file)
			string_match = regexframe.match(path)
			if string_match:
				triggerframe_list.append(path)
				# print(string_match.group(1) + string_match.group(2))
			# print(path)
	return triggerframe_list

# get_first_frame()
# print(get_png_dirlist())

# framelist = make_triggerframe_list()

# with open("triggerframe_list.txt", "w") as file:
# 	for line in framelist:
# 		file.write("{}\n".format(line))
