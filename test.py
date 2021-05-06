# import the necessary packages
from collections import deque
from threading import Thread
from queue import Queue
import imutils
import argparse
import datetime
import time
import cv2
import numpy as np
from statistics import mean, stdev

class KeyClipWriter:
	def __init__(self, bufSize=32, timeout=1.0):
		# store the maximum buffer size of frames to be kept
		# in memory along with the sleep timeout during threading
		self.bufSize = bufSize
		self.timeout = timeout
		# initialize the buffer of frames, queue of frames that
		# need to be written to file, video writer, writer thread,
		# and boolean indicating whether recording has started or not
		self.frames = deque(maxlen=bufSize)
		self.Q = None
		self.writer = None
		self.thread = None
		self.recording = False

	def update(self, frame):
		# update the frames buffer
		self.frames.appendleft(frame)
		# if we are recording, update the queue as well
		if self.recording:
			self.Q.put(frame)

	def start(self, outputPath, fourcc, fps):
		# indicate that we are recording, start the video writer,
		# and initialize the queue of frames that need to be written
		# to the video file
		self.recording = True
		self.writer = cv2.VideoWriter(outputPath, 0, 30,
			(self.frames[0].shape[1], self.frames[0].shape[0]))
		self.Q = Queue()
		# loop over the frames in the deque structure and add them
		# to the queue
		for i in range(len(self.frames), 0, -1):
			self.Q.put(self.frames[i - 1])
		# start a thread write frames to the video file
		self.thread = Thread(target=self.write, args=())
		self.thread.daemon = True
		self.thread.start()

	def write(self):
		# keep looping
		while True:
			# if we are done recording, exit the thread
			if not self.recording:
				return
			# check to see if there are entries in the queue
			if not self.Q.empty():
				# grab the next frame in the queue and write it
				# to the video file
				frame = self.Q.get()
				self.writer.write(frame)
			# otherwise, the queue is empty, so sleep for a bit
			# so we don't waste CPU cycles
			else:
				time.sleep(self.timeout)

	def flush(self):
		# empty the queue by flushing all remaining frames to file
		while not self.Q.empty():
			frame = self.Q.get()
			self.writer.write(frame)

	def finish(self):
		# indicate that we are done recording, join the thread,
		# flush all remaining frames in the queue to file, and
		# release the writer pointer
		self.recording = False
		self.thread.join()
		self.flush()
		self.writer.release()

def GroupPixels(image):
	retval, labels = cv2.connectedComponents(image)
	# Filter groups
	N = 50
	num = labels.max()
	for i in range(1, num+1):
		pts =  np.where(labels == i)
		if len(pts[0]) < N:
			labels[pts] = 0
	#Color groups
	label_hue = np.uint8(179*labels/np.max(labels))
	blank_ch = 255*np.ones_like(label_hue)
	labeled_img = cv2.merge([label_hue, blank_ch, blank_ch])
	# cvt to BGR for display
	labeled_img = cv2.cvtColor(labeled_img, cv2.COLOR_HSV2BGR)
	# set bg label to black
	labeled_img[label_hue==0] = 0
	return labeled_img

# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-f", "--fps", type=int, default=30,
	help="FPS of output video")
ap.add_argument("-c", "--codec", type=str, default="mp4v",
	help="codec of output video")
ap.add_argument("-b", "--buffer-size", type=int, default=32,
	help="buffer size of video clip writer")
args = vars(ap.parse_args())


# path = "C:/Users/Rede LEONA/Downloads/Jose Downloads/Check for triangulation/Santa Maria/18-10-2019/2019-10-19_012100_JV_SEMDADOS.avi"
path = "elve.avi"
# path = "E:/Campanha-2019/La Maria/29-10-2019/2019-10-29_002852_JV.avi"
capture = cv2.VideoCapture(cv2.samples.findFileOrKeep(path))
# initialize key clip writer and the consecutive number of
# frames that have *not* contained any action
kcw = KeyClipWriter(bufSize=args["buffer_size"])

kernel = np.ones((5,5),np.uint8)
# Define bright pixel count array of max size "window"
window = 10
min_pixel_delta = 50
# threshold = 62
threshold = 0
stacked_image = 0
average = deque(maxlen = window)
consec_frames = 0
update_consec_frames = False
capture.set(cv2.CAP_PROP_POS_FRAMES, 0)

# keep looping
while True:
	# Grab the current frame
	ret, frame = capture.read()
	# Loop video
	if frame is None:
	# if capture.get(cv2.CAP_PROP_POS_FRAMES) == 300000:
		# capture.set(cv2.CAP_PROP_POS_FRAMES, 0)
		# continue
		break
	# Increase the consecutive frames counter if a trigger occurred
	if update_consec_frames:
		consec_frames += 1
	# if kcw.recording:
	# 	cv2.rectangle(frame, (600,2), (680,20), (255,255,255), -1)
	# 	cv2.putText(frame, "recording", (605, 15),
	# 		cv2.FONT_HERSHEY_SIMPLEX, 0.5 , (0,0,0))
	# Cover the GPS time
	cv2.rectangle(frame, (0, 425), (710,465), (0,0,0), -1)
	# Insert the current frame on the top left
	cv2.rectangle(frame, (10, 2), (100,20), (255,255,255), -1)
	cv2.putText(frame, str(capture.get(cv2.CAP_PROP_POS_FRAMES)), (15, 15),
		cv2.FONT_HERSHEY_SIMPLEX, 0.5 , (0,0,0))
	# blur the frame and convert it to the GRAY color space
	gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
	gray = cv2.medianBlur(gray, 5)
	# filter bright pixels of the current frame
	ret1, th1 = cv2.threshold(gray, threshold, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
	th1 = cv2.morphologyEx(th1, cv2.MORPH_CLOSE, kernel)
	# Count the ammount of bright pixels in the current frame
	currentcount = cv2.countNonZero(th1)
	# Fill the moving array for average frame count calculation
	average.append(currentcount)
	# if len(average) > 1:
		# print("{} - {} = {}, {} {}".format(average[-2], average[-1], average[-2] - average[-1],currentcount, mean(average)))
	# Compare the current bright pixel count with the average
	# pixel count in the window
	if currentcount > (mean(average) + min_pixel_delta):
		consec_frames = 0
		update_consec_frames = True
		# Delete the pixel count from the trigger frame event,
		# it modifies the average too much
		average.pop()
		# print("trigger at ", capture.get(cv2.CAP_PROP_POS_FRAMES))
		# print("average ", currentcount, "difference ", currentcount - mean(average))
		# Stack the frame of the detected event
		stacked_image += frame
		# Find and draw contours in the mask
		cnts = cv2.findContours(th1, cv2.RETR_EXTERNAL, 
			cv2.CHAIN_APPROX_SIMPLE)
		cnts = imutils.grab_contours(cnts)
		cv2.drawContours(frame, cnts, -1, (0,255,0), 1)
		# Write to images the grouping of contiguous pixels
		# cv2.imwrite("./Grouped frames/grouping_test_frame{}.png".format(str(capture.get(cv2.CAP_PROP_POS_FRAMES))), GroupPixels(th1))
		# if not already recording, start recording
		if not kcw.recording:
			# timestamp = datetime.datetime.now()
			# p = "{} - {}.avi".format("test",
			# 	timestamp.strftime("%Y%m%d-%H%M%S"))
			p = "{}.avi".format(int(capture.get(cv2.CAP_PROP_POS_FRAMES)))
			kcw.start(p, cv2.VideoWriter_fourcc(*args["codec"]),
				args["fps"])
	# update the key frame clip buffer
	kcw.update(frame)
	# if we are recording and reached a threshold on consecutive
	# number of frames with no action, stop recording the clip
	if kcw.recording and consec_frames == args["buffer_size"]:
		# print("stop recording at ", capture.get(cv2.CAP_PROP_POS_FRAMES))
		# print("stop recording")
		kcw.finish()
		update_consec_frames = False
		consec_frames = 0
		# filter the stacked image and draw contours
		brightmask = cv2.cvtColor(stacked_image, cv2.COLOR_BGR2GRAY)
		brightmask = cv2.medianBlur(brightmask, 5)
		ret2, th2 = cv2.threshold(gray, threshold, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
		th2 = cv2.morphologyEx(th2, cv2.MORPH_CLOSE, kernel)
		contours = cv2.findContours(th2, cv2.RETR_EXTERNAL, 
			cv2.CHAIN_APPROX_SIMPLE)		
		contours = imutils.grab_contours(contours)
		cv2.drawContours(stacked_image, contours, -1, (0,255,0), 1)
		# cv2.imshow("Stacked", stacked_image)
		cv2.imwrite(p[:-4] + ".png", stacked_image)
		stacked_image = 0
		# temp = cv2.VideoCapture(p)
		# print("{} Frame count is {}".format(p, temp.get(cv2.CAP_PROP_FRAME_COUNT)))
	# show the frame
	cv2.imshow("Frame", frame)
	# Pause video reproduction after a trigger event
	# if currentcount > mean(average)+ min_pixel_delta:
	# 	cv2.waitKey(-1)
	# Escape video reproduction
	keyboard = cv2.waitKey(30)
	if keyboard == 49:
		capture.set(cv2.CAP_PROP_POS_FRAMES, capture.get(cv2.CAP_PROP_POS_FRAMES) - 500)
	if keyboard == 51:
		capture.set(cv2.CAP_PROP_POS_FRAMES, capture.get(cv2.CAP_PROP_POS_FRAMES) + 500)
	if keyboard == 32:
		cv2.waitKey(-1)
	if keyboard == 27:
		break
# if we are in the middle of recording a clip, wrap it up
if kcw.recording:
	kcw.finish()
# do a bit of cleanup
cv2.destroyAllWindows()
