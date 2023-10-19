typedef struct str_arr{
	char **arr;
	int s_size;
} str_arr;

typedef struct str_arr2 {
	str_arr **arr;
	int s_size;
} str_arr2;

typedef struct merge_cell {
	int start_row;
	int start_col;
	int end_row;
	int end_col;
	char *val;
} merge_cell;


typedef struct merge_cell_arr {
	merge_cell **cells;
	int s_size;
} merge_cell_arr;