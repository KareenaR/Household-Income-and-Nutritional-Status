/*
Name: Kareena Satia
Date: 8th January 2021 

Project Title: 
                       Household Income and Nutritional Status: 
        Testing for a change in the relationship across an Unknown Income Threshold 
					Using Regression Kink Design and survey data from India  

Steps: 
1. Merging the Individual IHDS 2012 dataset with the Household IHDS 2012 dataset and creating a measure of household income   
2. Cleaning the birth history IHDS dataset from 2012 and merging it with the dataset created in (1)
3. Merging the Individual IHDS 2005 dataset with the Household IHDS 2005 dataset and creating a measure of household income
4. Merging the 2005 and 2012 dataset created in (2) and (3) to form a panel dataset 
5. Clean the panel dataset and create variables for analysis 
*/

*****************************************************************************
*                      Cleaning IHDS - 2012 Dataset
*****************************************************************************
clear 
*Loading the 2012 individual dataset 
use "$raw\IHDS-2012\ICPSR_36151\DS0001\36151-0001-Data.dta"

*Sorting the dataset 
sort STATEID DISTID PSUID HHID HHSPLITID IDHH 

*Merging the 2012 household dataset with individual 2012 dataset 
merge m:1 STATEID DISTID PSUID HHID HHSPLITID IDHH using "$raw\IHDS-2012\ICPSR_36151\DS0002\36151-0002-Data.dta"

drop _merge 

*Generating a measure of income for 2012 
gen income_2012 = INCSALARY - INCNREGA + INCANIMAL
egen income_2012_own = rsum(income_2012 INCCROP INCBUS), missing
drop income_2012

tempfile i1 
save `i1'


*****************************************************************************
*                 Cleaning Birth History - 2012 Dataset
*****************************************************************************

*Loading the birth history dataset 
use "$raw\IHDS-2012\ICPSR_36151\DS0004\36151-0004-Data.dta"

*Renaming variables
rename BH1 birth_id 
rename BH2 PERSONID 	

*Generating birth order variable 
gen birth_order = birth_id 
replace birth_order = 3 if birth_id >= 3 & birth_id != . 
label var birth_order "Birth Order"

*Dropping duplicate observations 
bysort STATEID DISTID PSUID HHID HHSPLITID PERSONID : gen freq = _n
keep if freq == 1 

*Sorting the dataset
sort STATEID DISTID PSUID HHID HHSPLITID PERSONID 

*Merging the birth history dataset of 2012 with the merged Individual and Household dataset of 2012 
merge 1:1 STATEID DISTID PSUID HHID HHSPLITID PERSONID using `i1'

drop _merge 

save "$final\2012_Final.dta", replace 


*****************************************************************************
*                       Cleaning IHDS - 2005 Dataset
*****************************************************************************

*Loading 2005 individual dataset 
use "$raw\IHDS-2005\ICPSR_22626\DS0001\22626-0001-Data.dta"

sort STATEID DISTID PSUID HHID HHSPLITID IDHH

*Merging individual dataset with household dataset 
merge m:1 STATEID DISTID PSUID HHID HHSPLITID IDHH using "$raw\IHDS-2005\ICPSR_22626\DS0002\22626-0002-Data.dta"

drop _merge 

*Generating a measure of income for 2005 
gen income_2005 = INCWAGE + INCFARM + INCBUS + INCANIMALS
gen survey_year = 2005 

*To make the income in 2005 comparable to 2012, correcting income in rural areas
*by CPI for agricultural wage labor and for urban areas by CPI for industrial workers 
gen income_2005_def = (income_2005*195)/112.311 if URBAN == 1
replace income_2005_def = (income_2005*622)/342 if URBAN == 0 

*Saving the final 2005 dataset 
save "$final\2005_Final.dta", replace 


*****************************************************************************
*          Merging IHDS - 2005 and IHDS - 2012 Dataset
*****************************************************************************

*Using a linking file to merge Round1 and Round2 datasets 
use "$raw\linkind_1 (1).dta"

sort STATEID DISTID PSUID HHID HHSPLITID PERSONID 

*Merging the linking file with 2012 final dataset 
merge 1:1 STATEID DISTID PSUID HHID HHSPLITID PERSONID using "$final\2012_Final.dta"

drop _merge 

sort STATEID DISTID PSUID HHID2005 HHSPLITID2005 

tempfile i2
save `i2'

*Loading the 2005 final dataset 
use "$final\2005_Final.dta"

*Renaming variables 
rename HHID HHID2005 
rename HHSPLITID HHSPLITID2005 
rename PERSONID PERSONID2005 

keep STATEID DISTID PSUID HHID2005 HHSPLITID2005 PERSONID2005 income_2005_def 
sort STATEID DISTID PSUID HHID2005 HHSPLITID2005 PERSONID2005 

*Merging the 2005 final dataset with the 2012 dataset 
merge 1:m STATEID DISTID PSUID HHID2005 HHSPLITID2005 PERSONID2005 using `i2', gen(_mergeR1R2) force

drop _merge 

sort STATEID DISTID PSUID HHID HHSPLITID 

*Saving the final dataset together 
save "$final\merged_all.dta", replace

use "$final\merged_all.dta", clear 


*****************************************************************************
*                       Cleaning the entire dataset
*****************************************************************************

*Creating a measure of income 
gen avg_income = (income_2005_def + income_2012_own)/2 //average income in 2005 and 2012 for consumption smoothing 
gen avg_income_1000 = avg_income/1000   // generating income in thousands 
gen mon_income = avg_income_1000/12     // generating monthly income 

gen ln_income = ln(mon_income) if mon_income != . & mon_income != .  // taking log of monthly income
replace ln_income = . if ln_income < 0 | ln_income == . 
replace ln_income = . if ln_income > 4 

*Graph of household income distribution 
kdensity ln_income, color(blue) xline(1.8, lcolor(red) lpattern(dash)) xtitle("log household income") ytitle(density) title("") plotr(fcolor(white))
graph export "$outcomes\incomedist.png", replace   // the dotted red line shows the median household income
gr export "$outcomes/bmi_income.eps", as(eps) preview(off) replace
!epstopdf "$outcomes/bmi_income.eps"

*Renaming variables 
rename RO5 age
rename MB5 high_blood_pressure 
rename MB6 heart_disease 
rename MB7 diabetes 
rename RO3 sex  

*Correcting for miscoding of variables 
replace age = . if age == 98 | age == 99 | age == 95

*Creating different specifications of the variable age 
gen age2 = age^2 
gen age3 = age^3
label var age2 "Age squared"
label var age3 "Age cubed"

*Creating three different categories of age groups 
gen child = 0 
replace child = 1 if age < 5   // Age group: 0-5 

gen child2 = 0 
replace child2 = 1 if age > 5 & age < 19  // Age group: 5-19

gen adults = 0 
replace adults = 1 if age > 19 // Age greater than 19 

*Creating a measure of height (average of the first two rounds) in metres 
gen height_final = (AP5 + AP6)/2
gen height_m = height_final/100
gen height_m2 = height_m^2      // Squaring the height variable 

*Creating a measure of weights in kgs (average of the first two rounds)
gen weight_final = (AP8 + AP9)/2

*Generating body mass index for adults and discarding those observations with a bmi of over 40 and less than 10  
gen bmi = 0 
replace bmi = weight_final/height_m2 if adults == 1
replace bmi = . if bmi == 0
replace bmi = . if bmi > 40
replace bmi = . if bmi < 10 
kdensity bmi, color(blue) xtitle("BMI") ytitle("density") title("") plotr(fcolor(white)) xline(18.5, lcolor(black) lpattern(dash))
gr export "$outcomes/bmi_income_1.eps", as(eps) preview(off) replace
!epstopdf "$outcomes/bmi_income_1.eps"

*Height-for-age for children between 0-5: average = 110 
*Height-for-age for children between 5-19: average = 176.5 
twoway kdensity height_final if child == 1 || kdensity height_final if child2 == 1, xtitle("height") ytitle("density") legend(label (1 "0-59 months") label (2 "5-19 years")) title("") plotr(fcolor(white)) xline(162.8, lcolor(black) lpattern(dash)) xline(100.7, lcolor(black) lpattern(dash))
gr export "$outcomes/bmi_income_2.eps", as(eps) preview(off) replace
!epstopdf "$outcomes/bmi_income_2.eps"

*Generating indicators for major morbidity disease 
gen indicator = 1 if high_blood_pressure == 1 | heart_disease == 1 | diabetes == 1 | high_blood_pressure == 2 | heart_disease == 2 | diabetes == 2
replace indicator = 0 if high_blood_pressure == 0 | heart_disease == 0 | diabetes == 0

save "$final\analysis.dta", replace

