Due to upload limit, I splited the dataset into 2 parts: 

cd C:\Download
u chinacity2020_line_coord3, clear 
keep if g <= 2 
sa chinacity2020_line_coord3_1, replace 
u chinacity2020_line_coord3, clear 
keep if g > 2 
sa chinacity2020_line_coord3_2, replace 

And zipped them. 

The users can combine chinacity2020_line_coord3_1 with chinacity2020_line_coord3_2 using following stata code: 

u chinacity2020_line_coord3_1, clear 
ap using chinacity2020_line_coord3_2 
sa chinacity2020_line_coord3, replace 
