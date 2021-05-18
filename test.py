import cv2

cptec = cv2.imread("./S11635387_201910010000.jpg")     #(flag = 0 or 1 or -1)
cptec = cv2.applyColorMap(cptec, cv2.COLORMAP_JET)

cv2.namedWindow("cptec", cv2.WINDOW_NORMAL)
cv2.resizeWindow("cptec", 720, 640)
cv2.imshow("cptec", cptec)
cv2.waitKey(-1)
cv2.destroyAllWindows()