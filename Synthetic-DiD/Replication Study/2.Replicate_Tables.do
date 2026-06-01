clear all

global mainDIR "C:\Users\feder\Desktop\Project\Bertoia (Causal Inference)\Replication Study Federico\Replication"
global dataDIR "C:\Users\feder\Desktop\Project\Bertoia (Causal Inference)\Replication Study Federico\Replication\data"
global outputDIR "C:\Users\feder\Desktop\Project\Bertoia (Causal Inference)\Replication Study Federico\Replication\output"


set more off
cd "$mainDIR"


cap log close 
log using 2.Replicate_Tables.log, replace 

*=======================
* Table 1: Tax Incidence
*=======================
use data\tax_incidence_data, clear

tsset year 

* First differencing:
newey D.(retail_price oilprice_SEK energycarbon_tax), lag(16) 
eststo TableA1
test D1.energycarbon_tax=1

* Number of lags were chosen using the Newey-West (1994) method.
* Splitting up the total tax into its energy and carbon tax part
newey D.( retail_price oilprice_SEK energytax carbontax ), lag(16)
eststo TableA2
test D1.energytax=1
test D1.carbontax=1

/*
reg D.(retail_price oilprice_SEK energycarbon_tax), robust
test D1.energycarbon_tax=1


reg D.( retail_price oilprice_SEK energytax carbontax ), robust
test D1.energytax=1
test D1.carbontax=1


The Huber/White/sandwich robust variance estimator (see White [1980]) produces consistent
standard errors for OLS regression coefficient estimates in the presence of heteroskedasticity. The
Newey–West (1987) variance estimator is an extension that produces consistent estimates when there
is autocorrelation in addition to possible heteroskedasticity.	
The Newey–West variance estimator handles autocorrelation up to and including a lag of m,
where m is specified by stipulating the lag() option. Thus, it assumes that any autocorrelation at
lags greater than m can be ignored.
If lag(0) is specified, the variance estimates produced by newey are simply the Huber/
White/sandwich robust variances estimates calculated by regress, vce(robust);
*/

esttab TableA1 TableA2 using "$outputDIR\Table1.tex", replace cells(b(star fmt(3)) se(par fmt(4))) ///
title(Tax incidence) mtitle("Compact" "Splitted") ///
legend label varlabels(_cons constant) 




*==============================================
* Table 2: DiD Estimate of the Treatment Effect
*==============================================
use data\carbontax_data, clear
xtset Countryno year

gen treatment = 0
replace treatment =1 if Countryno==13 & year>=1990



xtdidregress (CO2_transport_capita) (treatment), group(Countryno) time(year)
eststo TableB

esttab TableB using "$outputDIR\Table2.tex", replace cells(b(star fmt(3)) se(par fmt(4))) ///
title(DiD Estimate of the Treatment Effect) mtitle("Compact" "Splitted") ///
legend label varlabels(_cons constant) 


/*
which is equivalent to

xtreg CO2_transport_capita i.year treatment, fe vce(cluster Countryno)

https://www.stata.com/manuals/tedidregress.pdf#tedidregress
*/


*==================================================================================================================
* Table 3 & 4: CO2 Emissions from Transport Predictor Means before Tax Reform & Country Weights in Synthetic Sweden
*==================================================================================================================

* I downloaded data of population for OECD countries from the WorldBank Dataset to obtain the weighted average of the predictors
* for the OECD sample. In the data folder I will add that dataset.

/* import excel "C:\Users\feder\Desktop\Project\Bertoia (Causal Inference)\Carbon Taxes and CO2 Emissions\OECD Population Data.xlsx", sheet("Data") firstrow
drop in 16/20
reshape long YR, i(CountryName) j(j)
rename j year
rename CountryName country
rename YR population
gen id = _n
keep id population
save "population_dataset.dta", replace
clear */

use data\carbontax_data, clear
gen id = _n
merge 1:1 id using "data\population_dataset.dta"
xtset Countryno year


synth CO2_transport_capita GDP_per_capita vehicles_capita gas_cons_capita urban_pop ///
CO2_transport_capita(1989) CO2_transport_capita(1980) CO2_transport_capita(1970), ///
trunit(13) trperiod(1990) xperiod(1980(1)1989) nested unitnames(country) figure iterate(2000) keep(synth_results)  replace 



ereturn list


*ssc install _gwtmean
 

egen GDP_per_capita_OECD = wtmean(GDP_per_capita) if Countryno !=13 & year>=1980 & year <=1989, weight(population)
egen vehicles_capita_OECD = wtmean(vehicles_capita) if Countryno !=13 & year>=1980 & year <=1989, weight(population)
egen gas_cons_capita_OECD = wtmean(gas_cons_capita) if Countryno !=13 & year>=1980 & year <=1989, weight(population)
egen urban_pop_OECD = wtmean(urban_pop) if Countryno !=13 & year>=1980 & year <=1989, weight(population)
egen CO2_transport_capita1989_OECD = wtmean(CO2_transport_capita) if Countryno !=13 & year==1989, weight(population)
egen CO2_transport_capita1980_OECD = wtmean(CO2_transport_capita) if Countryno !=13 & year==1980, weight(population)
egen CO2_transport_capita1970_OECD = wtmean(CO2_transport_capita) if Countryno !=13 & year==1970, weight(population)

sum GDP_per_capita_OECD vehicles_capita_OECD gas_cons_capita_OECD urban_pop_OECD CO2_transport_capita1989_OECD CO2_transport_capita1980_OECD CO2_transport_capita1970_OECD if Countryno!=13



matrix list e(X_balance)
matrix list e(W_weights)
matrix list e(V_matrix)



*==================================================================
* Table 5: Estimation Results from Gasoline Consumption Regressions
*==================================================================	

use data\disentangling_regression_data, clear
tsset year

newey log_gas_cons rctewvat real_carbontax_with_vat d_carbontax t, lag(16)
lincom _b[rctewvat]-_b[real_carbontax_with_vat]
eststo Table31

newey log_gas_cons rctewvat real_carbontax_with_vat d_carbontax t real_gdp_cap_1000, lag(16)
lincom _b[rctewvat]-_b[real_carbontax_with_vat]
eststo Table32

newey log_gas_cons rctewvat real_carbontax_with_vat d_carbontax t real_gdp_cap_1000 urban_pop, lag(16) 
lincom _b[rctewvat]-_b[real_carbontax_with_vat]
eststo Table33

newey log_gas_cons rctewvat real_carbontax_with_vat d_carbontax t real_gdp_cap_1000 urban_pop unemploymentrate, lag(16)
lincom _b[rctewvat]-_b[real_carbontax_with_vat]
eststo Table34

/*
 A natural question to ask is whether a variable presumed to be endogenous in the previously fit
model could instead be treated as exogenous. If the endogenous regressors are in fact exogenous,
then the OLS estimator is more efficient; and depending on the strength of the instruments and other
factors, the sacrifice in efficiency by using an instrumental-variables estimator can be significant.
Thus, unless an instrumental-variables estimator is really needed, OLS should be used instead. estat
endogenous provides several tests of endogeneity after 2SLS and GMM estimation.


The Durbin and Wu–Hausman tests assume that the error term is i.i.d. Therefore, if you requested
a robust VCE at estimation time, estat endogenous will instead report Wooldridge's (1995) score
test and a regression-based test of exogeneity. Both these tests can tolerate heteroskedastic and
autocorrelated errors, while only the regression-based test is amenable to clustering.
*/

/*
For an excluded exogenous variable to be a valid instrument, it must be sufficiently correlated with
the included endogenous regressors but uncorrelated with the error term
*/


ivregress 2sls log_gas_cons (rctewvat=real_energytax_with_vat) real_carbontax_with_vat d_carbontax t real_gdp_cap_1000 urban_pop unemploymentrate, ///
vce(hac bartlett 16)
* vce(hac bartlett opt) gives 16 lags, but I need to specify them to perform estat firststage
lincom _b[rctewvat]-_b[real_carbontax_with_vat]
eststo Table35
estat endogenous
estat firststage

ivregress 2sls log_gas_cons (rctewvat=real_oil_price_sek) real_carbontax_with_vat d_carbontax t real_gdp_cap_1000 urban_pop unemploymentrate, ///
vce(hac bartlett 16)
* vce(hac bartlett opt) gives 16 lags, but I need to specify them to perform estat firststage
lincom _b[rctewvat]-_b[real_carbontax_with_vat]
eststo Table36
estat endogenous
estat firststage


esttab Table31 Table32 Table33 Table34 Table35 Table36 using "$outputDIR\Table5.tex", replace cells(b(star fmt(3)) se(par fmt(4))) ///
title(Estimation Results from Gasoline Consumption Regressions) mtitle("OLS" "OLS" "OLS" "OLS" "IV(EnTax)" "IV(OilPrice)") ///
legend label varlabels(_cons constant) 


*==============================================================================================================================================
* Table 6 & 7: CO2 Emissions from Transport Predictor Means before Tax Reform (Full Sample) & Country Weights in Synthetic Sweden (Full Sample) 
*==============================================================================================================================================

/*
import excel "C:\Users\feder\Desktop\Project\Bertoia (Causal Inference)\Carbon Taxes and CO2 Emissions\OECD Population Data Full Sample.xlsx", sheet("Data") firstrow clear
drop in 25/29
reshape long YR, i(CountryName) j(j)
rename j year
rename CountryName country
rename YR population
gen id = _n
keep id population
save "population_dataset_fullsample.dta", replace
clear
*/

use data\carbontax_fullsample_data, clear
gen id = _n
merge 1:1 id using "data\population_dataset_fullsample.dta"
xtset Countryno year


synth CO2_transport_capita GDP_per_capita vehicles_capita gas_cons_capita urban_pop ///
CO2_transport_capita(1989) CO2_transport_capita(1980) CO2_transport_capita(1970), ///
trunit(21) trperiod(1990) xperiod(1980(1)1989) nested unitnames(country) figure iterate(2000) 

ereturn list

matrix list e(X_balance)
matrix list e(W_weights)
matrix list e(V_matrix)

egen GDP_per_capita_OECD = mean(GDP_per_capita) if Countryno !=21 & year>=1980 & year <=1989
egen vehicles_capita_OECD = mean(vehicles_capita) if Countryno !=21 & year>=1980 & year <=1989
egen gas_cons_capita_OECD = mean(gas_cons_capita) if Countryno !=21 & year>=1980 & year <=1989
egen urban_pop_OECD = mean(urban_pop) if Countryno !=21 & year>=1980 & year <=1989
egen CO2_transport_capita1989_OECD = mean(CO2_transport_capita) if Countryno !=21 & year==1989
egen CO2_transport_capita1980_OECD = mean(CO2_transport_capita) if Countryno !=21 & year==1980
egen CO2_transport_capita1970_OECD = mean(CO2_transport_capita) if Countryno !=21 & year==1970



sum GDP_per_capita vehicles_capita gas_cons_capita urban_pop CO2_transport_capita1989_OECD CO2_transport_capita1980_OECD CO2_transport_capita1970_OECD if Countryno !=21


/*
For the full sample he uses the sample average (online appendix)

egen GDP_per_capita_OECD = wtmean(GDP_per_capita) if Countryno !=21 & year>=1980 & year <=1989, weight(population)
egen vehicles_capita_OECD = wtmean(vehicles_capita) if Countryno !=21 & year>=1980 & year <=1989, weight(population)
egen gas_cons_capita_OECD = wtmean(gas_cons_capita) if Countryno !=21 & year>=1980 & year <=1989, weight(population)
egen urban_pop_OECD = wtmean(urban_pop) if Countryno !=21 & year>=1980 & year <=1989, weight(population)
egen CO2_transport_capita1989_OECD = wtmean(CO2_transport_capita) if Countryno !=21 & year==1989, weight(population)
egen CO2_transport_capita1980_OECD = wtmean(CO2_transport_capita) if Countryno !=21 & year==1980, weight(population)
egen CO2_transport_capita1970_OECD = wtmean(CO2_transport_capita) if Countryno !=21 & year==1970, weight(population)

sum GDP_per_capita_OECD vehicles_capita_OECD gas_cons_capita_OECD urban_pop_OECD CO2_transport_capita1989_OECD CO2_transport_capita1980_OECD CO2_transport_capita1970_OECD if Countryno!=21
*/






log close