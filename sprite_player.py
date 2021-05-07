import os
import cv2
import re 
from pprint import pprint
import numpy as np


def get_sprites_list():
	rootdir = "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV"
	# Look for unedited video clips
	regexavi = re.compile("(.*)(Positives)(.*)(.*original.avi$)")
	sprites_list = []
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
				sprites_list.append(path)
				# print(string_match.group(1) + string_match.group(2))
	return sprites_list

video_list = get_sprites_list()

# pprint(video_list, width=180)

kernel = np.ones((2,2),np.uint8)
video_index = 0
while True:
	break_flag = False
	pprint(video_list[video_index], width=180)
	capture = cv2.VideoCapture(cv2.samples.findFileOrKeep(video_list[video_index]))
	
	ret, frame = capture.read()
	th1 = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
	ret1, th1 = cv2.threshold(th1, 10, 255, cv2.THRESH_BINARY)
	previous_count = cv2.countNonZero(th1)
	capture.set(cv2.CAP_PROP_POS_FRAMES, 0)
	threshold = 8
	calibration_flag = False
	while True:
		# Grab the current frame
		ret, frame = capture.read()
		# Loop video
		if frame is None:
		# if capture.get(cv2.CAP_PROP_POS_FRAMES) == 300000:
			# capture.set(cv2.CAP_PROP_POS_FRAMES, 0)
			# continue
			pprint("File end, playing next file")
			video_index += 1
			break
		# Cover the GPS time
		frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
		ret1, th1 = cv2.threshold(frame, threshold, 255, cv2.THRESH_BINARY)
		# ret1, th1 = cv2.threshold(frame, threshold, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
		cv2.rectangle(th1, (0, 425), (710,465), (0,0,0), -1)
		current_count = cv2.countNonZero(th1)
		calibration_flag = True
		if not calibration_flag:
			while current_count > int(720*480*0.001):
				threshold += 2
				# th1 = cv2.medianBlur(th1, 5)
				ret1, th1 = cv2.threshold(frame, threshold, 255, cv2.THRESH_BINARY)
				# th1 = cv2.morphologyEx(th1, cv2.MORPH_OPEN, kernel)
				cv2.rectangle(th1, (0, 425), (710,465), (0,0,0), -1)
				current_count = cv2.countNonZero(th1)
				# cv2.imshow("th1", th1)
				# cv2.waitKey(-1)
			# pprint("Too bright {}".format(threshold))
		# th1 = cv2.morphologyEx(th1, cv2.MORPH_OPEN, kernel)
		# current_count = cv2.countNonZero(th1)
		# calibration_flag = True
		# cv2.imshow("th1", th1)
		
		cv2.imshow("Frame", frame)
		keyboard = cv2.waitKey(30)

		# if (current_count - previous_count) > 150:
		# 	pprint("Event triggered, press any key to continue")
		# 	keyboard = cv2.waitKey(-1)
		previous_count = current_count
		# if keyboard != -1:
		# 	print(keyboard)
		if keyboard == 51:
			pprint("Next file")
			video_index += 1
			break
		if keyboard == 49:
			pprint("Previous file")
			video_index -= 1
			break
		if keyboard == 32:
			pprint("Pause")
			cv2.waitKey(-1)
		if keyboard == 27:
			break_flag = True
			break
	capture.release()
	if break_flag:
		break

