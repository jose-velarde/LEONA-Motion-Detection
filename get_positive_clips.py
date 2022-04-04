import os
import re
import cv2
from numpy import true_divide
from constants import *


def print_video_length():
    """outdated"""
    regexfulldir = re.compile("(.*Positives.*avi$)")
    regexstation = re.compile(r"(.*?\\)(.*?)(\d+-\d+-\d+)(\\.*?)")
    # rootdir = "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV"
    rootdir = "C:/Users/JoseVelarde/Downloads/Personal/LEONA/LEONA-Motion-Detection/Footage review"

    for root, dirs, files in os.walk(rootdir):
        for file in files:
            path = os.path.join(root, file)
            if regexfulldir.match(path):
                firstframe = str(file[:-4])
                capture = cv2.VideoCapture(cv2.samples.findFileOrKeep(path))
                length = capture.get(cv2.CAP_PROP_FRAME_COUNT)
                # print(firstframe, length)
                # print(regexstation.match(path).group(2))
                # print(os.path.join(root,file))


def generate_clips(stations, deinterlace_flag):
    """outdated"""
    deinterlace_mode = "discard"
    # deinterlace_mode = "linear"
    previous_frames = 32
    stacked_image = 0
    stack_count = 6

    i = 0
    for clips_list in stations:
        print(dirlistpc[i], filelisthdd[i])
        capture = cv2.VideoCapture(cv2.samples.findFileOrKeep(filelisthdd[i]))

        for clip in clips_list:
            start = clip[0]
            length = int(clip[1])
            # print(start, length)
            ret, frame = capture.read()

            capture.set(cv2.CAP_PROP_POS_FRAMES, start - previous_frames)

            if deinterlace_flag:
                p = "{}Deinterlaced/{} - deinterlaced.avi".format(dirlistpc[i], start)
                writer = cv2.VideoWriter(
                    p, 0, 60, (int(capture.get(3)), int(capture.get(4)))
                )
            else:
                p = "{}Clips/{} - original.avi".format(dirlistpc[i], start)

                writer = cv2.VideoWriter(
                    p, 0, 30, (int(capture.get(3)), int(capture.get(4)))
                )

            while True:
                ret, frame = capture.read()
                if frame is None:
                    break
                if deinterlace_flag:

                    first_field, second_field = deinterlace(deinterlace_mode, frame)
                    writer.write(first_field)
                    writer.write(second_field)
                else:
                    writer.write(frame)

                    if (capture.get(cv2.CAP_PROP_POS_FRAMES)) >= (
                        start - stack_count
                    ) and (capture.get(cv2.CAP_PROP_POS_FRAMES)) <= (
                        start + stack_count
                    ):
                        stacked_image += frame

            if not deinterlace_flag:
                cv2.imwrite(p[:-12] + "stack.png", stacked_image)
                stacked_image = 0

            writer.release()
            cv2.destroyAllWindows()
        capture.release()
        i += 1


def get_clips_in_folder(rootdir):
    regexfulldir = re.compile("(.*avi$)")
    file_list = []
    for root, dirs, files in os.walk(rootdir):
        for file in files:
            path = os.path.join(root, file)
            if regexfulldir.match(path):

                capture = cv2.VideoCapture(cv2.samples.findFileOrKeep(path))
                length = capture.get(cv2.CAP_PROP_FRAME_COUNT)
                file_list.append([path, length])
                # print(path, length)
                # print(path[:110])
                # print(path[110:-15])
    return file_list


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


def deinterlace_clips(folders, deinterlace_flag, trigger_frame, stack_count):

    deinterlace_mode = "discard"
    # deinterlace_mode = "linear"

    stacked_image = 0

    i = 0
    for folder in folders:
        folder_len = len(folder)
        clips_list = get_clips_in_folder(folder)

        for clip in clips_list:
            clip_path = clip[0]
            length = int(clip[1])
            # print(clip_path)
            capture = cv2.VideoCapture(cv2.samples.findFileOrKeep(clip_path))

            if deinterlace_flag:
                p = "{}Deinterlaced/{} - ".format(
                    clip_path[:folder_len], clip_path[folder_len:-15]
                )

                if not os.path.exists("{}Deinterlaced".format(clip_path[:folder_len])):
                    os.makedirs("{}Deinterlaced".format(clip_path[:folder_len]))

                writer = cv2.VideoWriter(
                    p + "deinterlaced.avi",
                    0,
                    60,
                    (int(capture.get(3)), int(capture.get(4))),
                )
            else:
                p = "{}Clips/{} - ".format(
                    clip_path[:folder_len], clip_path[folder_len:-15]
                )

                writer = cv2.VideoWriter(
                    p + "original.avi",
                    0,
                    30,
                    (int(capture.get(3)), int(capture.get(4))),
                )
            print(p)
            while True:
                ret, frame = capture.read()
                if frame is None:
                    break
                if deinterlace_flag:
                    first_field, second_field = deinterlace(deinterlace_mode, frame)
                    writer.write(first_field)
                    writer.write(second_field)

                    if capture.get(cv2.CAP_PROP_POS_FRAMES) == trigger_frame:
                        cv2.imwrite(p + "field_1.png", first_field)
                        cv2.imwrite(p + "field_2.png", second_field)

                    if (capture.get(cv2.CAP_PROP_POS_FRAMES)) >= (
                        (trigger_frame - 1) - stack_count
                    ) and (capture.get(cv2.CAP_PROP_POS_FRAMES)) <= (trigger_frame - 1):
                        stacked_image += first_field
                        stacked_image += second_field
                else:
                    writer.write(frame)

                    if (capture.get(cv2.CAP_PROP_POS_FRAMES)) >= (
                        trigger_frame - stack_count
                    ) and (capture.get(cv2.CAP_PROP_POS_FRAMES)) <= (
                        trigger_frame + stack_count
                    ):
                        stacked_image += frame

            cv2.imwrite(p + "stack.png", stacked_image)
            stacked_image = 0

            writer.release()
            cv2.destroyAllWindows()
            capture.release()
        i += 1


# Stations = [Anillaco14, LaMaria02, LaMaria29, SantaMaria01, SantaMaria26, SantaMaria28]
Stations = [Anillaco12]
Stations_Wide = [
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Anillaco/2018-12-14_041911_Wide/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Anillaco/2018-12-14_063933_Wide/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Anillaco/2018-12-14_065708_Wide/Positives/",
]

Stations_Narrow = [
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Anillaco/2018-12-14_033512_Narrow/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Anillaco/2018-12-14_041925_Narrow/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Anillaco/2018-12-14_065722_Narrow/Positives/",
]

Stations_HDD = [
    "C:/Users/JoseVelarde/Downloads/Personal/LEONA/LEONA-Motion-Detection/Footage review/2018-12-13_235655_533/Positives/"
]
# print_video_length()
Fix_Folder = [
    "C:/Users/JoseVelarde/Downloads/Personal/LEONA/LEONA-Motion-Detection/Footage review/2018-12-13_235655_533/Positives/Clips/"
]

Stations_Wide_BR = [
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/2018-12-14_04 19 UT - 06 32 UT _ Wide/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/2018-12-14_06 39  UT - 06 43 UT _ Wide/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/2018-12-14_06 57  UT - 07 24 UT _ Wide/Positives/",
]

Stations_Narrow_BR = [
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/2018-12-14_03 35 UT - 04 08 UT _ Narrow/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/2018-12-14_04 19 UT - 06 32 UT _ Narrow/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/2018-12-14_06 39 UT _ 06 43 UT _ Narrow/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/2018-12-14_06 57 UT - 07 24 UT _ Narrow/Positives/",
]
Stations_Elves_BR = [
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/2018-12-14_04 19 UT - 06 32 UT _ Narrow/Elves/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/2018-12-14_04 19 UT - 06 32 UT _ Wide/Elves/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/2018-12-14_06 57  UT - 07 24 UT _ Wide/Elves/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Footage review/2018-12-14_06 57 UT - 07 24 UT _ Narrow/Elves/",
]

Old_Positive_Clips = [
    # "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Anillaco/2019-11-14/Positives/Clips/",
    # "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Santa Maria/2019-11-01/Positives/Clips/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Santa Maria/2019-10-28/Positives/Clips/",
    # "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/La Maria/2019-10-29/Positives/Clips/",
    # "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Santa Maria/2019-10-26/Positives/Clips/",
]

Old_False_Positive_Clips = [
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Anillaco/2019-11-14/False positives/Clips/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Santa Maria/2019-11-01/False positives/Clips/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Santa Maria/2019-10-28/False positives/Clips/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/La Maria/2019-10-29/False positives/Clips/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Santa Maria/2019-10-26/False positives/Clips/",
]
deinterlace_flag = True
# deinterlace_flag = False

# print_clips_in_folder(Stations[0])
# generate_clips(Stations, deinterlace_flag)
deinterlace_clips(
    Old_Positive_Clips, deinterlace_flag, trigger_frame=32, stack_count=12
)
