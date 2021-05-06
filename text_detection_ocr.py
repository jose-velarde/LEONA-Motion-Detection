import cv2
import pytesseract
import numpy as np
import re
from get_first_frame import get_png_dirlist


pytesseract.pytesseract.tesseract_cmd = 'C:\\Program Files\\Tesseract-OCR\\tesseract.exe'

kernel = np.ones((3,2),np.uint8)
regex_hhmmss = re.compile("(.*)(\d{2})\:(\d{2})\:(\d{2})(.*)")
image_list = get_png_dirlist()
# print(image_list)
for image in image_list:
	img = cv2.imread(image)
	img = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
	ret2, img = cv2.threshold(img, 150, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
	# img = cv2.medianBlur(img, 3)
	img = cv2.morphologyEx(img, cv2.MORPH_CLOSE, kernel)
	img = cv2.bitwise_not(img)
	# print(image)
	hImg, wImg = img.shape
	# conf = r'--oem 3 --psm 6 outputbase digits'
	# boxes = pytesseract.image_to_boxes(img, config=conf)
	boxes = pytesseract.image_to_boxes(img)
	time = []
	for b in boxes.splitlines():
		b = b.split(' ')
		x, y, w, h = int(b[1]), int(b[2]), int(b[3]), int(b[4])
		img = cv2.cvtColor(img, cv2.COLOR_RGB2RGBA)
		# cv2.rectangle(img, (x,hImg- y), (w,hImg- h), (0, 0, 255), 1)
		cv2.putText(img,b[0],(x,hImg- y-50),cv2.FONT_HERSHEY_SIMPLEX,1,(0,0,255),2)
		time.append(b[0])
	try:
		hhmmss = regex_hhmmss.match("".join(time))
		print("{}:{}:{}".format(hhmmss.group(2), hhmmss.group(3), hhmmss.group(4)))
	except:
		pass
	cv2.imshow('img', img)
	keyboard = cv2.waitKey(0)
	if keyboard == 32:
		break
