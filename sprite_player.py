import os
import cv2  # pip install opencv-python
import re
from pprint import pprint
import numpy as np  # pip install numpy
from matplotlib import pyplot as plt  # pip install matplotlib
from numpy.core.fromnumeric import size
from numpy.core.shape_base import stack
from numpy.lib.function_base import average
from termcolor import colored  # pip intall termcolor
from skimage import measure  # pip install scikit-image
from collections import deque
from statistics import mean


def get_clips_in_folder(rootdir: str, clip_type: str):
    """Search .avi files in @rootdir folder and subfolders

    Args:
        rootdir (str): Folder to search ending in .../Positives/
        clip_type (str): Folder name -> 'Clips' or 'Deinterlaced'

    Returns:
        list: list of fullpath (str)
    """
    regexfulldir = re.compile(rf"(.*{clip_type}.*avi$)")
    file_list = []

    for root, dirs, files in os.walk(rootdir):
        for file in files:
            fullpath = os.path.join(root, file)
            if regexfulldir.match(fullpath):
                file_list.append(fullpath)
                # print(path, frame_count)

    return file_list


def split_frame(frame, n_rows, n_columns):
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
    #! ROI TEST, Region of interest, dividing each frame in parts and plot histograms
    # ? Very slow and the histograms do not show relevant information during the trigger event
    # Display the resulting sub-frame
    # for row in range(0, n_rows):
    # 	for col in range(0, n_columns):
    # 		cv2.imshow(str(row*n_columns+col+1), sections[row*n_columns+col])
    # 		cv2.moveWindow(str(row*n_columns+col+1), 1000+(col*roi_width), 50+(row*roi_height))
    # 		hist, bins = np.histogram(sections[row*n_columns+col].ravel(), int(cutout), [start, cutout])
    # 		plt.subplot(n_rows, n_columns, row*n_columns+col+1)
    # 		plt.plot(hist, color = "r")
    # 		plt.xlim([start, cutout])
    # 		plt.ylim([0, 2000])
    # 		plt.pause(0.001)
    # 		plt.clf()


def draw_grid(frame, n_rows, n_columns):
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


def plot_histogram(frames, start, cutout, maxy, imode_flag):
    #! FRAMES MUST BE INPUT AS LIST, i.e. [image] OR [image1, image2]
    if imode_flag:
        plt.ion()
        figure = plt.figure(1)

    for i, frame in enumerate(frames):
        hist, bins = np.histogram(frame.ravel(), int(cutout), [start, cutout])
        plt.subplot(1, len(frames), i + 1)
        plt.plot(hist, color="r")
        plt.xlim([start, cutout])
        plt.ylim([0, maxy])
    plt.pause(0.001)
    plt.clf()


def thresh_func(
    frame, mode="bin", threshold=8, block=3, substract=15, close_kernel=0, open_kernel=0
):
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


def deinterlace(mode, frame):
    first_field = frame.copy()
    second_field = frame.copy()
    if mode == "discard":
        first_field[1:-1:2] = 0
        second_field[2:-1:2] = 0
    elif mode == "linear":
        first_field[1:-1:2] = frame[0:-2:2] / 2 + frame[2::2] / 2
        second_field[2:-1:2] = frame[1:-2:2] / 2 + frame[3::2] / 2
    return first_field, second_field


color_dict = {
    "1": [0, 0, 128],
    "2": [0, 0, 192],
    "3": [0, 0, 255],
    "4": [0, 64, 255],
    "5": [0, 128, 255],
    "6": [0, 192, 255],
    "7": [0, 255, 255],
    "8": [64, 255, 192],
    "9": [128, 255, 128],
    "10": [192, 255, 64],
    "11": [255, 255, 0],
    "12": [255, 192, 0],
    "13": [255, 128, 0],
    "14": [255, 64, 0],
    "15": [255, 0, 0],
    "16": [192, 0, 0],
    "17": [128, 0, 0],
}

# full_videos_dir = "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV"
# full_videos_dir = "C:/Users/sauli/OneDrive/Desktop/Videos/Selected"
full_videos_dir = "C:/Users/JoseVelarde/Downloads/Personal/LEONA/Videos/"

# footage_dir = "C:/Users/JoseVelarde/Downloads/Personal/LEONA/LEONA-Motion-Detection/Footage review/"
footage_dir = "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/"
# clips_dir = "C:/Users/JoseVelarde/Downloads/Personal/LEONA/LEONA-Motion-Detection/Footage review/2018-12-13_235655_533/Positives/"
clips_dir = [
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/2018-12-14_04 19 UT - 06 32 UT _ Wide/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/2018-12-14_06 39  UT - 06 43 UT _ Wide/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/2018-12-14_06 57  UT - 07 24 UT _ Wide/Positives/",
]
clips_dir = clips_dir[0]

obs_regex = re.compile(rf"({footage_dir})([^\/]*)(.+)")
observation_folder = obs_regex.match(clips_dir).group(2) + "/"

# clip_type = "Clips"
# clip_type = "Deinterlaced"
clip_type = "original"
video_list = get_clips_in_folder(clips_dir, clip_type)
video_index = 0

kernel = np.ones((5, 5), np.uint8)
imode_flag = True

threshold = 30  # 8
mode = "bin"
block = 5
substract = 10
close_kernel = (10, 2)
open_kernel = (3, 3)

mode2 = "bin"
block2 = 5
substract2 = 10
close_kernel2 = 0
open_kernel2 = 0

n_rows = 4
n_columns = 4

min_delta = 50
window = 5

count_stack = deque(maxlen=window)
count_stack2 = deque(maxlen=window)
count_stack3 = deque(maxlen=window)

deinterlace_mode = "discard"
# deinterlace_mode = "linear"

while True:
    # skip_trigger_flag = True
    skip_trigger_flag = False
    # break_flag = True
    break_flag = False
    # calibration_flag = True
    calibration_flag = False
    absdiff_flag = True
    # absdiff_flag = False
    # raw_deinterlace_flag = True
    raw_deinterlace_flag = False
    # deinterlace_flag = True
    deinterlace_flag = False
    # average_flag = True
    average_flag = False
    # labeling_flag = True
    labeling_flag = False
    colormap_flag = True
    # colormap_flag = False
    if video_index == len(video_list):
        video_index = 0

    if not os.path.exists("Manual review/{}".format(observation_folder + clip_type)):
        os.makedirs("Manual review/{}".format(observation_folder + clip_type))
    record_dir = "./Manual review/{}.txt".format(observation_folder + clip_type)
    # with open(record_dir, "a") as record_file:
    #     print(
    #         "New review session initiated from frame number: {}".format(starting_frame),
    #         file=record_file,
    #     )

    with open(record_dir, "r") as record_file:
        done_clips_list = [line.split(", ") for line in record_file.readlines()]
        done_clips = [
            video_path.replace("\\", "/") for video_path in done_clips_list[:][0]
        ]
        print(video_list[video_index] in done_clips)
        if video_list[video_index] in done_clips:
            video_index += 1
            continue

    triggered = False

    #! Start video file capture
    pprint("Playing -> {}".format(video_list[video_index]), width=180)
    capture = cv2.VideoCapture(cv2.samples.findFileOrKeep(video_list[video_index]))
    starting_frame = 0
    capture.set(cv2.CAP_PROP_POS_FRAMES, starting_frame)

    while True:
        # Listen for inputs
        keyboard = cv2.waitKey(30)
        #! FILE REPRODUCTION START
        ret, frame = capture.read()
        # Skip to next file if done
        if frame is None:
            pprint("File end, playing next file")
            video_index += 1
            break

        # frame: original data
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        # current_frame: gps time covered
        current_frame = frame.copy()
        cv2.rectangle(current_frame, (0, 420), (710, 465), (0, 0, 0), -1)

        #! DEINTERLACE FRAMES, mode = "discard" or mode = "linear"
        if deinterlace_flag or colormap_flag or raw_deinterlace_flag:
            first_field, second_field = deinterlace(deinterlace_mode, frame)
            # cv2.rectangle(first_field, (0, 420), (710,465), (0,0,0), -1)
            # cv2.rectangle(second_field, (0, 420), (710,465), (0,0,0), -1)

        #! Get 1st frame data for delta calculations and skip to next iteration
        if (capture.get(cv2.CAP_PROP_POS_FRAMES)) == starting_frame + 1:
            previous_frame = current_frame.copy()
            count_stack.clear()
            #
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

            if deinterlace_flag:
                previous_field1 = first_field.copy()
                previous_field2 = second_field.copy()

                ret2, th2 = thresh_func(
                    current_frame, mode2, threshold, block2, substract2
                )
                previous_sections2, previous_count2 = split_frame(
                    th2, n_rows, n_columns
                )
                ret3, th3 = thresh_func(
                    current_frame, mode2, threshold, block2, substract2
                )
                previous_sections3, previous_count3 = split_frame(
                    th3, n_rows, n_columns
                )
            continue

        #! THRESHOLDING
        # Delete static pixels
        th1 = cv2.absdiff(previous_frame, current_frame)

        if deinterlace_flag:
            th2 = cv2.absdiff(previous_field1, first_field)
            th3 = cv2.absdiff(previous_field2, second_field)

        # Threshold
        if not calibration_flag:
            ret1, th1 = thresh_func(
                th1, mode, threshold, block, substract, close_kernel, open_kernel
            )

            if deinterlace_flag:
                ret2, th2 = thresh_func(th2, mode2, threshold, block2, substract2)
                ret3, th3 = thresh_func(th3, mode2, threshold, block2, substract2)

        #! SIMPLE ADJUSTING THRESHOLDING
        if calibration_flag:
            count = previous_count
            delta_total = sum(count)
            if deinterlace_flag:
                ret2, th2 = thresh_func(th2, mode2, threshold, block2, substract2)
                ret3, th3 = thresh_func(th3, mode2, threshold, block2, substract2)

            while delta_total > int(720 * 480 * 0.001):
                threshold += 2
                ret1, th1 = thresh_func(current_frame, "bin", threshold)

                delta_total = cv2.countNonZero(th1)
                pprint("Too bright {}".format(threshold))
            th1 = cv2.morphologyEx(th1, cv2.MORPH_OPEN, kernel)
        calibration_flag = False

        #! LABELING
        if labeling_flag:
            labels = measure.label(th1, background=0, connectivity=2)
            mask = np.zeros((*th1.shape, 3), dtype="uint8")

            label_number, pixel_count = np.unique(labels, return_counts=True)
            for label, pixels in zip(label_number, pixel_count):
                if label == 0:
                    continue
                if pixels > 30:
                    label_mask = np.zeros((*th1.shape, 3), dtype="uint8")
                    label_mask[labels == label] = color_dict[str(label)]
                    mask = cv2.add(mask, label_mask)
            cv2.imshow("mask", mask)
        #! COLORMAP
        if colormap_flag:
            # equal1 = cv2.applyColorMap(current_frame.copy(), cv2.COLORMAP_JET)
            colored1 = first_field.copy()
            colored2 = second_field.copy()
            colored1 = cv2.applyColorMap(colored1, cv2.COLORMAP_JET)
            colored2 = cv2.applyColorMap(colored2, cv2.COLORMAP_JET)

            clahe = cv2.createCLAHE(clipLimit=1, tileGridSize=(8, 8))
            equal11 = clahe.apply(first_field.copy())
            equal22 = clahe.apply(second_field.copy())
            equal11 = cv2.applyColorMap(equal11, cv2.COLORMAP_JET)
            equal22 = cv2.applyColorMap(equal22, cv2.COLORMAP_JET)
        #! HISTOGRAM PLOT
        # plot_histogram([first_field, equal11], 0, 255, 15000, imode_flag)
        # imode_flag = False

        #! SECTIONS DIVISION
        sections, count = split_frame(th1, n_rows, n_columns)
        count_stack.append(count)

        if deinterlace_flag:
            sections2, count2 = split_frame(th2, n_rows, n_columns)
            sections3, count3 = split_frame(th3, n_rows, n_columns)

        #! SHOW FRAMES
        # grid_th1 = th1.copy()
        # draw_grid(grid_th1, n_rows, n_columns)
        # cv2.imshow("th1", grid_th1)
        cv2.imshow("Frame", frame)

        # cv2.imshow("th3", equal1)
        if raw_deinterlace_flag:
            cv2.imshow("field 1", first_field)
            cv2.imshow("field 2", second_field)
        if deinterlace_flag:
            cv2.imshow("th2", th2)
            cv2.imshow("th3", th3)
        if colormap_flag:
            cv2.imshow("colored 12", equal11)
            cv2.imshow("colored 2", equal22)
            # cv2.imshow("Frame", colored2)
            # cv2.imshow("th1", colored1)
        if triggered:
            keyboard = cv2.waitKey(-1)
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

        if deinterlace_flag:
            delta2 = np.subtract(count2, previous_count2)
            delta_total2 = sum(count2) - sum(previous_count2)
            delta3 = np.subtract(count3, previous_count3)
            delta_total3 = sum(count3) - sum(previous_count3)

        if not skip_trigger_flag:
            for rows in range(n_rows):
                print(
                    " |".join(
                        str(e).rjust(5)
                        for e in count[rows * n_columns : (rows + 1) * n_columns]
                    ),
                    end="",
                )
                print(colored("    ||", "red"), end="")
                print(
                    " |".join(
                        str(e).rjust(5)
                        for e in delta[rows * n_columns : (rows + 1) * n_columns]
                    ),
                    end="",
                )
                # print(colored("    ||", "red"), end = "")
                # print(" |".join(str(e).rjust(5) for e in stack_mean[rows*n_columns:(rows+1)*n_columns]), end = "")

                if deinterlace_flag:
                    print(colored("    ||", "red"), end="")
                    print(
                        " |".join(
                            str(e).rjust(5)
                            for e in delta2[rows * n_columns : (rows + 1) * n_columns]
                        ),
                        end="",
                    )
                    print(colored("    ||", "red"), end="")
                    print(
                        " |".join(
                            str(e).rjust(5)
                            for e in delta3[rows * n_columns : (rows + 1) * n_columns]
                        ),
                        end="",
                    )
                    print()
                else:
                    print()

        if deinterlace_flag:
            print(
                "---------- total: {}, {}, {} ----------".format(
                    delta_total, delta_total2, delta_total3
                )
            )
        else:
            print("---------- total: {} ----------".format(delta_total))
        # Update previous data for next loop
        previous_frame = current_frame.copy()
        previous_sections = sections
        previous_count = count
        if deinterlace_flag:
            previous_field1 = first_field.copy()
            previous_field1 = second_field.copy()
            previous_sections2 = sections2
            previous_count2 = count2
            previous_sections3 = sections3
            previous_count3 = count3

        if not skip_trigger_flag and not triggered:
            if average_flag:
                if any(pixel_diff > min_delta for pixel_diff in delta):
                    print("Event triggered, press any key to continue")
                    print(colored("DELTA MODE", "red"))
                    keyboard = cv2.waitKey(-1)
            else:
                if (
                    any(
                        section_count > mean + min_delta
                        for section_count, mean in zip(count, stack_mean)
                    )
                    and len(count_stack) == window
                ):
                    # count_stack.pop()
                    pprint("Event triggered, press any key to continue")
                    print(colored("AVERAGE+DELTA MODE", "red"))
                    triggered = True
                    keyboard = cv2.waitKey(-1)

        #! INPUT COMMANDS SECTION
        # if keyboard != -1:
        # 	print(keyboard)
        if keyboard == 32:
            pprint("Pause at {}".format(capture.get(cv2.CAP_PROP_POS_FRAMES)))
            cv2.waitKey(-1)

        if keyboard == 50:
            frame_n = capture.get(cv2.CAP_PROP_POS_FRAMES)
            print(
                "Manual record at frame {:.0f}. + {:.0f} min {:.0f} seg since start".format(
                    frame_n,
                    frame_n // (30 * 60),
                    frame_n // (30) - 60 * (frame_n // (30 * 60)),
                ),
            )
            p = "Manual review/{}/{}".format(
                video_list[video_index][30:-4],
                int(frame_n),
            )
            with open(record_dir, "a") as record_file:
                print(
                    "Manual record at frame {:.0f}. + {:.0f} min {:.0f} seg since start".format(
                        frame_n,
                        frame_n // (30 * 60),
                        frame_n // (30) - 60 * (frame_n // (30 * 60)),
                    ),
                    file=record_file,
                )
            cv2.imwrite(p + ".png", frame)

        if keyboard == 52:
            pprint("Go back 1 frame")
            capture.set(
                cv2.CAP_PROP_POS_FRAMES, capture.get(cv2.CAP_PROP_POS_FRAMES) - 2
            )

        if keyboard == 53:
            pprint("Log brightest frame (1st field")
            with open(record_dir, "a") as record_file:
                print(
                    "{}, {}, {}".format(
                        video_list[video_index],
                        (capture.get(cv2.CAP_PROP_POS_FRAMES) * 2 - 1),
                        "field 1",
                    ),
                    file=record_file,
                )
            triggered = False

        if keyboard == 54:
            pprint("Log brightest frame (2nd field")
            with open(record_dir, "a") as record_file:
                print(
                    "{}, {}, {}".format(
                        video_list[video_index],
                        (capture.get(cv2.CAP_PROP_POS_FRAMES) * 2),
                        "field 2",
                    ),
                    file=record_file,
                )
            triggered = False

        if keyboard == 55:
            pprint("Continue playing after trigger")
            triggered = False

        if keyboard == 49:
            pprint("Previous file")
            video_index -= 1
            break
        if keyboard == 51:
            pprint("Next file")
            video_index += 1
            break

        if keyboard == 27:
            break_flag = True
            break
    capture.release()
    if break_flag:
        break
