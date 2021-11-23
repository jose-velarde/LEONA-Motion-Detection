def main():
    chunk_size = 2000000  # lines

    def write_chunk(part, lines):
        with open("data_part_" + str(part) + ".csv", "w") as f_out:
            f_out.write(header)
            f_out.writelines(lines)

    with open(
        "C:\\Users\\sauli\\Downloads\\Soft_Tesis\\brasildat_eliah_leona_2021.10.07.csv",
        "r",
    ) as f:
        count = 0
        header = f.readline()
        lines = []
        for line in f:
            count += 1
            lines.append(line)
            if count % chunk_size == 0:
                write_chunk(count // chunk_size, lines)
                lines = []
        # write remainder
        if len(lines) > 0:
            write_chunk((count // chunk_size) + 1, lines)


if __name__ == "__main__":
    main()
