/* Name: Kareena Satia 
*  Date: 8th January 2021 
Project Title: 
						Household Income and Nutritional Status: 
			Testing for a change in the relationship across an Unknown Income Threshold 
					Using Regression Kink Design and survey data from India  

Project Description: My project is motivated by the working paper "Economic Development, The Nutrition Trap 
and Cardiometabolic Disease" by Nancy Luke, Kaivan Munshi, Anu Mary Oommen and Swapnil Singh (2020). 

In developing countries, there are following two types of individuals:
 
	1. For some, as long as current consumption is sufficiently close to their ancestral levels that
	determined an individual's BMI set point, his/her BMI will remain at that set point. 

	2. For others, once there is a mismatch between current consumption and ancestral income due to increases in income, 
	the individual has escaped nutrition trap and his/her BMI will track with current income. 

Therefore, although nutritional status (BMI) is improving in current income across all income levels, 
there is a discontinuity in the slope of the relationship between income and nutritional status at a
particular income threshold. 

My objective is to test for a slope change at an unknown income threshold 
using regression kink design and nationally representative household survey data from India (IHDS).  

Steps: 
1. Merging the Individual IHDS 2012 dataset with the Household IHDS 2012 dataset and creating a measure of household income   
2. Cleaning the birth history IHDS dataset from 2012 and merging it with the dataset created in (1)
3. Merging the Individual IHDS 2005 dataset with the Household IHDS 2005 dataset and creating a measure of household income
4. Merging the 2005 and 2012 dataset created in (2) and (3) to form a panel dataset 
5. Clean the panel dataset and create variables for analysis 
6. Testing for slope change by running a loop containing regressions, calculating the F-type statistic and find the income threshold where the F-type statistic is minimized 
7. Using the income threshold found in (6) to estimate the regression of BMI on income and finding the slope change 
8. For robustness, I test for slope change by running a loop containing regression of height (an alternative nutritional measure) on income 
*/

clear all 
cap log close 

// This is the project working folder 
global projdir "C:\Users\18575\Desktop\IHDS"

// Raw Data Folder
global raw "$projdir\Data"

// Folder where the Final Data set is stored
global final "$projdir\Final_Data"

// Folder for Output (tables and graphs) 
global outcomes "$projdir\Output"

// Folder for Do-files 
global do_file "$projdir\Do-files"

// Folder for Log file
global log_output "$projdir\Log"

// Setting Working Directory
cd "$projdir"

*****************Start the log**************************************

log using "$log_output\Log\bmi_income_log.txt", ///
	replace text

*****************Running the cleaning do-file******************************

do "$do-file\Cleaning.do"

*****************Running the analysis do-file******************************

do "$do-file\Analysis.do"

*****************Closing the log file*******************************

cap log close 


