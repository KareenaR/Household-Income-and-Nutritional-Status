/* 
Name: Kareena Satia
Date: 8th January 2021 

Project Title: 
                     Household Income and Nutritional Status: 
			Testing for a change in the relationship across an Unknown Income Threshold 
					Using Regression Kink Design and survey data from India 

File Purpose: This file contains data analysis. 

Steps: 
1. Testing for slope change by running a loop containing regressions, calculating the F-type statistic and find the income threshold where the F-type statistic is minimized 
2. Using the income threshold found in (6) to estimate the regression of BMI on income and finding the slope change 
3. For robustness, I test for slope change by running a loop containing regression of height (an alternative nutritional measure) on income 

*/
*****************************************************************************
*                       Data Analysis 
*****************************************************************************

/* Running a loop to calculate the income threshold where there is a slope change in the relationship 
*between bmi and income  

Steps:
1. Running piecewise linear regressions to examine the relationship between BMI and income above and below the threshold 
2. The first regression only runs on observations where the ln_income >= threshold value 
3. The second regression runs on observatiosn where the ln_income < threshold 
4. I insert the sum of squares of residuals from the two regressions into the matrix and add them up 
5. I insert the number of observations in the two regressions and add them up 
6. I find the minimum sum of squared residuals across different threshold incomes 
7. I use the minimum sum of squared residuls to calculate the F-type statistic : n*(rss_i - rss_min)/rss_min 
8. I plot the F-type statistic against the income threshols to look for a pattern where the F-type statistic increases as it moves away from the income 
   threshold with the lowest sum of squared residuals 

My regression specification is: bmi = beta_0 + beta_1*(ln_income) + beta_2*(ln_income - threshold) + beta_3*(X'_i) + e 

*/ 
clear 

use "$final\analysis.dta", clear 

local threshold = 0.05    // Starting with a lower threshold and then moving up 
local row = 1             // Stating a counter of row = 1
local minrss = 0            // Creating a variable minrss 
matrix A = J(70,7,.)       // Creating an empty matrix of 70 rows and 8 columns

while `threshold' <= 3.50 {    
	              
	gen inc`row' = (ln_income - `threshold')   // Generating variable with the difference between ln_income and threshold
	matrix A[`row', 1] = `threshold'    // Inserting threshold values
	
	qui reg bmi ln_income inc`row' sex age age2 age3 URBAN2011 i.ID13 i.DISTID if adults == 1 & inc`row' >= 0 // Running a regression with only obs with ln_income >= threshold 
	matrix A[`row',2] = e(rss)          // Inserting sum of squared residuals
	matrix A[`row',3] = e(N)            // Inserting the number of observations 
	
	qui reg bmi ln_income inc`row' sex age age2 age3 URBAN2011 i.ID13 i.DISTID if adults == 1 & inc`row' < 0 // Running a separate regression with only obs with ln_income < threshold
	matrix A[`row',4] = e(rss)          // Inserting sum of squared residuals 
	matrix A[`row',5] = e(N)            // Inserting the number of observations 
	
	matrix A[`row',6] = A[`row',2] + A[`row',4]   // Total sum of squared residuals from two regressions 
	matrix A[`row',7] = A[`row',3] + A[`row',5]   // Total number of observations from two regressions 
	
	if `row' == 1 {                         // Stating the first sum of squared residuals as the minimum 
		local minrss = A[`row',6] 
	}
	
	else {                                 // for every other row, I run a check 
		if A[`row',6] < `minrss' {         // whether the rss is less than the first one, 
			local minrss = A[`row',6]      // if it is, then I state that as the lowest one 
		}
	}
	
	local threshold = `threshold' + 0.05  // Increasing the threshold value consistently by 0.05
	local row = `row' + 1                 // Increasing the value of row by 1 
}

matrix min_rss = J(70,1,`minrss')         // Creating a matrix of 70 rows and 1 column with minimum rss 
mat C = diag(A[1...,7]) * (A[1...,6] - min_rss) * (1/`minrss')  // Generating the F-type statistic (rss_i - min_rss)/min_rss
mat A = A, C        // Adding matrix C to matrix A 

// The income threshold at which the F-type statistic minimizes is 1.65 

*Transforming the matrix into variables 
svmat A

*Renaming variables created from matrix A 
rename A8 ftype 
rename A1 thresholds

*Graph displaying the relationship of the F-type statistic and income threshold values 
line ftype thresholds, title("") xtitle("income threshold") ytitle("F-type statistic") lcolor(blue) plotr(fcolor(white))
gr export "$outcomes/bmi_income_3.eps", as(eps) preview(off) replace
!epstopdf "$outcomes/bmi_income_3.eps"           // Line displays a U shaped relationship: wherein the F-type statistic keeps 
						                        //	increasing on both sides as it moves away from the income threshold at which the F-type statistic is minimized  

*Generating a dummy for income values greater than the threshold 
gen knot = 1 if ln_income >= 1.65 
replace knot = 0 if ln_income < 1.65 & ln_income != .

*Generating a variable with an interaction between the dummy and ln_income which measures the slope change 
gen diff = ln_income - 1.65 
gen diffXknot = knot*diff
 
*Running a piecewise linear regression with the break at income threshold value of 1.65 
reg bmi ln_income diffXknot sex age age2 age3 URBAN2011 i.ID13 i.DISTID if adults == 1
outreg2 using "$outcomes\regBMI", replace label bdec(2) sdec(2) rdec(2) keep(ln_income diffXknot sex age age2 age3 URBAN2011)

// The slope change is given by the coefficient on the diffXknot. It is positive and statistically significant 
// that displays a stronger income effect at higher income values 

replace height_final = . if height_final > 176 & adults == 1 
// In order to check the robustness of the results, I check for slope change using another nutritional measure (height). 
// In the following steps, I run the same test and examine the relationship between height and income. 

*My regression specification is: height = beta_0 + beta_1(ln_income) + beta_2(ln_income - threshold) + beta_3(x'_i) + e 

local threshold = 0.05 // Starting with an income threshold and then moving up 
local row = 1          // Starting a counter of rows in a matrix 
local rss_min = 0 
matrix B = J(70,7,.)   // Creating a matrix of 70 rows and 8 columns
 
while `threshold' <= 3.50 {
	
	gen income`row' = (ln_income - `threshold') // Generating variable with the difference between ln_income and threshold
	matrix B[`row', 1] = `threshold'          // Inserting threshold values
	
	qui reg height_final ln_income income`row' sex age age2 age3 URBAN2011 i.ID13 i.DISTID if adults == 1 & income`row' >= 0 // Running a regression with ln_income >= threshold 
	matrix B[`row',2] = e(rss)         // Inserting squared sum of residuals 
	matrix B[`row',3] = e(N)           // Inserting number of obs 
	
	qui reg height_final ln_income income`row' sex age age2 age3 URBAN2011 i.ID13 i.DISTID if adults == 1 & income`row' < 0 // Running a separate regression with ln_income < threshold 
	matrix B[`row',4] = e(rss)        // Inserting squared sum of residuals 
	matrix B[`row',5] = e(N)          // Inserting number of obs 
	
	matrix B[`row',6] = B[`row',2] + B[`row',4]    // Total squared sum of residuals from two regresssions 
	matrix B[`row',7] = B[`row',3] + B[`row',5]    // Total number of obs from two regressions 
	
	if `row' == 1 {                         // Stating the first sum of squared residuals as the minimum 
		local rss_min = A[`row',6] 
	}
	
	else {                                 // for every other row, I run a check 
		if B[`row',6] < `rss_min' {         // whether the rss is less than the first one, 
			local rss_min = B[`row',6]      // if it is, then I state that as the lowest one 
		}
	}	
	local threshold = `threshold' + 0.05
	local row = `row' + 1
} 

matrix min_rss_2 = J(70,1,`rss_min')         // Creating a matrix of 70 rows and 1 column with minimum rss 
mat D = diag(B[1...,7]) * (B[1...,6] - min_rss_2) * (1/`rss_min')  // Generating the F-type statistic (rss_i - min_rss)/min_rss
mat B = B, D        // Adding matrix C to matrix A 

//The income threshold at which the sum of squared residuals minimizes is 1.7 

*Generating variables from matrix 
svmat B

*Renaming variables created from the matrix 
rename B8 ftype_1
rename B1 thresholds_1

*Graph of the F-type statistic and income thresholds 
line ftype_1 thresholds_1, title("") xtitle("income threshold") ytitle("F-type statistic") lcolor(red) plotr(fcolor(white))
gr export "$outcomes/bmi_income_4.eps", as(eps) preview(off) replace
!epstopdf "$outcomes/bmi_income_4.eps" 

*Creating variables for estimation
gen knot2 = 1 if ln_income >= 1.7 
replace knot2 = 0 if ln_income < 1.7 & ln_income != .

*Using the income threshold at which the break occurs to generate a new variable which states the slope change 
gen diff2 = ln_income - 1.7
gen diff2Xknot = diff2*knot2      // generating variable indicating the measure of slope change 

*Running a regression with the income threshold value found in the loop 
reg height_final ln_income diff2Xknot sex age age2 age3 URBAN2011 i.ID13 i.DISTID if adults ==1 
outreg2 using "$outcomes\regBMI", append tex label bdec(2) sdec(2) rdec(2) keep(ln_income diffXknot sex age age2 age3 URBAN2011)

// The coefficient on diff2Xknot shows the slope change. It is positive and statistically significant. 

// We find evidence for a slope change between household income and nutritional status. After choosing a specific income threshold 
// and running a regression for the same, we find that the coefficient on the slope change is positive and statistically significant. 