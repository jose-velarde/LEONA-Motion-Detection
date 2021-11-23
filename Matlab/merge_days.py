import pandas as pd
import numpy as np
import glob

path = r"C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Matlab/brasildat_data/day_chunks"
filenames = glob.glob(path + "/201*.csv")
filenames = np.array(filenames)

# print("{}".format(filenames))

previous_file = filenames[0][93:95]
# day_test = np.array([])
day = []
# print(previous_file)
for file in filenames:
    # break
    day_chunk = pd.read_csv(file, index_col=None, header=0)
    if file[93:95] == previous_file:
        # day_test = np.append(day_test, file)
        # print(file[43:53])
        day.append(day_chunk)
    else:
        # print()
        # print(day_test)
        # day_test = np.array([])
        # day_test = np.append(day_test, file)
        day_complete = pd.concat(day, axis=0, ignore_index=True)

        year_str = str(day_complete.loc[0, "year"])
        month_str = str(day_complete.loc[0, "month"])
        if len(month_str) == 1:
            month_str = '0' + month_str        
        day_str = str(day_complete.loc[0, "day"])
        if len(day_str) == 1:
            day_str = '0' + day_str

        day_complete.to_csv(
            year_str
            + "-"
            + month_str
            + "-"
            + day_str
            + ".csv",
            index=False,
        )
        day = []
        day.append(day_chunk)
        previous_file = file[93:95]

if len(day):
    day_complete = pd.concat(day, axis=0, ignore_index=True)

    year_str = str(day_complete.loc[0, "year"])

    month_str = str(day_complete.loc[0, "month"])
    if len(month_str) == 1:
        month_str = '0' + month_str

    day_str = str(day_complete.loc[0, "day"])
    if len(day_str) == 1:
        day_str = '0' + day_str

    day_complete.to_csv(
        year_str
        + "-"
        + month_str
        + "-"
        + day_str
        + ".csv",
        index=False,
    )
