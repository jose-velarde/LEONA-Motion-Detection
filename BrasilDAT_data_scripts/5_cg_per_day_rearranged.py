import pandas as pd
import numpy as np
import glob

path = r"C:\\Users\\sauli\\Downloads\\Soft_Tesis\\OpenCV\\BrasilDAT_data\\days"
filenames = glob.glob(path + "\\201*.csv")
filenames = np.array(filenames)

# print("{}".format(filenames))

# previous_file = filenames[0][43:53]
# day_test = np.array([])
day = []

for file in filenames:
    day = pd.read_csv(file, index_col=None, header=0)
    day = day[(day["ic_cg_flag"] == 0)].iloc[:, :-1][
        [
            "corrente_pico_kA",
            "hour",
            "minute",
            "second",
            "nanosec",
            "latitude",
            "longitude",
            "year",
            "month",
            "day",
        ]
    ]

    year_str = str(day.iloc[1,7])
    month_str = str(day.iloc[1,8])
    if len(month_str) == 1:
        month_str = "0" + month_str
    day_str = str(day.iloc[1,9])
    if len(day_str) == 1:
        day_str = "0" + day_str

    day.to_csv(
        year_str + "-" + month_str + "-" + day_str + "_cg" + ".csv",
        index=False,
    )
