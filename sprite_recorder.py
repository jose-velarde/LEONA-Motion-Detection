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
from termcolor import colored  # pip install termcolor
from pprint import pprint
import os
import re


class KeyClipWriter:
    """Clip recorder class, continuosly records opencv frames to a buffer and writes
    them to an file when finished
    """

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

    # kcw.start(p, cv2.VideoWriter_fourcc(*args["codec"]), args["fps"])
    def start(self, outputPath, fourcc, fps):
        # indicate that we are recording, start the video writer,
        # and initialize the queue of frames that need to be written
        # to the video file
        self.recording = True
        self.writer = cv2.VideoWriter(
            outputPath,
            0,
            fps,
            (self.frames[0].shape[1], self.frames[0].shape[0]),
            False,
        )
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
    """Not implemented

    Args:
        image (list): opencv frame

    Returns:
        list: opencv frame with colored isolated pixels groups
    """
    retval, labels = cv2.connectedComponents(image)
    # Filter groups
    N = 50
    num = labels.max()
    for i in range(1, num + 1):
        pts = np.where(labels == i)
        if len(pts[0]) < N:
            labels[pts] = 0
    # Color groups
    label_hue = np.uint8(179 * labels / np.max(labels))
    blank_ch = 255 * np.ones_like(label_hue)
    labeled_img = cv2.merge([label_hue, blank_ch, blank_ch])
    # cvt to BGR for display
    labeled_img = cv2.cvtColor(labeled_img, cv2.COLOR_HSV2BGR)
    # set bg label to black
    labeled_img[label_hue == 0] = 0
    return labeled_img


def thresh_func(
    frame, mode="bin", threshold=8, block=3, substract=15, close_kernel=0, open_kernel=0
):
    """Apply morphological transformations and thresholding.
    More about transformations: https://docs.opencv.org/3.4/d9/d61/tutorial_py_morphological_ops.html
    More about thresholding: https://docs.opencv.org/3.4/d7/d4d/tutorial_py_thresholding.html

    Args:
        frame (list): opencv frame
        mode (str, optional): thresholding mode one of bin, bin+otsu, mean, gaussian . Defaults to "bin".
        threshold (int, optional): pixel brightness threshold, 8 for dark images, larger for brighter images. Defaults to 8.
        block (int, optional): adaptative threshold parameter. Defaults to 3.
        substract (int, optional): adaptative threshold parameter. Defaults to 15.
        close_kernel ((int, int), optional): kernel size, recommended tuple (10,2). Defaults to 0.
        open_kernel ((int, int), optional): kernel size, recommended tuple (3,3). Defaults to 0.

    Returns:
        list: opencv frame
    """
    if mode == "bin":
        ret1, th1 = cv2.threshold(frame, threshold, 255, cv2.THRESH_BINARY)
    elif mode == "bin+otsu":
        ret1, th1 = cv2.threshold(
            frame, threshold, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU
        )
    elif mode == "mean":
        th1 = cv2.adaptiveThreshold(
            frame, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, block, substract
        )
        th1 = cv2.bitwise_not(th1)
        ret1 = None
    elif mode == "gaussian":
        th1 = cv2.adaptiveThreshold(
            frame,
            255,
            cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
            cv2.THRESH_BINARY,
            block,
            substract,
        )
        th1 = cv2.bitwise_not(th1)
        ret1 = None
    if close_kernel:
        th1 = cv2.morphologyEx(th1, cv2.MORPH_CLOSE, np.ones(close_kernel, np.uint8))
    if open_kernel:
        th1 = cv2.morphologyEx(th1, cv2.MORPH_OPEN, np.ones(open_kernel, np.uint8))
    return ret1, th1


def split_frame(frame, n_rows, n_columns):
    """Splits the opencv frame

    Args:
        frame (list): opencv frame
        n_rows (int): number of rows to split the frame into
        n_columns (int): number of columns to split the frame into

    Returns:
        list: opencv frame sections
    """
    height, width = frame.shape
    roi_height = int(height / n_rows)
    roi_width = int(width / n_columns)
    sections = []
    count = []
    for row in range(0, n_rows):
        for col in range(0, n_columns):
            tmp_image = frame[
                row * roi_height : (row + 1) * roi_height,
                col * roi_width : (col + 1) * roi_width,
            ]
            sections.append(tmp_image)
            count.append(cv2.countNonZero(tmp_image))
    return sections, count


def draw_grid(frame, n_rows, n_columns):
    """Show division lines for each section in a frame

    Args:
        frame (list): opencv frame
        n_rows (int): numer of section rows
        n_columns (int): number of section columns
    """
    height, width = frame.shape
    roi_height = int(height / n_rows)
    roi_width = int(width / n_columns)

    for row in range(0, n_rows):
        cv2.line(
            frame,
            (0, (row + 1) * roi_height),
            (width, (row + 1) * roi_height),
            (255, 255, 255),
            1,
        )
    for col in range(0, n_columns):
        cv2.line(
            frame,
            ((col + 1) * roi_width, 0),
            ((col + 1) * roi_width, height),
            (255, 255, 255),
            1,
        )


def get_videos_list(rootdir):
    """Recursively lookup .avi files in rootdir and subfolders to return their full path string in a list

    Args:
        rootdir (string): path containing video files

    Returns:
        list: list containing the fullpath of each avi file
    """
    # Look for unedited video clips
    regexavi = re.compile("(.*.avi$)")
    video_list = []
    for root, dirs, files in os.walk(rootdir):
        for file in files:
            path = os.path.join(root, file)
            string_match = regexavi.match(path)
            if string_match:
                video_list.append(path)
    return video_list


# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-f", "--fps", type=int, default=30, help="FPS of output video")
ap.add_argument("-c", "--codec", type=str, default="mp4v", help="codec of output video")
ap.add_argument(
    "-b", "--buffer-size", type=int, default=32, help="buffer size of video clip writer"
)
args = vars(ap.parse_args())

# path = "C:/Users/Rede LEONA/Downloads/Jose Downloads/Videos from LEONA2 HD/La Maria/"
# path = "C:/Users/JoseVelarde/Downloads/Personal/LEONA/Videos"
# path = "C:/Users/Rede LEONA/Downloads/Jose Downloads/Videos from LEONA2 HD/Anillaco 2018-12-14/NARROW FOV CAMERA/"
# path = "C:/Users/Rede LEONA/Downloads/Jose Downloads/Videos from LEONA2 HD/Anillaco 2018-12-14/WIDE FOV CAMERA/"
path = "C:\Users\Rede LEONA\Downloads\Jose Downloads\Videos from LEONA2 HD\Anillaco 2018-12-14\WIDE FOV CAMERA"
video_list = get_videos_list(path)
save_folder = "Footage Review/"
for video in [video_list[0]]:
    pprint("Playing -> {}".format(video), width=180)

    # initialize opencv object
    capture = cv2.VideoCapture(cv2.samples.findFileOrKeep(video))
    starting_frame = 0
    capture.set(cv2.CAP_PROP_POS_FRAMES, starting_frame)

    # initialize key clip writer (with buffer size)
    kcw = KeyClipWriter(bufSize=32)

    # Triggering mode selection
    # False: DELTA MODE, 			bright pixel delta > min_delta
    # True : AVERAGE+DELTA MODE, 	bright pixel count > mean count + min_delta
    average_flag = True
    # minimum difference of white pixels between frames to trigger detection
    min_delta = 50  # 50~100 works alright, increase if it triggers a lot (usually due to house/street lights)

    # thresholding function parameters
    threshold = 30  # 8 for darker images (i.e. wide Anillaco camera for 14/12/2018)
    # 30 used for dark images (i.e. narrow Anillaco camera for 14/12/2018)
    mode = "bin"
    close_kernel = (10, 2)
    open_kernel = (3, 3)
    # set but not used parameters
    block = 5
    substract = 10

    # initialize stacked image
    stacked_image = 0
    # Number of sections to divide the frame
    n_rows = 4
    n_columns = 4
    # number of previous frames taken into account to take the average of white pixel count
    window = 32

    # initialize a buffer object to store bright pixel count
    count_stack = deque(maxlen=window)
    # initialize the consecutive number of frames that have *not* contained any action
    consec_frames = 0
    update_consec_frames = False

    # keep looping
    while True:
        # Listen for inputs
        keyboard = cv2.waitKey(30)
        # Increase the consecutive frames counter if recording
        if update_consec_frames:
            consec_frames += 1
        # Grab the current frame
        #! FILE REPRODUCTION START
        ret, frame = capture.read()
        # Stop file reproduction
        if frame is None:
            # if capture.get(cv2.CAP_PROP_POS_FRAMES) == 300000:
            # capture.set(cv2.CAP_PROP_POS_FRAMES, 0)
            # continue
            print("File end")
            break

        # frame: original data
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        # current_frame: gps time covered
        current_frame = frame.copy()
        cv2.rectangle(current_frame, (0, 420), (710, 465), (0, 0, 0), -1)

        #! Get 1st frame data for delta calculations and skip to next iterations
        if (capture.get(cv2.CAP_PROP_POS_FRAMES)) == (starting_frame + 1):
            previous_frame = current_frame.copy()
            # Reset white pixel count of previous frames
            count_stack.clear()
            # thresholding and white pixel counting
            ret1, th1 = thresh_func(
                current_frame,
                mode,
                threshold,
                block,
                substract,
                close_kernel,
                open_kernel,
            )
            previous_sections, previous_count = split_frame(th1, n_rows, n_columns)
            continue
        #! Optional text indicators on video: current frame and recording (OUTDATED)
        # if kcw.recording:
        # 	cv2.rectangle(frame, (600,2), (680,20), (255,255,255), -1)
        # 	cv2.putText(frame, "recording", (605, 15),
        # 		cv2.FONT_HERSHEY_SIMPLEX, 0.5 , (0,0,0))
        # Insert the current frame on the top left
        # cv2.rectangle(gray, (10, 2), (100,20), (255,255,255), -1)
        # cv2.putText(frame, str(capture.get(cv2.CAP_PROP_POS_FRAMES)), (15, 15),
        # 	cv2.FONT_HERSHEY_SIMPLEX, 0.5 , (0,0,0))
        #! Background extraction and thresholding
        th1 = cv2.absdiff(previous_frame, current_frame)
        # filter bright pixels of the current frame
        ret1, th1 = thresh_func(
            th1, mode, threshold, block, substract, close_kernel, open_kernel
        )
        #! SECTIONS DIVISION
        # Count the ammount of bright pixels in the current frame, for each section
        sections, count = split_frame(th1, n_rows, n_columns)
        # Fill the moving array for average frame count calculation
        count_stack.append(count)
        #! BRIGHT PIXEL DELTA CALCULATION
        delta = np.subtract(count, previous_count)
        delta_total = sum(count) - sum(previous_count)

        stack_mean = []
        # Average window calculations
        for section in range(n_rows * n_columns):
            total = 0
            for frame_count in count_stack:
                total += frame_count[section]
            stack_mean.append(int(total / len(count_stack)))

        # * Uncomment to print bright pixels count for: current frame count || delta count || count_mean

        # for rows in range(n_rows):
        #     print(" |".join(str(e).rjust(5) for e in count[rows*n_columns:(rows+1)*n_columns]), end = "")
        #     print(colored("    ||", "red"), end = "")
        #     print(" |".join(str(e).rjust(5) for e in delta[rows*n_columns:(rows+1)*n_columns]), end = "")
        #     print(colored("    ||", "red"), end = "")
        #     print(" |".join(str(e).rjust(5) for e in stack_mean[rows*n_columns:(rows+1)*n_columns]), end = "")
        #     print()
        # print()

        previous_frame = current_frame.copy()
        previous_sections = sections
        previous_count = count
        # Compare the current bright pixel count with the average
        # pixel count in the window
        if not average_flag:
            if any(pixel_diff > min_delta for pixel_diff in delta):
                print(
                    "Event triggered, press any key to continue",
                    capture.get(cv2.CAP_PROP_POS_FRAMES),
                    end="",
                )
                print(colored("DELTA MODE", "red"))
                consec_frames = 0
                update_consec_frames = True
                # # Delete the pixel count from the trigger frame event,
                # # it modifies the average too much
                # count_stack.pop()
                stacked_image += frame

                if not kcw.recording:
                    if not os.path.exists(
                        "{}/{}".format(save_folder, video[len(path) : -4])
                    ):
                        os.makedirs("{}/{}".format(save_folder, video[len(path) : -4]))
                    p = "{}/{}/{} - original.avi".format(
                        save_folder,
                        video[len(path) : -4],
                        int(capture.get(cv2.CAP_PROP_POS_FRAMES)),
                    )
                    with open(
                        "{}.txt".format(save_folder, video[len(path) : -4]), "w"
                    ) as file:
                        pass
                    kcw.start(p, cv2.VideoWriter_fourcc(*args["codec"]), args["fps"])
                # Pause video if trigger ocurred
                # keyboard = cv2.waitKey(-1)
        else:
            if (
                any(
                    section_count > mean + min_delta
                    for section_count, mean in zip(count, stack_mean)
                )
                and len(count_stack) == window
            ):
                print(
                    "Event triggered, press any key to continue",
                    capture.get(cv2.CAP_PROP_POS_FRAMES),
                    end=" ",
                )
                print(colored("AVERAGE+DELTA MODE", "red"))
                # Start consecutive frames count, recording stops when consec_frames == buffer_size
                consec_frames = 0
                update_consec_frames = True
                # # Delete the pixel count from the trigger frame event,
                # # it modifies the average too much
                # count_stack.pop()
                # Insert the triggering frame into a stacked image
                stacked_image += frame
                # Create video file clip if not recording, insert triggered frame number on file name
                if not kcw.recording:
                    if not os.path.exists(
                        "{}/{}".format(save_folder, video[len(path) : -4])
                    ):
                        os.makedirs("{}/{}".format(save_folder, video[len(path) : -4]))
                        filename = "./{}/{}.txt".format(
                            save_folder, video[len(path) : -4]
                        )
                        with open(filename, "w") as nf:
                            pass
                    p = "{}/{}/{} - original.avi".format(
                        save_folder,
                        video[len(path) : -4],
                        int(capture.get(cv2.CAP_PROP_POS_FRAMES)),
                    )

                    kcw.start(p, cv2.VideoWriter_fourcc(*args["codec"]), args["fps"])
                # Pause video if trigger ocurred
                # keyboard = cv2.waitKey(-1)

                # TODO: Countours test
                # 	# Find and draw contours in the mask
                # 	# cnts = cv2.findContours(th1, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
                # 	# cnts = imutils.grab_contours(cnts)
                # 	# cv2.drawContours(frame, cnts, -1, (0,255,0), 1)
                # 	# Write to images the grouping of contiguous pixels
                # 	# cv2.imwrite("./Grouped frames/grouping_test_frame{}.png".format(str(capture.get(cv2.CAP_PROP_POS_FRAMES))), GroupPixels(th1))

        # update the key frame clip buffer
        kcw.update(frame)
        # if we are recording and reached a threshold on consecutive
        # number of frames with no triggers, stop recording the clip
        if kcw.recording and consec_frames == args["buffer_size"]:
            # print("stop recording at ", capture.get(cv2.CAP_PROP_POS_FRAMES))
            # print("stop recording")
            kcw.finish()
            update_consec_frames = False
            consec_frames = 0
            cv2.imwrite(p[:-4] + ".png", stacked_image)
            stacked_image = 0

        #! SHOW FRAMES

        # show original frame
        cv2.imshow("Frame", frame)
        # show frame after thresholding, comment to hide
        cv2.imshow("Threshold", th1)

        # * show frame after thresholding with split lines, uncomment to hide
        # grid_th1 = th1.copy()
        # draw_grid(grid_th1, n_rows, n_columns)
        # cv2.imshow("ThresholdLines", grid_th1)

        if keyboard == 49:
            capture.set(
                cv2.CAP_PROP_POS_FRAMES, capture.get(cv2.CAP_PROP_POS_FRAMES) - 500
            )
        if keyboard == 51:
            capture.set(
                cv2.CAP_PROP_POS_FRAMES, capture.get(cv2.CAP_PROP_POS_FRAMES) + 500
            )
        if keyboard == 32:
            pprint("Pause at {}".format(capture.get(cv2.CAP_PROP_POS_FRAMES)))
            cv2.waitKey(-1)

        # Escape video reproduction
        if keyboard == 27:
            pprint("Break called")
            break
    # finish recording if any
    if kcw.recording:
        kcw.finish()
    # cleanup
    cv2.destroyAllWindows()
