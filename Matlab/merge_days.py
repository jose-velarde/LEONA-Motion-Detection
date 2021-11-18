import pandas as pd
import numpy as np
import glob

path = r"C:/Users/sauli/Downloads/Soft_Tesis/OpenCV"
filenames = glob.glob(path + "/2019-11-1*.csv")
filenames = np.array(filenames)

# print("{}".format(filenames))

previous_file = filenames[0][43:53]
# day_test = np.array([])
day = []

for file in filenames:
    day_chunk = pd.read_csv(file, index_col=None, header=0)

    if file[43:53] == previous_file:
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
        if len(day_str) == 1:
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
        previous_file = file[43:53]

if len(day):
    day_complete = pd.concat(day, axis=0, ignore_index=True)

    year_str = str(day_complete.loc[0, "year"])

    month_str = str(day_complete.loc[0, "month"])
    if len(day_str) == 1:
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
