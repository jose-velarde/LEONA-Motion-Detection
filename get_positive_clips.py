import os
import re
import cv2
from numpy import true_divide
from constants import *


def print_video_length():
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


dirlistpc = [
    "C:/Users/JoseVelarde/Downloads/Personal/LEONA/LEONA-Motion-Detection/Footage review/018-12-13_235655_533/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Anillaco 14-11-2019/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/La Maria 02-10-2019/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/La Maria 29-10-2019/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Santa Maria 01-11-2019/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Santa Maria 26-10-2019/Positives/",
    "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Santa Maria 28-10-2019/Positives/",
]

filelisthdd = [
    "C:/Users/JoseVelarde/Downloads/Personal/LEONA/Videos/2018-12-13_235655_533(01 56UT--04 08UT).avi",
    "E:/Campanha-2019/Anillaco/14-11-2019/2019-11-14_020120_JV_W.avi",
    "E:/Campanha-2019/La Maria/02-10-2019/2019-10-02_014427_JV.avi",
    "E:/Campanha-2019/La Maria/29-10-2019/2019-10-29_002852_JV.avi",
    "E:/Campanha-2019/Santa Maria/01-11-2019/2019-11-01_222054_JV.avi",
    "E:/Campanha-2019/Santa Maria/26-10-2019/2019-10-26_213353_JV_NAOAPAGAR.avi",
    "E:/Campanha-2019/Santa Maria/28-10-2019/2019-10-28_194528_JV_NAOAPAGAR.avi",
]

hddlist = [
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
    "E:/Campanha-2019/Santa Maria/28-10-2019/2019-10-28_194528_JV_NAOAPAGAR.avi",
]


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


def generate_clips(stations, deinterlace_flag):
    """Generate clips (normal or deinterlaced) from the original video files

    Args:
        stations (list): list of folder strings
        deinterlace_flag (bool): deinterlace clip if true
    """
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


def deinterlace_clips(folders, deinterlace_flag):

    deinterlace_mode = "discard"
    # deinterlace_mode = "linear"

    stacked_image = 0
    stack_count = 6

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
                p = "{}Deinterlaced/{} - deinterlaced.avi".format(
                    clip_path[:folder_len], clip_path[folder_len:-15]
                )
                writer = cv2.VideoWriter(
                    p, 0, 60, (int(capture.get(3)), int(capture.get(4)))
                )
            else:
                p = "{}Clips/{} - original.avi".format(
                    clip_path[:folder_len], clip_path[folder_len:-15]
                )

                writer = cv2.VideoWriter(
                    p, 0, 30, (int(capture.get(3)), int(capture.get(4)))
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
                else:
                    # print(ret)
                    writer.write(frame)
                    # cv2.imshow("Frame", frame)
                    # cv2.waitKey(-1)

                    if (capture.get(cv2.CAP_PROP_POS_FRAMES)) >= (
                        32 - stack_count
                    ) and (capture.get(cv2.CAP_PROP_POS_FRAMES)) <= (32 + stack_count):
                        stacked_image += frame
            if not deinterlace_flag:
                cv2.imwrite(p[:-12] + "stack.png", stacked_image)
                stacked_image = 0

            writer.release()
            cv2.destroyAllWindows()
            capture.release()
        i += 1


# Stations = [Anillaco14, LaMaria02, LaMaria29, SantaMaria01, SantaMaria26, SantaMaria28]
# Stations = [Anillaco12]
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
# print_video_length()
Fix_Folder = [
    "C:/Users/JoseVelarde/Downloads/Personal/LEONA/LEONA-Motion-Detection/Footage review/2018-12-13_235655_533/Positives/Clips/"
]

deinterlace_flag = True
# deinterlace_flag = False

# print_clips_in_folder(Stations[0])
# generate_clips(Stations, deinterlace_flag)
deinterlace_clips(Stations_Wide, deinterlace_flag)
