import os
import re
import cv2
from numpy import true_divide


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
                print(firstframe, length)
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

Anillaco12 = [
    [109095, 66.0],
    [112885, 66.0],
    [136969, 66.0],
    [153094, 66.0],
    [155161, 66.0],
    [159918, 66.0],
    [161309, 66.0],
    [167307, 67.0],
    [170677, 81.0],
    [171870, 66.0],
    [176699, 66.0],
    [179856, 66.0],
    [214564, 66.0],
    [215173, 76.0],
    [215668, 67.0],
    [217506, 66.0],
    [217969, 70.0],
    [218591, 66.0],
    [220487, 66.0],
    [221814, 66.0],
    [222619, 66.0],
    [223925, 67.0],
    [224239, 76.0],
    [226060, 77.0],
    [226199, 66.0],
    [230134, 68.0],
    [230703, 93.0],
    [233242, 66.0],
    [233598, 66.0],
]

Anillaco14 = [
    [126591, 65.0],
    [131763, 65.0],
    [136091, 66.0],
    [144705, 65.0],
    [184470, 66.0],
    [33094, 104.0],
    [46851, 65.0],
    [49290, 68.0],
    [6891, 65.0],
]

LaMaria02 = [[127522, 65.0], [80634, 66.0]]

LaMaria29 = [
    [104102, 65.0],
    [111967, 65.0],
    [118401, 65.0],
    [120150, 65.0],
    [122199, 65.0],
    [122467, 65.0],
    [133920, 67.0],
    [134811, 65.0],
    [140239, 65.0],
    [154003, 221.0],
    [165914, 65.0],
    [171706, 65.0],
    [177657, 65.0],
    [179267, 65.0],
    [182770, 65.0],
    [182963, 65.0],
    [185797, 65.0],
    [187780, 65.0],
    [206979, 65.0],
    [214713, 65.0],
    [216247, 65.0],
    [216920, 65.0],
    [65270, 79.0],
    [79832, 65.0],
]

SantaMaria01 = [
    [191850, 65.0],
    [200515, 65.0],
    [205643, 65.0],
    [235828, 65.0],
    [240864, 65.0],
    [348338, 65.0],
    [383227, 65.0],
    [434255, 65.0],
    [493424, 66.0],
    [580159, 66.0],
    [583623, 65.0],
    [585663, 65.0],
    [593609, 66.0],
    [602709, 65.0],
    [610326, 65.0],
    [617138, 66.0],
    [628893, 67.0],
    [640955, 65.0],
    [650820, 65.0],
    [651276, 65.0],
    [652203, 65.0],
    [657903, 66.0],
    [665882, 72.0],
    [666040, 65.0],
    [673093, 66.0],
    [676942, 65.0],
    [680184, 182.0],
]

SantaMaria26 = [
    [10221, 66.0],
    [10642, 65.0],
    [11418, 66.0],
    [11576, 66.0],
    [1357, 67.0],
    [14206, 66.0],
    [14841, 67.0],
    [15420, 66.0],
    [15566, 65.0],
    [15922, 66.0],
    [1629, 66.0],
    [16909, 65.0],
    [17419, 65.0],
    [17847, 66.0],
    [19745, 65.0],
    [20982, 65.0],
    [21484, 66.0],
    [22262, 66.0],
    [23159, 78.0],
    [23431, 65.0],
    [25217, 67.0],
    [26252, 65.0],
    [26558, 66.0],
    [2689, 66.0],
    [27867, 65.0],
    [28964, 65.0],
    [30369, 69.0],
    [30807, 67.0],
    [31640, 65.0],
    [31912, 65.0],
    [33139, 67.0],
    [34063, 67.0],
    [35129, 67.0],
    [35461, 66.0],
    [3639, 66.0],
    [36462, 66.0],
    [37448, 66.0],
    [38565, 66.0],
    [39524, 65.0],
    [40956, 66.0],
    [41991, 65.0],
    [4387, 66.0],
    [47623, 66.0],
    [48337, 65.0],
    [49559, 66.0],
    [60718, 65.0],
    [61679, 65.0],
    [62980, 66.0],
    [6400, 65.0],
    [65921, 65.0],
    [69193, 65.0],
    [69635, 65.0],
    [7047, 67.0],
    [70520, 66.0],
    [73482, 65.0],
    [78945, 65.0],
    [8219, 65.0],
    [8493, 65.0],
    [93792, 65.0],
]

SantaMaria28 = [
    [100047, 90.0],
    [102182, 88.0],
    [105645, 71.0],
    [109447, 69.0],
    [113524, 67.0],
    [116418, 65.0],
    [119169, 65.0],
    [119278, 66.0],
    [119691, 69.0],
    [121629, 65.0],
    [122216, 66.0],
    [123828, 66.0],
    [125913, 66.0],
    [126860, 65.0],
    [127950, 65.0],
    [129478, 66.0],
    [130290, 65.0],
    [132944, 65.0],
    [134743, 65.0],
    [136477, 65.0],
    [136830, 65.0],
    [138003, 66.0],
    [141953, 65.0],
    [142364, 66.0],
    [143653, 65.0],
    [146079, 66.0],
    [146665, 66.0],
    [152333, 66.0],
    [156828, 65.0],
    [164416, 65.0],
    [165887, 65.0],
    [168769, 65.0],
    [169330, 65.0],
    [171304, 66.0],
    [172233, 65.0],
    [173655, 66.0],
    [174844, 65.0],
    [177169, 65.0],
    [189216, 69.0],
    [190972, 65.0],
    [192742, 77.0],
    [196825, 65.0],
    [199109, 65.0],
    [200023, 65.0],
    [202760, 65.0],
    [204214, 65.0],
    [226266, 65.0],
    [250120, 67.0],
    [255041, 65.0],
    [260761, 66.0],
    [263003, 65.0],
    [265544, 65.0],
    [269592, 65.0],
    [270187, 65.0],
    [273036, 66.0],
    [276221, 65.0],
    [277667, 92.0],
    [278617, 65.0],
    [281548, 68.0],
    [283743, 65.0],
    [285166, 65.0],
    [287792, 65.0],
    [293570, 65.0],
    [295553, 65.0],
    [298623, 65.0],
    [299255, 65.0],
    [301551, 66.0],
    [302344, 65.0],
    [303668, 66.0],
    [304377, 66.0],
    [305342, 113.0],
    [305535, 66.0],
    [30591, 66.0],
    [307371, 65.0],
    [307578, 66.0],
    [309730, 66.0],
    [311080, 65.0],
    [315962, 66.0],
    [317605, 65.0],
    [321977, 66.0],
    [322095, 65.0],
    [324450, 65.0],
    [326784, 65.0],
    [32802, 66.0],
    [328706, 65.0],
    [332350, 66.0],
    [335141, 65.0],
    [336754, 65.0],
    [344596, 99.0],
    [347878, 76.0],
    [350740, 65.0],
    [360527, 66.0],
    [363913, 65.0],
    [365735, 65.0],
    [375184, 73.0],
    [381119, 66.0],
    [39081, 65.0],
    [402315, 66.0],
    [40797, 77.0],
    [414934, 65.0],
    [422133, 65.0],
    [424340, 65.0],
    [42867, 66.0],
    [433637, 66.0],
    [444872, 65.0],
    [46847, 72.0],
    [48323, 65.0],
    [50102, 65.0],
    [505398, 66.0],
    [517875, 65.0],
    [521428, 65.0],
    [523708, 65.0],
    [52411, 66.0],
    [525827, 66.0],
    [52850, 65.0],
    [529654, 66.0],
    [531031, 65.0],
    [53172, 66.0],
    [535631, 65.0],
    [538303, 65.0],
    [540565, 65.0],
    [54204, 65.0],
    [545109, 65.0],
    [547444, 66.0],
    [551555, 65.0],
    [56200, 65.0],
    [563140, 76.0],
    [57241, 71.0],
    [573763, 91.0],
    [57387, 65.0],
    [579935, 65.0],
    [59000, 65.0],
    [59479, 65.0],
    [60939, 65.0],
    [63424, 67.0],
    [65002, 66.0],
    [67677, 65.0],
    [69490, 91.0],
    [71804, 66.0],
    [74930, 66.0],
    [77476, 108.0],
    [78668, 66.0],
    [80889, 75.0],
    [82094, 65.0],
    [83143, 69.0],
    [85499, 66.0],
    [88540, 92.0],
    [89097, 67.0],
    [89150, 66.0],
    [92971, 72.0],
    [94446, 65.0],
    [95411, 71.0],
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

            for frames in range(length):
                ret, frame = capture.read()
                if deinterlace_flag:
                    first_field, second_field = deinterlace(deinterlace_mode, frame)
                    writer.write(first_field)
                    writer.write(second_field)
                else:
                    # print(ret)
                    writer.write(frame)
                    # cv2.imshow("Frame", frame)
                    # cv2.waitKey(-1)

                    #! Get 1st frame data for delta calculations and skip to next iteration
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


# Stations = [Anillaco14, LaMaria02, LaMaria29, SantaMaria01, SantaMaria26, SantaMaria28]
Stations = [Anillaco12]
# print_video_length()


# deinterlace_flag = True
deinterlace_flag = False


generate_clips(Stations, deinterlace_flag)
