import pandas as pd
import numpy as np
import glob

path = r"C:\\Users\\sauli\\Downloads\\Soft_Tesis\\BrasilDAT_data\\days"
filenames = glob.glob(path + "\\201*.csv")
filenames = np.array(filenames)

print("{}".format(filenames))

previous_file = filenames[0][43:53]
# day_test = np.array([])
day = []

for file in filenames:
    day_df = pd.read_csv(file, index_col=None, header=0)

    year_str = str(day_df.loc[0, "year"])
    month_str = str(day_df.loc[0, "month"])
    if len(day_str) == 1:
        month_str = "0" + month_str
    day_str = str(day_df.loc[0, "day"])
    if len(day_str) == 1:
        day_str = "0" + day_str

    day_df.to_csv(
        year_str + "-" + month_str + "-" + day_str + ".csv",
        index=False,
    )
    day = []
