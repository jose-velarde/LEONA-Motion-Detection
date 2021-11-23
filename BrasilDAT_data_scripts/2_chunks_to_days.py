import pandas as pd

for part in range(1, 21):
    if part == 1:
        chunk = pd.read_csv('C:\\Users\\Rede LEONA\\Downloads\\Jose Downloads\\OpenCV\\Matlab\\brasildat_data\\data_part_'+ str(part) + '.csv', delimiter='|', skiprows=[1])
    else:
        chunk = pd.read_csv('C:\\Users\\Rede LEONA\\Downloads\\Jose Downloads\\OpenCV\\Matlab\\brasildat_data\\data_part_'+ str(part) + '.csv', delimiter='|')

    chunk.columns = chunk.columns.str.replace(' ', '')

    chunk["data_hora"] = chunk["data_hora"].str.strip()
    
    date_time = chunk.data_hora.str.extract('(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2}) (?P<hour>\d{2}):(?P<minute>\d{2}):(?P<second>\d{2})')
    
    chunk_ready = date_time.join(chunk.iloc[:,-5:]).rename(columns={'nanosseg': 'nanosec', 'corrente_ka':'corrente_pico_kA', 'tipo':'ic_cg_flag'})

    for group in chunk_ready.groupby(['month', 'day']):
        group[1].to_csv(group[1].iloc[0]['year'] +'-'+ group[1].iloc[0]['month'] +'-'+ group[1].iloc[0]['day'] + '_chunk' + str(part) + '.csv', index=False)
        # print(group[1].iloc[0]['year'] +'-'+ group[1].iloc[0]['month'] +'-'+ group[1].iloc[0]['day'] )
