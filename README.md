# Household-Income-and-Nutritional-Status
Testing for a slope change across an unknown income threshold using Regression Kink Design and Survey Data from India 

Written by: Kareena Satia

## Project Description: 
My project is motivated by the working paper "Economic Development, The Nutrition Trap and Cardiometabolic Disease" by Nancy Luke, Kaivan Munshi, Anu Mary Oommen and Swapnil Singh (2020).

In developing countries, there are following two types of individuals:
1. For some, as long as current consumption is sufficiently close to their ancestral levels that determined an individual's BMI set point, his/her BMI will remain at that set point.
2. For others, once there is a mismatch between current consumption and ancestral income due to increases in income, the individual has escaped nutrition trap and his/her BMI will track with current income.
Therefore, although nutritional status (BMI) is improving in current income across all income levels, there is a discontinuity in the slope of the relationship between income and nutritional status at a particular income threshold.

Objective: My objective is to test for a slope change at an unknown income threshold using regression kink design and nationally representative household survey data from India (IHDS).

## Data:
The original dataset is by India Human Development Survey: a nationally representative panel survey in India from the years 2004-05 and 2011-12. Data was downloaded from here https://www.icpsr.umich.edu/web/DSDR/studies/22626 and here https://www.icpsr.umich.edu/web/DSDR/studies/36151

For 2005, I have used DS0001 folder which contains the individual dataset and DS0002 folder which contains the household dataset. 
For 2012, I have used DS0001 folder which contains the individual dataset, DS0002 folder which contains the household dataset and DS0004 which contains the birth history dataset. 

In addition to these, I have also used a Linking file to link the two rounds of survey data. The data can be downloaded from here: https://ihds.umd.edu/data/data-download

## Coding:
The master do-file in Do Files\Master.do runs the cleaning and analysis files.

## Output:
The regression output and graphs produced in LaTex can be found in Final_Output.pdf




### Acknowledgment: 

I thank Dr. Swapnil Singh (one of the co-authors of the paper: "Economic Development, The Nutrition
Trap and Cardiometabolic Disease") for his guidance and help.
