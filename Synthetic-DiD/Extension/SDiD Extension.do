clear all

global mainDIR "C:\Users\feder\Desktop\Project\Bertoia (Causal Inference)\Replication Study Federico\Extension"
global dataDIR "C:\Users\feder\Desktop\Project\Bertoia (Causal Inference)\Replication Study Federico\Extension\data"
global outputDIR "C:\Users\feder\Desktop\Project\Bertoia (Causal Inference)\Replication Study Federico\Extension\output"


set more off
cd "$mainDIR"

cap log close 
log using ExtensionsSDID, replace

*ssc install sdid




*===========================================
* 1. DiD / SC / SDiD plot without covariates
*===========================================


* DiD

use data\carbontax_data, clear
xtset Countryno year
encode country, gen(countrynumb)
gen treatment = 0
replace treatment =1 if Countryno==13 & year>=1990


xtdidregress (CO2_transport_capita) (treatment), group(Countryno) time(year)
*-.2137205 ATT


sdid CO2_transport_capita Countryno year treatment, ///
vce(placebo) seed(123) ///
method(did) graph g1on ///
g1_opt(xtitle(" ") scheme(sj) ///
xlabel(1 "Australia" 2 "Belgium" 3 "Canada" 4 "Denmark" 5 "France" 6 "Greece" 7 "Iceland" 8 "Japan" ///
9 "New Zealand" 10 "Poland" 11 "Portugal" 12 "Spain" 13 "Switzerland" 14 "United States"))  ///
g2_opt(ylabel(0(1)3) scheme(sj) ytitle("Metric tons per capita (CO2 from transport)", margin(medium)) ///
legend(order(2 "Sweden" 1 "OECD countries"))) 

graph export "$outputDIR\DiD Figures\DiD weights.png", as(png) name("g1_1990") replace
graph export "$outputDIR\DiD Figures\DiD outcome.png", as(png) name("g2_1990") replace


*(notice it is the same graph of Figure 3) -0.21372 ATT /  0.27489 SE



matrix results = J(15,1,.)
forvalues i = 1(1)15 {
	use data\carbontax_data, clear
    xtset Countryno year
    gen treatment = 0
    replace treatment =1 if Countryno==`i' & year>=1990
	
	cd "$outputDIR\DiD Figures"
	sdid CO2_transport_capita Countryno year treatment, ///
    vce(noinference) seed(123) method(did) graph graph_export(did_`i', .png)  ///
    g1_opt(xtitle(" ") scheme(sj)) ///
    g2_opt(ylabel(0(1)6) scheme(sj) ytitle("Metric tons per capita (CO2 from transport)", margin(medium))) 
	
    matrix results[`i',1]= e(tau)[1,1]
	cd "$mainDIR"
}



matrix list results
gen placebo_variance = .
gen id = _n

forvalues i = 1(1)15 {
	
	replace placebo_variance = results[`i',1] if id==`i'

}

sum placebo_variance if id!=3 & id!=7 & id!=9 & id!=10 & id!=13 

* .1425035 SE



* SC

/*
Original Results

synth CO2_transport_capita GDP_per_capita vehicles_capita gas_cons_capita urban_pop ///
CO2_transport_capita(1989) CO2_transport_capita(1980) CO2_transport_capita(1970), ///
trunit(13) trperiod(1990) xperiod(1980(1)1989) nested unitnames(country) figure iterate(2000) keep(synth_results) replace    /*  .034956 */   

*customV(0.219 0.078 0.01 0.213 0.183 0.284 0.013)      rmspe  .0349572 

use synth_results, clear
gen gap = _Y_treated - _Y_synthetic

sum gap if _time >=1990    
-.2867492 ATT

*/

/*
Synthetic control using as predictors all lags of the dependent variable

use data\carbontax_data, clear
xtset Countryno year
gen treatment = 0
replace treatment =1 if Countryno==13 & year>=1990

synth CO2_transport_capita CO2_transport_capita(1989)  CO2_transport_capita(1988)  CO2_transport_capita(1987)  CO2_transport_capita(1986) ///
CO2_transport_capita(1985)  CO2_transport_capita(1984)  CO2_transport_capita(1983)  CO2_transport_capita(1982)  CO2_transport_capita(1981) ///
CO2_transport_capita(1980)  CO2_transport_capita(1979)  CO2_transport_capita(1978)  CO2_transport_capita(1977)  CO2_transport_capita(1976) ///
CO2_transport_capita(1975)  CO2_transport_capita(1974)  CO2_transport_capita(1973)  CO2_transport_capita(1972)  CO2_transport_capita(1971) ///
CO2_transport_capita(1970) CO2_transport_capita(1969) CO2_transport_capita(1968) CO2_transport_capita(1967) CO2_transport_capita(1966) ///
CO2_transport_capita(1965) CO2_transport_capita(1964) CO2_transport_capita(1963) CO2_transport_capita(1962) ///
CO2_transport_capita(1961) CO2_transport_capita(1960), ///
trunit(13) trperiod(1990) unitnames(country) nested iterate(2000) figure keep(synth_results_extension) replace


use synth_results_extension, clear
gen gap = _Y_treated - _Y_synthetic
egen ATT = mean(gap) if _time >= 1990
sum ATT
*-.2810822 ATT

*/


use data\carbontax_data, clear
xtset Countryno year
gen treatment = 0
replace treatment =1 if Countryno==13 & year>=1990


sdid CO2_transport_capita Countryno year treatment, ///
vce(placebo) seed(123)  ///
method(sc) graph g1on mattitles ///
g1_opt(xtitle(" ") scheme(sj) ///
xlabel(1 "Australia" 2 "Belgium" 3 "Canada" 4 "Denmark" 5 "France" 6 "Greece" 7 "Iceland" 8 "Japan" ///
9 "New Zealand" 10 "Poland" 11 "Portugal" 12 "Spain" 13 "Switzerland" 14 "United States"))  ///
g2_opt(ylabel(0(1)3) scheme(sj) ytitle("Metric tons per capita (CO2 from transport)", margin(medium)) ///
legend(order(2 "Sweden" 1 "Synthetic Sweden"))) 
*-0.27122  ATT / 0.40887 SE

graph export "$outputDIR\SC Figures\SC weights.png", as(png) name("g1_1990") replace
graph export "$outputDIR\SC Figures\SC outcome.png", as(png) name("g2_1990") replace


matrix results = J(15,1,.)
forvalues i = 1(1)15 {
	use data\carbontax_data, clear
    xtset Countryno year
    gen treatment = 0
    replace treatment =1 if Countryno==`i' & year>=1990
	
	cd "$outputDIR\SC Figures"
	sdid CO2_transport_capita Countryno year treatment, ///
    vce(noinference) seed(123) method(sc) graph graph_export(sc_`i', .png) ///
    g1_opt(xtitle(" ") scheme(sj)) ///
    g2_opt(ylabel(0(1)6) scheme(sj) ytitle("Metric tons per capita (CO2 from transport)", margin(medium))) 
	
    matrix results[`i',1]= e(tau)[1,1]
	cd "$mainDIR"
}

matrix list results


gen placebo_variance = .
gen id = _n

forvalues i = 1(1)15 {
	
	replace placebo_variance = results[`i',1] if id==`i'

}

sum placebo_variance if id !=3 & id!=7 & id!=10 & id!=11 & id!=13 & id!=15

*  0.1509147 SE



* SDiD
use data\carbontax_data, clear
xtset Countryno year
gen treatment = 0
replace treatment =1 if Countryno==13 & year>=1990

sdid CO2_transport_capita Countryno year treatment, ///
vce(placebo) seed(123)  ///
method(sdid) graph g1on mattitles ///
g1_opt(xtitle(" ") scheme(sj) ///
xlabel(1 "Australia" 2 "Belgium" 3 "Canada" 4 "Denmark" 5 "France" 6 "Greece" 7 "Iceland" 8 "Japan" ///
9 "New Zealand" 10 "Poland" 11 "Portugal" 12 "Spain" 13 "Switzerland" 14 "United States"))  ///
g2_opt(ylabel(0(1)3) scheme(sj) ytitle("Metric tons per capita (CO2 from transport)", margin(medium)) ///
legend(order(2 "Sweden" 1 "Synthetic Sweden"))) 
* -0.34822 ATT / 0.30675 SE

graph export "$outputDIR\SDiD Figures\SDiD weights.png", as(png) name("g1_1990") replace
graph export "$outputDIR\SDiD Figures\SDiD outcome.png", as(png) name("g2_1990") replace



matrix results = J(15,1,.)
forvalues i = 1(1)15 {
	use data\carbontax_data, clear
    xtset Countryno year
    gen treatment = 0
    replace treatment =1 if Countryno==`i' & year>=1990
	
	cd "$outputDIR\SDiD Figures"
	sdid CO2_transport_capita Countryno year treatment, ///
    vce(noinference) seed(123) method(sdid) graph graph_export(sdid_`i', .png) ///
    g1_opt(xtitle(" ") scheme(sj)) ///
    g2_opt(ylabel(0(1)6) scheme(sj) ytitle("Metric tons per capita (CO2 from transport)", margin(medium))) 
	
    matrix results[`i',1]= e(tau)[1,1]
	cd "$mainDIR"
}


matrix list results


gen placebo_variance = .
gen id = _n

forvalues i = 1(1)15 {
	
	replace placebo_variance = results[`i',1] if id==`i'

}

sum placebo_variance if id!=3 & id!=7 & id!=10 & id!=13 & id!= 14
* 0.1493607 SE



*==============================
* 2. SDiD plot with covariates
*==============================


*1. SDID with optimized covariates 
use data\carbontax_data, clear
xtset Countryno year
gen treatment = 0
replace treatment =1 if Countryno==13 & year>=1990


sdid CO2_transport_capita Countryno year treatment if Countryno!=10, vce(placebo) ///
covariates(GDP_per_capita gas_cons_capita vehicles_capita urban_pop) ///
seed(123) graph g1on ///
g1_opt(xtitle(" ") scheme(sj) ///
xlabel(1 "Australia" 2 "Belgium" 3 "Canada" 4 "Denmark" 5 "France" 6 "Greece" 7 "Iceland" 8 "Japan" ///
9 "New Zealand" 10 "Portugal" 11 "Spain" 12 "Switzerland" 13 "United States"))  ///
g2_opt(ylabel(0(1)3) scheme(sj) ytitle("Metric tons per capita (CO2 from transport)", margin(medium)) ///
legend(order(2 "Sweden" 1 "Synthetic Sweden"))) 
* -0.28977 / 0.20226 SE

graph export "$outputDIR\opt SDiD Figures\opt SDiD weights.png", as(png) name("g1_1990") replace
graph export "$outputDIR\opt SDiD Figures\opt SDiD outcome.png", as(png) name("g2_1990") replace


matrix results = J(15,1,.)
forvalues i = 1(1)15 {
	if `i' != 10{
		
	
	use data\carbontax_data, clear
    xtset Countryno year
    gen treatment = 0
    replace treatment =1 if Countryno==`i' & year>=1990
	
	cd "$outputDIR\opt SDiD Figures"
	sdid CO2_transport_capita Countryno year treatment if Countryno!=10, ///
    vce(noinference) seed(123) method(sdid) graph graph_export(opt_sdid_`i', .png) ///
	covariates(GDP_per_capita gas_cons_capita vehicles_capita urban_pop) ///
    g1_opt(xtitle(" ") scheme(sj)) ///
    g2_opt(ylabel(0(1)6) scheme(sj) ytitle("Metric tons per capita (CO2 from transport)", margin(medium))) 
	
    matrix results[`i',1]= e(tau)[1,1]
	cd "$mainDIR"
	}

}

matrix list results


gen placebo_variance = .
gen id = _n

forvalues i = 1(1)15 {
	
	if `i' != 10{
	
	replace placebo_variance = results[`i',1] if id==`i'
	}

}

sum placebo_variance if id!=3 & id!=7 & id!=13 & id!= 14

* 0.1331582



*2. SDID with projected covariates
use data\carbontax_data, clear
xtset Countryno year
gen treatment = 0
replace treatment =1 if Countryno==13 & year>=1990

sdid CO2_transport_capita Countryno year treatment if Countryno!=10, vce(placebo) ///
covariates(GDP_per_capita gas_cons_capita vehicles_capita urban_pop, projected) ///
seed(123) graph g1on ///
g1_opt(xtitle(" ") scheme(sj) ///
xlabel(1 "Australia" 2 "Belgium" 3 "Canada" 4 "Denmark" 5 "France" 6 "Greece" 7 "Iceland" 8 "Japan" ///
9 "New Zealand" 10 "Portugal" 11 "Spain" 12 "Switzerland" 13 "United States"))  ///
g2_opt(ylabel(0(1)3) scheme(sj) ytitle("Metric tons per capita (CO2 from transport)", margin(medium)) ///
legend(order(2 "Sweden" 1 "Synthetic Sweden"))) 
*  -0.29216 ATT /  0.24204 SE

graph export "$outputDIR\proj SDiD Figures\proj SDiD weights.png", as(png) name("g1_1990") replace
graph export "$outputDIR\proj SDiD Figures\proj SDiD outcome.png", as(png) name("g2_1990") replace

matrix results = J(15,1,.)
forvalues i = 1(1)15 {
	if `i' != 10{
		
	
	use data\carbontax_data, clear
    xtset Countryno year
    gen treatment = 0
    replace treatment =1 if Countryno==`i' & year>=1990
	
	cd "$outputDIR\proj SDiD Figures"
	sdid CO2_transport_capita Countryno year treatment if Countryno!=10, ///
    vce(noinference) seed(123) method(sdid) graph graph_export(proj_sdid_`i', .png) ///
	covariates(GDP_per_capita gas_cons_capita vehicles_capita urban_pop, projected) ///
	g1_opt(xtitle(" ") scheme(sj)) ///
    g2_opt(ylabel(0(1)6) scheme(sj) ytitle("Metric tons per capita (CO2 from transport)", margin(medium))) 
	
    matrix results[`i',1]= e(tau)[1,1]
	cd "$mainDIR"
	}
}

matrix list results


gen placebo_variance = .
gen id = _n

forvalues i = 1(1)15 {
	
	if `i' != 10{
	
	replace placebo_variance = results[`i',1] if id==`i'
	}

}

sum placebo_variance if id!=7 & id!=13 & id!=14

* 0.150727



log close  

