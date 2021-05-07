import os
import re
import cv2
import numpy as np

# la reque

regexfulldir = re.compile("(.*False positives.*avi$)")
regexstation = re.compile(r"(.*?\\)(.*?)(\d+-\d+-\d+)(\\.*?)")
rootdir = "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV"
dirliststring = ["14-11-2019", "02-10-2019", "29-10-2019", "01-11-2019", "26-10-2019", "28-10-2019"]



dirlistpc = [
	"C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Anillaco 14-11-2019/False positives/",
	"C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/La Maria 02-10-2019/False positives/",
	"C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/La Maria 29-10-2019/False positives/",
	"C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Santa Maria 01-11-2019/False positives/",
	"C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Santa Maria 26-10-2019/False positives/",
	"C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Santa Maria 28-10-2019/False positives/"]

filelisthdd = [
	"E:/Campanha-2019/Anillaco/14-11-2019/2019-11-14_020120_JV_W.avi",
	"E:/Campanha-2019/La Maria/02-10-2019/2019-10-02_014427_JV.avi",
	"E:/Campanha-2019/La Maria/29-10-2019/2019-10-29_002852_JV.avi",
	"E:/Campanha-2019/Santa Maria/01-11-2019/2019-11-01_222054_JV.avi",
	"E:/Campanha-2019/Santa Maria/26-10-2019/2019-10-26_213353_JV_NAOAPAGAR.avi",
	"E:/Campanha-2019/Santa Maria/28-10-2019/2019-10-28_194528_JV_NAOAPAGAR.avi"]

hddlist= [
	"E:/Campanha-2019/Anillaco/14-11-2019/2019-11-14_020120_JV_W.avi",
	"E:/Campanha-2019/La Maria/02-10-2019/2019-10-02_014427_JV.avi",
	"E:/Campanha-2019/La Maria/24-10-2019/2019-10-24_210457_563.avi",
	"E:/Campanha-2019/La Maria/29-10-2019/2019-10-29_002852_JV.avi",
	"E:/Campanha-2019/Santa Maria/01-11-2019/2019-11-01_222054_JV.avi",
	"E:/Campanha-2019/Santa Maria/08-11-2019/2019-11-08_202545_JV.avi",
	"E:/Campanha-2019/Santa Maria/08-11-2019/2019-11-09_005913_JV.avi",
	"E:/Campanha-2019/Santa Maria/18-10-2019/2019-10-19_012100_JV_SEMDADOS.avi",
	"E:/Campanha-2019/Santa Maria/24-10-2019/2019-10-24_212139_454.avi",
	"E:/Campanha-2019/Santa Maria/26-10-2019/2019-10-26_213353_JV_NAOAPAGAR.avi",
	"E:/Campanha-2019/Santa Maria/28-10-2019/2019-10-28_194528_JV_NAOAPAGAR.avi"]

Anillaco14 = []

LaMaria02 = []

LaMaria29 = []

SantaMaria01 = []

SantaMaria26 = []

SantaMaria28 = []

Stations = [Anillaco14, LaMaria02, LaMaria29, SantaMaria01, SantaMaria26, SantaMaria28]

for root,  dirs, files in os.walk(rootdir):
	for file in files:
		path = os.path.join(root,file)
		date = regexstation.match(path)		
		for dir, station in zip(dirliststring, Stations):
			try:
				if regexfulldir.match(path) and date.group(3) in dir:
					firstframe =  str(file[:-4])
					capture = cv2.VideoCapture(cv2.samples.findFileOrKeep(path))
					length = capture.get(cv2.CAP_PROP_FRAME_COUNT)
					# print(path, firstframe, length)
					# print(os.path.join(root,file))
					if length < 500:
						station.append([int(firstframe), length])
			except:
				None
# Stations = np.array(Stations, dtype="object")
# print(Stations)

i = 0
for dir in Stations:
	print(dirlistpc[i], filelisthdd[i])
	capture = cv2.VideoCapture(cv2.samples.findFileOrKeep(filelisthdd[i]))

	for file in dir:
		start = file[0]
		length = int(file[1])
		# print(start, length)
		ret, frame = capture.read()

		capture.set(cv2.CAP_PROP_POS_FRAMES, start - 32)
		p = "{}Clips/{} - original.avi".format(dirlistpc[i], start - 32)
		writer = cv2.VideoWriter(p, 0, 30, (int(capture.get(3)), int(capture.get(4))))
		for frames in range(length):
			ret, frame = capture.read()
			# print(ret)
			writer.write(frame)
			# cv2.imshow("Frame", frame)
			# cv2.waitKey(-1)
 
		writer.release()
		cv2.destroyAllWindows()
	capture.release()
	i += 1

